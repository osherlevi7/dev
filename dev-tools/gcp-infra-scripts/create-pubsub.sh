#!/bin/bash
echo Creating a Pub/sub topics
## functions
function usage() {
  echo "$0 <project id> <name>"
  exit 1
}
## main
if [ $# -ne 2 ]; then
   usage
else
   project=$1
   name=$2
fi
# create service account in project
echo "Create PubSub topics"
topic_list="a b c d"
for topic in $topic_list 
do
	echo "Create topic $topic-$name"
	gcloud pubsub topics create ${topic}-${name} --labels=environment=${name}
done
