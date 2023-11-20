# Bucket Archive Process 

### Requierments 

> Source bucket(prod) 
> Target bucket(archive)
> A uuid-to-leave.xlsx file with a list of UUID to leave at the source 
> gcloud init with the right permissions


## List all the entier source bucket into a txt file

```shell
$ gsutil ls gs://source_bucket/path/folder/ | grep '/$' > bucket_all_uuids.txt
```

## Create Virtual env

```shell
$ python3 -m venv venv
```

## Now, you will activate the virtual environment. On Unix or MacOS, you can do this by running:

```shell
$ source venv/bin/activate
```

## Let's start with the first script which overview the all bucket_all_uuids.txt and compae with the uuid-to-leave.xlsx

```shell
$ python3 missing-buckets.py

```
This will create a new file called "missing-uuids.xlsx" which will compare if no UUID in the uuid-to-leave.xlsx it will move it to "missing-uuids.xlsx"

## Now you can run the main script, after we have the missing-uuids.xlsx file
 
```shell
python src/main.py
```

## To run tests:

```shell
python -m unittest tests/test_main.py
```
