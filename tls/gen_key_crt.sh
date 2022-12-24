#!/bin/bash

# generate srk key and crts
export TLS1_KEY="TLS1_sha256_p256_svr"
# generate key pair to hsm
sudo pkcs11-tool \
  --module $PKCS11_MODULE \
  --pin $USR_PIN \
  --keypairgen \
  --key-type EC:prime256v1 \
  --label $TLS1_KEY \
  --id 2001



# generate csr
sudo openssl req -new \
  -engine pkcs11 \
  -keyform engine \
  -key "label_${TLS1_KEY}" \
  -subj "/C=JP/ST=Nagoya/O=myhome/CN=server" \
  -out server.csr



sudo openssl req \
  -engine pkcs11 \
  -new -batch \
  -subj "/CN=${TLS1_KEY}/" \
  -key "label_${TLS1_KEY}" \
  -keyform engine \
  -out temp_srk_req.pem