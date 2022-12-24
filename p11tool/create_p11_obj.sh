#!/bin/bash

export USR_PIN=1234
export SO_PIN=1234

softhsm2-util --init-token -free -label softhsm --pin $USR_PIN --so_pin $SO_PIN
p11tool --so-login --batch --label 