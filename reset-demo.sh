#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH

git reset --hard HEAD
sf project deploy start -c -g

echo ""
echo Demo was reset. Remember to close all IDE tabs and clear dev agent history.
echo ""