#!/bin/bash

# Navigate to the ansible directory
cd ansible

# Run the ansible playbook
ansible-playbook -i inventory.ini common.yml
ansible-playbook -i inventory.ini peer.yml
ansible-playbook -i inventory.ini orderer.yml
ansible-playbook -i inventory.ini couchdb.yml