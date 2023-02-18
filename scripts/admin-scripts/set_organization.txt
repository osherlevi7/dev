gcloud organizations add-iam-policy-binding <org_ID> --member=user:osher@domain.ai --role=roles/resourcemanager.folderAdmin
gcloud resource-manager folders create --display-name=infrastructure --organization=<org_ID>
gcloud resource-manager folders create --display-name=production --organization=<org_ID>
gcloud resource-manager folders create --display-name=development --organization=<org_ID>
gcloud projects create dns --folder=infrastructure
gcloud projects create dns --folder <folder_ID> --name="DNS"
gcloud projects create jenkins --folder 1025020209615 --name="jenkins"
gcloud resource-manager folders list 
gcloud resource-manager folders list --organization=<org_ID>
gcloud projects create production --folder <folder_ID --name="production"
gcloud projects create staging --folder <folder_ID> --name= "staging"
gcloud projects create development --folder <folder_ID> --name="development"

