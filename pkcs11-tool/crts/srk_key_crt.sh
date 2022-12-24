#!/bin/bash


# generate srk key and crts
export SRK1_KEY="SRK1_sha256_p256_ca"
# generate key pair to hsm
sudo pkcs11-tool \
  --module $PKCS11_MODULE \
  --pin $USR_PIN \
  --keypairgen \
  --key-type EC:prime256v1 \
  --label $SRK1_KEY \
  --id 1001
# generate csr
sudo openssl req \
  -engine pkcs11 \
  -new -batch \
  -subj "/CN=${SRK1_KEY}/" \
  -key "label_${SRK1_KEY}" \
  -keyform engine \
  -out temp_srk_req.pem
# generate crt
sudo openssl ca \
  -engine pkcs11 \
  -batch \
  -md sha256 \
  -outdir ./ \
  -in ./temp_srk_req.pem \
  -cert "${CA_KEY}.pem" \
  -keyform engine \
  -keyfile "label_${CA_KEY}" \
  -extfile ~/cst-3.1.0/ca/v3_ca.cnf \
  -out "${SRK1_KEY}.pem" \
  -notext \
  -days 10950 \
  -config ~/cst-3.1.0/ca/openssl.cnf
# convert pem to der
sudo openssl x509 \
  -outform der \
  -in ${SRK1_KEY}.pem \
  -out ${SRK1_KEY}.der
# register crt to hsm
sudo pkcs11-tool \
  --module $PKCS11_MODULE -l \
  --write-object ${SRK1_KEY}.der \
  --type cert \
  --label $SRK1_KEY \
  --id 1001 \
  --pin $USR_PIN