# ansible-init
Simple bash script to initialise an Ansible-style project directory
as per [the best practice doc](http://docs.ansible.com/ansible/latest/playbooks_best_practices.html#directory-layout).

**Please note that this script will probably overwrite any existing Ansible files
you have in the directory. It's mean to work as an initialisation command, so run
it in a fresh directory.**

# Running it
Clone the script into a directory somewhere outside your project, then:

`cd /path/to/your/project`

`bash /path/to/ansible-init.sh role1 role2 roleN`
