#!/bin/bash

sudo apt install softhsm2 libsofthsm2-dev
sudo mkdir -p /var/lib/softhsm/tokens
sudo apt install opensc libengine-pkcs11-openssl
dpkg -s libengine-pkcs11-openssl | grep '^Version'

