#!/bin/bash


# create ca key and crts
export CA_KEY="CA1_sha256_p256_ca"
# create key pair to hsm
sudo pkcs11-tool \
  --module $PKCS11_MODULE -l \
  --pin $USR_PIN \
  --keypairgen \
  --key-type EC:prime256v1 \
  --label $CA_KEY \
  --id 1000
# create self-crt
sudo openssl req \
  -engine pkcs11 \
  -new -batch \
  -subj "/CN=${CA_KEY}/" \
  -key "label_${CA_KEY}" \
  -keyform engine \
  -out ${CA_KEY}.pem \
  -text -x509 \
  -days 10950 \
  -config ~/cst-3.1.0/ca/openssl.cnf
