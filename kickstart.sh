#/usr/bin/env bash
cd baseboxes
vagrant basebox build ubuntu-12.10-amd64
vagrant basebox export ubuntu-12.10-amd64
cd -
vagrant up 

