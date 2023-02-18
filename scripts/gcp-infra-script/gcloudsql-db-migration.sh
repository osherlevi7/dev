#!/bin/bash
set -u
# Check for Gcloud
if ! type gcloud > /dev/null; then
    echo "ERROR: Gcloud CLI not found!"
fi
# Check for pigz
if ! type pigz > /dev/null; then
    gzipper=pigz
else
    gzipper=gzip
fi

for i in "$@"
do
case $i in
    -destInstance=*|--destInstance=*)
      destInstance="${i#*=}"
    [ -z "$destInstance" ] && echo true
      ;;
    -sourceInstance=*|--sourceInstance=*)
      sourceInstance="${i#*=}"
    [ -z "$sourceInstance" ] && echo true
      ;;
    -destDB=*|--destdb=*)
    destDB="${i#*=}"
    [ -z "$destDB" ] && echo true
    ;;
    -sourceDB=*|--sourcedb=*)
    sourceDB="${i#*=}"
    [ -z "$sourceDB" ] && echo true
    ;;
    -tables=*|--tables=*)
    sourceTables="${i#*=}"
    [ -z "$sourceTables" ] && echo true
    ;;
    -project=*|--project=*)
    project="${i#*=}"
    [ -z "$project" ] && echo true
    ;;
    -destDBSA=*|--destDBSA=*)
    destDBSA="${i#*=}"
    [ -z "$destDBSA" ] && echo true
    ;;
   -sourceDBSA=*|--sourcetDBSA=*)
   sourceDBSA="${i#*=}"
    [ -z "$sourceDBSA" ] && echo true
   ;;
  -exportBucket=*|--exportBucket=*)
  exportBucket="${i#*=}"
   [ -z "$exportBucket" ] && echo true
  ;;
  *)
      echo "UNKNOWN FLAG: ${1}";
      echo ""
    ;;
esac
done

echo "==="
echo "GCP PROJECT: ${project}"
echo "SOURCE TABLES: ${sourceTables}"
echo "SOURCE DATABASE SERVICE ACCOUNT ADDRESS: ${sourceDBSA}"
echo "DESTINATION DATABASE SERVICE ACCOUNT ADDRESS: ${destDBSA}"
echo "EXPORT BUCKET: ${exportBucket}"
echo "SOURCE INSTANCE: ${sourceInstance}"
echo "DESTINATION INSTANCE: ${destInstance}"
echo "SOURCE DATABASE: ${sourceDB}"
echo "DESTINATION DATABASE: ${destDB}"
echo "==="
echo ""

# BEGIN EXPORT
timestamp=$(date +%s)
echo ${timestamp}
echo "INFO: GSQL: Granting ${sourceDBSA} Read Access TO ${exportBucket}"
echo ""
gsutil acl ch -u ${sourceDBSA}:W ${exportBucket}

# Run Export, Catch gcloud-cli timeouts, and follow operations
echo "==="
echo "INFO: GSQL: Exporting ${sourceTables} FROM ${sourceDB} ON ${sourceInstance} TO ${exportBucket}/sql/${timestamp}/_new_${timestamp}.sql.gz"
echo "==="
gcloudExport=$(gcloud sql export sql ${sourceInstance} ${exportBucket}/sql/${timestamp}/_new_${timestamp}.sql.gz --table=${sourceTables} --database=${sourceDB} --project ${project} 2>&1)
echo ""
if [ $? -eq 0 ]
then
  echo "pipestatus: ${PIPESTATUS[0]}"
  sqlOperation=$(echo "$gcloudExport" | grep -Eo '\`.*\`' | tr -d '`' | tr -d '\n')
  until eval "$sqlOperation"; do
    echo "==="
    echo "WARNING: Gcloud SQL Operation Watch Timeout: Retrying in 10 seconds.."
    echo "==="
    sleep 10
    done
fi
echo ""
echo "==="
echo "INFO: GS: Granting ${destDBSA} Read Access TO ${exportBucket}/sql/${timestamp}/_new_${timestamp}.sql.gz"
echo "==="
gsutil acl ch -u ${destDBSA}:R ${exportBucket}/sql/${timestamp}/_new_${timestamp}.sql.gz
echo ""
echo "==="
echo "INFO: Creating Local Directories"
echo "==="
mkdir -p  ./${timestamp}/sql
cd ./${timestamp}/sql
echo ""
echo "==="
echo "INFO: GS: Downloading ${exportBucket}/sql/${timestamp}/_new_${timestamp}.sql.gz"
echo "==="
gsutil cp ${exportBucket}/sql/${timestamp}/_new_${timestamp}.sql.gz .
echo ""
echo "==="
echo "INFO: Extracting _new_${timestamp}.sql.gz"
echo "==="
$gzipper -d -n ./_new_${timestamp}.sql.gz
echo ""
echo "==="
echo "INFO: Replacing ${sourceTables} WITH _new_${timestamp} Prefix"
echo "==="
for i in $(echo $sourceTables | sed "s/,/ /g")
do
  sed -i -e "s/$i/_new_${timestamp}_$i/g" _new_${timestamp}.sql
    echo "$i"
done
echo ""
echo "==="
echo "INFO: SQL PREVIEW (first 30l):"
echo "==="
echo ""
HEAD -30 _new_${timestamp}.sql
echo ""
echo "==="
echo "INFO: Gzipping _new_${timestamp}_.sql"
echo "==="
$gzipper _new_${timestamp}.sql
echo ""
echo "==="
echo "INFO: Uploading Composite Files: _new_${timestamp}.sql TO ${exportBucket}/sql/${timestamp}/modified/_new_${timestamp}.sql.gz"
echo "==="
gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp _new_${timestamp}.sql.gz ${exportBucket}/sql/${timestamp}/modified/_new_${timestamp}.sql.gz
echo ""
echo "==="
echo "INFO: GS: Granting ${destInstance} Read Access TO ${exportBucket}/sql/${timestamp}/_new_${timestamp}.sql.gz "
echo "==="
gsutil acl ch -u ${destDBSA}:R  ${exportBucket}/sql/${timestamp}/modified/_new_${timestamp}.sql.gz
echo "==="
echo "INFO: Importing Tables to ${destInstance} ${destDB} : _new_${timestamp}.sql TO ${exportBucket}/sql/${timestamp}/modified/_new_${timestamp}.sql.gz"
echo "==="
gcloudImport=$(gcloud sql import sql ${destInstance}  ${exportBucket}/sql/${timestamp}/modified/_new_${timestamp}.sql.gz --database=${destDB} --project=${project} 2>&1)
echo ""
if [ $? -eq 0 ]
then
  echo "pipestatus: ${PIPESTATUS[0]}"
  sqlOperation=$(echo "$gcloudImport" | grep -Eo '\`.*\`' | tr -d '`' | tr -d '\n')
  until eval "$sqlOperation"; do
    echo "==="
    echo "WARNING: Gcloud SQL Operation Watch Timeout: Retrying in 10 seconds.."
    echo "==="
    sleep 10
    done
fi
echo ""
echo "==="
echo "INFO: Deleting ${timestamp}/"
echo "==="
mv ../../
rm -- "$timestamp"/*
echo ""
echo "==="
echo "INFO: GS: Revoking Access to_new_${timestamp}.sql.gz"
echo "==="
# Remove Service Account Read Access to Export File
gsutil acl ch -d ${sourceDBSA} ${exportBucket}
gsutil acl ch -d ${destDBSA} ${exportBucket}/sql/${timestamp}/_new_${timestamp}.sql.gz
gsutil acl ch -d ${destDBSA} ${exportBucket}/sql/${timestamp}/modified/_new_${timestamp}.sql.gz
