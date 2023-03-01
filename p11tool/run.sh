#!/bin/bash

set -x

# https://stackoverflow.com/questions/53230852/error-creating-token-via-softhsm2-as-non-root-user-could-not-initialize-the-lib
mkdir -p ./softhsm/tokens
pushd ./softhsm/tokens
echo "directories.tokendir = ${PWD}" > softhsm2.conf
export SOFTHSM2_CONF=${PWD}/softhsm2.conf
popd
# https://gitlab.com/gnutls/gnutls/-/issues/721
softhsm2-util --init-token --free --label softhsm --pin $USR_PIN --so-pin $SO_PIN
p11tool --generate-privkey=RSA --bits=2048 --label=pkey --login --set-pin=$USR_PIN pkcs11:token=softhsm
p11tool --list-all --so-login --set-so-pin=$SO_PIN pkcs11:token=softhsm


URL=$(p11tool --list-token-url --so-login --set-so-pin=$SO_PIN pkcs11:token=softhsm | sed -n 2p)";pin-value="${SO_PIN}

openssl req -engine pkcs11 -new -key ${URL} -keyform engine -out req.pem -text -x509 -subj "/CN=NXP Semiconductor"

openssl x509 -engine pkcs11 -signkey ${URL} -keyform engine -in req.pem -out cert.pem


echo "hello softhsm" > plain.txt
openssl pkeyutl -engine pkcs11 -encrypt -in plain.txt -out encrypted.enc -inkey cert.pem -certin
openssl pkeyutl -engine pkcs11 -decrypt -in encrypted.enc -out plain.dec -inkey ${URL} -keyform engine
cat plain.txt
cat plain.dec

rm -rf ./softhsm
rm -rf ./*.pem ./*.enc ./*.dec ./*.txt

set +x
