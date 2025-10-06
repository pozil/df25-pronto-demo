#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH

echo "Resetting demo..."
rm -rf force-app/main/default/classes
rm -rf force-app/main/default/lwc
git reset --hard HEAD
sf project deploy start -c -g -m ApexClass -m LightningComponentBundle -m FlexiPage

echo ""
echo Demo was reset. Remember to close all IDE tabs and clear dev agent history.
echo ""