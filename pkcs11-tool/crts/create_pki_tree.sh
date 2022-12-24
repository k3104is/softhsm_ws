#!/bin/bash

# create pki tree
touch index.txt
echo "unique_subject = no" > index.txt.attr
echo "12345678" > serial