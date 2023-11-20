#!/bin/bash
echo Creating a scheduler
## functions
function usage() {
  echo "$0 <project id> <sub_domain> <region name>"
  exit 1
}
## main
if [ $# -ne 3 ]; then
   usage
else
   project=$1
   sub_domain=$2
   region=$3
fi
echo "Create Jobs tasks"
gcloud scheduler jobs create http --project=$project ${sub_domain}-manage-appointments \
         	 --location=$region --schedule="* * * * *" --max-backoff=3600s \
		 --max-doublings=5 --max-retry-duration=0s --min-backoff=5s \
		 --time-zone="Africa/Abidjan" --attempt-deadline=180s --http-method=GET \
		 --oidc-token-audience=https://${sub_domain}.domain.ai/v1/manage-appointments/ \
		 --oidc-service-account-email=sa@.iam.gserviceaccount.com \
		 --headers="User-Agent=Google-Cloud-Scheduler" --attempt-deadline=180s \
		 --description="${sub_domain} manage-appointments job"

gcloud scheduler jobs create http --project=$project ${sub_domain}-appointment-reminder \
         	 --location=$region --schedule="0 * * * *" --max-backoff=300s \
		 --max-doublings=5 --max-retry-duration=0s --min-backoff=10s \
		 --time-zone="US/Central" --attempt-deadline=180s --http-method=GET \
		 --oidc-token-audience=https://${sub_domain}.domain.ai/v1/appointment-reminder/ \
		 --oidc-service-account-email=sa@.iam.gserviceaccount.com \
		 --headers="User-Agent=Google-Cloud-Scheduler" --attempt-deadline=180s \
		 --description="${sub_domain} appointment-reminder job"

gcloud scheduler jobs create http --project=$project ${sub_domain}-expire-transactions \
         	 --location=$region --schedule="0 0 * * *" --max-backoff=3600s \
		 --max-doublings=5 --max-retry-duration=0s --min-backoff=5s \
		 --time-zone="Africa/Abidjan" --attempt-deadline=180s --http-method=POST \
		 --oidc-token-audience=https://${sub_domain}.domain.ai/v1/run-expire-transactions-job/ \
		 --oidc-service-account-email=sa@.iam.gserviceaccount.com \
		 --headers="User-Agent=Google-Cloud-Scheduler" --attempt-deadline=180s \
		 --description="${sub_domain} run-expire-transactions-job job"

gcloud scheduler jobs create http --project=$project ${sub_domain}-later-function \
         	 --location=$region --schedule="* * * * *" --max-backoff=3600s \
		 --max-doublings=5 --max-retry-duration=0s --min-backoff=5s \
		 --time-zone="Africa/Abidjan" --attempt-deadline=180s --http-method=GET \
		 --oidc-token-audience=https://${sub_domain}.domain.ai/v1/later-function/ \
		 --oidc-service-account-email=sa@.iam.gserviceaccount.com \
		 --headers="User-Agent=Google-Cloud-Scheduler" --attempt-deadline=180s \
		 --description="${sub_domain} later-function job"

gcloud scheduler jobs create http --project=$project ${sub_domain}-queue-scheduled-appointmnets \
         	 --location=$region --schedule="* * * * *" --max-backoff=3600s \
		 --max-doublings=5 --max-retry-duration=0s --min-backoff=5s \
		 --time-zone="US/Central" --attempt-deadline=180s --http-method=POST \
		 --oidc-token-audience=https://${sub_domain}.domain.ai/v1/run-appointment-schedule-job/ \
		 --oidc-service-account-email=sa@.iam.gserviceaccount.com \
		 --headers="User-Agent=Google-Cloud-Scheduler" --attempt-deadline=180s \
		 --description="${sub_domain} run-appointment-schedule-job job"

gcloud scheduler jobs create http --project=$project ${sub_domain}-daily-shift-reminder \
         	 --location=$region --schedule="0 13 * * *" --max-backoff=3600s \
		 --max-doublings=5 --max-retry-duration=0s --min-backoff=5s \
		 --time-zone="America/New_York" --attempt-deadline=180s --http-method=GET \
		 --oidc-token-audience=https://${sub_domain}.domain.ai/v1/alert-doctor-shifts/ \
		 --oidc-service-account-email=sa@.iam.gserviceaccount.com \
		 --headers="User-Agent=Google-Cloud-Scheduler" --attempt-deadline=180s \
		 --description="${sub_domain} alert-doctor-shifts job"

gcloud scheduler jobs create http --project=$project ${sub_domain}-update-patient-indicators \
         	 --location=$region --schedule="0 1 * * *" --max-backoff=300s \
		 --max-doublings=5 --max-retry-duration=0s --min-backoff=10s \
		 --time-zone="Etc/GMT" --attempt-deadline=180s --http-method=GET \
		 --oidc-token-audience=https://${sub_domain}.domain.ai/v1/updated-indicators/ \
		 --oidc-service-account-email=sa@.iam.gserviceaccount.com \
		 --headers="User-Agent=Google-Cloud-Scheduler" --attempt-deadline=180s \
		 --description="${sub_domain} updated-patient-indicators job"

gcloud scheduler jobs create http --project=$project ${sub_domain}-reset-visits-cancelled-subscriptions \
         	 --location=$region --schedule="0 0 * * *" --max-backoff=300s \
		 --max-doublings=5 --max-retry-duration=0s --min-backoff=10s \
		 --time-zone="Etc/GMT" --attempt-deadline=180s --http-method=GET \
		 --oidc-token-audience=https://${sub_domain}.domain.ai/v1/zuora/reset-visits-on-sub-cancel/ \
		 --oidc-service-account-email=sa@.iam.gserviceaccount.com \
		 --headers="User-Agent=Google-Cloud-Scheduler" --attempt-deadline=180s \
		 --description="${sub_domain} reset-visits-cancelled-subscriptions job"

gcloud scheduler jobs create http --project=$project ${sub_domain}-zuora-products-sync \
         	 --location=$region --schedule="0 1 * * *" --max-backoff=300s \
		 --max-doublings=5 --max-retry-duration=0s --min-backoff=10s \
		 --time-zone="Etc/GMT" --attempt-deadline=180s --http-method=GET \
		 --oidc-token-audience=https://${sub_domain}.domain.ai/v1/products-sync/ \
		 --oidc-service-account-email=sa@.iam.gserviceaccount.com \
		 --headers="User-Agent=Google-Cloud-Scheduler" --attempt-deadline=180s \
		 --description="${sub_domain} zuora-products-sync job"
