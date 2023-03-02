#!/bin/bash

set -x

# https://stackoverflow.com/questions/53230852/error-creating-token-via-softhsm2-as-non-root-user-could-not-initialize-the-lib
mkdir -p ./softhsm/tokens
pushd ./softhsm/tokens
echo "directories.tokendir = ${PWD}" > softhsm2.conf
export SOFTHSM2_CONF=${PWD}/softhsm2.conf
popd

# https://gitlab.com/gnutls/gnutls/-/issues/721
softhsm2-util --init-token --free --label softhsm --pin ${USER_PIN} --so-pin ${SO_PIN}
URL=$(p11tool --list-token-url --so-login --set-so-pin=${SO_PIN} pkcs11:token=softhsm | sed -n 2p)
URL_USER_PIN=${URL}";pin-value="${USER_PIN}

p11tool --login --generate-ecc --curve=secp256r1 --label="ec-key-256" --outfile="ec-key-256.pub" ${URL} --set-pin=${USER_PIN}
p11tool --login --list-privkeys ${URL} --set-pin=${USER_PIN}

openssl req -engine pkcs11 -new -key ${URL_USER_PIN} -keyform engine -out req.pem -x509 -subj "/CN=NXP Semiconductor"
openssl x509 -engine pkcs11 -signkey ${URL_USER_PIN} -keyform engine -in req.pem -out cert.pem

echo "hello softhsm" > plain.txt
openssl pkeyutl -engine pkcs11 -sign -in plain.txt -out cert_ecc.sign -inkey ${URL_USER_PIN} -keyform engine
openssl pkeyutl -verify -in plain.txt -sigfile cert_ecc.sign -inkey cert.pem -certin

set +x
