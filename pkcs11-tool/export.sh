#!/bin/bash

# export
export PKCS11_MODULE=$(find /usr/lib/ -name p11-kit-proxy.so)
export SO_PIN=7635005489180126
export USR_PIN=12345678


# export SOFTHSM2_CONF=/usr/share/softhsm/softhsm2.conf
# directories.tokendir = /var/lib/softhsm/tokens/