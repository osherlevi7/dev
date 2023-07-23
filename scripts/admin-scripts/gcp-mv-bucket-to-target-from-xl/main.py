import pandas as pd
import subprocess
from google.cloud import storage
from tqdm import tqdm  


# Authenticate to GCP
storage_client = storage.Client()

# Source and destination buckets
source_bucket_name = 'source_bucket/a/b'
destination_bucket_path = 'gs://target_bucket/a/b'

# Read the list of UUIDs from the Excel file
df = pd.read_excel('bucket_list.xlsx')

# Loop over the UUIDs and move the corresponding folders
for index, row in tqdm(df.iterrows(), total=df.shape[0]):
    uuid = row['UUID']  # replace 'UUID' with the appropriate column name
    source_folder_path = f'gs://{source_bucket_name}/{uuid}/*'
    destination_folder_path = f'{destination_bucket_path}/{uuid}/'

    # Construct the gsutil command
    cmd = f'gsutil -m mv {source_folder_path} {destination_folder_path}'

    # Execute the command
    subprocess.run(cmd, shell=True, check=True)