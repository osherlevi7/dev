# ANSIBLE
#### Set the LB IP range & API agent IP
Metal LB is set to the cluster with a range of services
The rage is  **"192.168.0.222-192.168.0.240"**
```sh
    vim k3s-ansible/inventory/cluster/group_vars/all.yaml
```
#### Set the Master and the Node on the Inventory file
The IP of the eno1 interface on the nodes
```sh
    # on the nodes machine run -
    # ip a | grep 192
    vim k3s-ansible/inventory/cluster/hosts.ini
```
#### creating the Cluster 
This will install the cluster with the masters and optionally with a workers
```sh
    ansible-playbook  site.yml -i k3s-ansible/inventory/cluster/hosts.ini 
```
#### remove the Cluster 
This will destroy the cluster and teh all configurations are related to them
```sh
    ansible-playbook  reset.yml -i k3s-ansible/inventory/cluster/hosts.ini 
```
<hr>
<br>

