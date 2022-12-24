#!/bin/bash

# https://stackoverflow.com/questions/53230852/error-creating-token-via-softhsm2-as-non-root-user-could-not-initialize-the-lib
mkdir -p ./softhsm/tokens
pushd ./softhsm/
echo "directories.tokendir = $PWD/tokens" > softhsm2.conf
popd
export SOFTHSM2_CONF=/home/k3104is/workspace/softhsm_ws/p11tool/softhsm/softhsm2.conf
# https://gitlab.com/gnutls/gnutls/-/issues/721
softhsm2-util --init-token --free --label softhsm --pin $USR_PIN --so-pin $SO_PIN
p11tool --generate-privkey=RSA --bits=2048 --label=pkey --login --set-pin=$USR_PIN pkcs11:token=softhsm
p11tool --list-all --so-login --set-so-pin=$SO_PIN pkcs11:token=softhsm