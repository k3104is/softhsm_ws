#!/bin/bash

set -x

# https://stackoverflow.com/questions/53230852/error-creating-token-via-softhsm2-as-non-root-user-could-not-initialize-the-lib
mkdir -p ./softhsm/tokens
pushd ./softhsm/tokens
echo "directories.tokendir = ${PWD}" > softhsm2.conf
export SOFTHSM2_CONF=${PWD}/softhsm2.conf
popd

# generate softhsm
# https://gitlab.com/gnutls/gnutls/-/issues/721
softhsm2-util --init-token --free --label softhsm --pin ${USER_PIN} --so-pin ${SO_PIN}
URL=$(p11tool --list-token-url --so-login --set-so-pin=${SO_PIN} pkcs11:token=softhsm | sed -n 2p)
URL_USER_PIN=${URL}";pin-value="${USER_PIN}

# generate ecc key
p11tool --login --generate-ecc --curve=secp256r1 --label="ec-key-256" --outfile="ec-key-256.pub" ${URL} --set-pin=${USER_PIN}
# check
p11tool --login --list-privkeys ${URL} --set-pin=${USER_PIN}

# generate csr
openssl req -engine pkcs11 -new -key ${URL_USER_PIN} -keyform engine -out server.csr -subj "/CN=NXP Semiconductor"

# set serial
echo "01" > serial

# generate a private key for a curve
openssl ecparam -name prime256v1 > ecdsaparam

# create a self-signed certificate
openssl req -nodes -x509 \
  -newkey ec:ecdsaparam \
  -keyout ca.key \
  -subj "/C=JP/ST=Nagoya/O=myhome/CN=localhost" \
  -days 3650 \
  -out ca.crt

# certificate
openssl x509 -req \
  -in ./server.csr \
  -CA ca.crt \
  -CAserial serial \
  -CAkey ca.key \
  -out server.crt

# launch server
openssl s_server \
  -engine pkcs11 \
  -accept 54321 \
  -cert server.crt \
  -key ${URL_USER_PIN} -keyform engine \
  -CAfile ca.crt &
sleep 1

# launch client
echo "Hello, World!" | openssl s_client \
  -connect 127.0.0.1:54321 \
  -CAfile ca.crt \
  > /dev/null 2>&1
sleep 2

# delete task
jobs -l | awk -F' ' '{print $2}' | xargs kill -9 > /dev/null 2>&1
sleep 1

set +x
