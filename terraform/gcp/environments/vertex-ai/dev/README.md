## command to run this terraform 

### Init the backend state on a GCP bucket & install providers 
<br>

```sh


	$ terraform init 

```
### Plan the infra using the tevars file 
<br>

```sh 

	
	$ terraform plan -var-file=terraform.tfvars

```

### Apply the infra

```sh 

	$ terraform apply -var-file=terraform.tfvars

```
