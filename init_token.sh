#!/bin/bash



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
