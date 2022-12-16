#!/bin/bash

# export
export PKCS11_MODULE=$(find /usr/lib/ -name p11-kit-proxy.so)
export SO_PIN=7635005489180126
export USR_PIN=12345678

# init token
sudo pkcs11-tool \
  --module $PKCS11_MODULE \
  --init-token \
  --init-pin \
  --so-pin $SO_PIN \
  --new-pin $USR_PIN \
  --label "CST-HSM-DEMO" \
  --pin $USR_PIN \
  --login
