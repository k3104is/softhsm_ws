#!/bin/bash
sudo cat /usr/share/p11-kit/modules/softhsm2.module
sudo sh -c 'echo "priority: 10" >> /usr/share/p11-kit/modules/softhsm2.module'
sudo cat /usr/share/p11-kit/modules/softhsm2.module
sudo p11-kit list-modules
