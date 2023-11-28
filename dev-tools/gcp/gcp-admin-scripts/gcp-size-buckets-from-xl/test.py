import os
import subprocess
import pandas as pd
from tqdm import tqdm

# Load the spreadsheet containing the bucket names
# Replace 'bucket_list.xlsx' with the path to your spreadsheet
df = pd.read_excel('bucket_list_20-k.xlsx')

# Initialize total size
total_size = 0

# Define the number of retries
num_retries = 3

# Iterate over each bucket
for bucket in tqdm(df['UUID']):
    # Initialize retry count
    retry_count = 0

    while retry_count < num_retries:
        try:
            # Use the gsutil du command to get the size of the bucket
            command = f'gsutil du -s gs://PATH/TO/YOUR/{bucket}'
            result = subprocess.run(command, shell=True, capture_output=True, text=True)

            # Check if the command returned any output
            if result.stdout:
                # The result is a string in the format "size  gs://bucket_name"
                # We split the string to get the size
                size = int(result.stdout.split()[0])

                # Add the size to the total
                total_size += size

                print(f'The size of bucket {bucket} is {size / 1024**3:.2f} GB')
            else:
                print(f'Could not get the size of bucket {bucket}. Check if the bucket exists and if you have the necessary permissions to access it.')
            
            # If we reach this point, the command was successful, so we break the loop
            break
        except Exception as e:
            print(f'Error getting the size of bucket {bucket}: {e}')
            retry_count += 1

        if retry_count == num_retries:
            print(f'Failed to get the size of bucket {bucket} after {num_retries} retries')

print(f'The total size of all buckets is {total_size / 1024**3:.2f} GB')

