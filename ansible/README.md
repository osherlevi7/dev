# Ansible Project with dynamic-inventory using GCP-Plugin

### Install the plugin 
* ansible-galaxy collection install google.cloud



### References
* https://devopscube.com/ansible-dymanic-inventry-google-cloud/#:~:text=It%20is%20an%20ansible%20google,group%20instances%20based%20on%20names 

> List of all VM instances
* $ ansible-inventory --graph

> List of VM instances by group name
* $ ansible-inventory --graph demo     # /dev/stage/prod

> Run the ansible-playbook with vault_password_file
* $ ansible-playbook -i inventory/inventory.gcp.yml -l demo playbook.yml --vault-password-file /home/ansible/ansible/pass.txt


