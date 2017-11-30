#!/usr/bin/env bash
set -eu
set -o pipefail

if [ -z $@ ]; then
    echo "Please specify the roles you need as spaced cli arguments."
    echo "For example 'bash ansible-init.sh myrole yourole theirrole'."
    echo
    exit 1;
fi

# Overwrite warning
echo "=== WARNING: THIS SCRIPT MAY OVERWRITE ANY EXISTING ANSIBLE FILES! ==="
read -p "CONTINUE? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Right, we'll stop here then. Goodbye."
    exit 1
fi
echo

# Vars
ANSIBLE_CONFIG=ansible.cfg
ANSIBLE_TOP_LEVEL_DIRS=(group_vars host_vars)
ANSIBLE_ROLE_DIRS=(tasks handlers templates files vars defaults meta)
ANSIBLE_PLAY=site.yml
ANSIBLE_INVENTORY=inventory

# Create ansible.cfg with some defaults
echo "+ Creating a config with some common defaults..."
touch ${ANSIBLE_CONFIG}

cat > ${ANSIBLE_CONFIG} <<EOF
[default]
inventory         = ./inventory
roles_path        = ./roles
become            = True
become_method     = sudo
private_key_file  = ~/.ssh/id_rsa
host_key_checking = False
EOF

echo "+ Done."
echo

# Create an inventory file
echo "+ Creating a blank inventory file..."
touch ${ANSIBLE_INVENTORY}
echo "[all]" > ${ANSIBLE_INVENTORY}

echo "+ Done."
echo

# Create top-level directory structure
echo "+ Creating top-level directories..."
for dir in ${ANSIBLE_TOP_LEVEL_DIRS[@]}; do
    mkdir -p ${dir}
done

echo "+ Done."
echo

# Create roles structure
echo "+ Creating roles directory..."
mkdir -p roles

echo "+ Done."
echo

echo "+ Setting desired roles with common directory structure..."
for role in $@; do
    for dir in ${ANSIBLE_ROLE_DIRS[@]}; do
        mkdir -p roles/${role}/${dir}
    done
    echo "---" > roles/${role}/tasks/main.yml
done

echo "+ Done."
echo

# Create a master site.yml playbook calling all roles on all hosts
echo "+ Creating a top-level playbook to run provided roles..."
touch ${ANSIBLE_PLAY}

cat > ${ANSIBLE_PLAY} <<EOF
---
- hosts: all
  gather_facts: False
  become: True
  roles:
$(for role in $@; do echo "    - ${role}"; done)
EOF

echo "+ Done"
echo

echo "You're all set! Goodbye!"
