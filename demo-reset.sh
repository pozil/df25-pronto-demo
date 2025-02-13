#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH

git reset --hard HEAD
sf project deploy start -c -g -m ApexClass -m LightningComponentBundle

echo ""
echo Demo was reset. Remember to close all VS Code tabs.
echo ""