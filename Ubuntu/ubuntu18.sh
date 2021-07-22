#!/bin/bash
packer build -force -var-file variables.json ubuntu18.json
