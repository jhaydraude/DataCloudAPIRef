# Data Cloud Ingestion API Reference

## Purpose

This repo detailed step by step walkthroughs of using the Data Cloud Ingestion API. It is meant as a [companion to this guide]( 
https://salesforce.quip.com/daYKA7Iw9MfB)

This is in no way intended to be production code. It is a step by step walkthrough of the necessary calls to use the Data Cloud Ingestion API for the purposes of training and education.

The samples are bash scripts using cUrl with tokens stored in environment variables.

## Installation


```bash
# Clone the repository
git clone https://github.com/jhaydraude/DataCloudAPIReference

# Navigate to the project directory
cd DataCloudAPIReference

# Install dependencies
brew install jq
```

### Data Cloud Configuration

1. Create your [Connected App](https://salesforce.quip.com/SiSYADNSwKGN)
    - Open the file `Bash/Environment.env` and add the Consumer Key and Consumer Secrets to it.
    **It's important that the redirect URL in the connected app and in  `Environment.env` are the same**
2. Create the [API Connector](https://salesforce.quip.com/3b3SAaTV4hMn)
    - The Schema File for this project is located in `Sample Data/customer_orders_schema.yaml`
    **It's important that the connector name is `CustomerOrders` to match the sample data and scripts in this repository**
3. Deploy the [Data Streams](https://salesforce.quip.com/uDgmAbTYKmXQ)


## Usage



### Get a Data Cloud Access Token

The sample scripts use the [Web Server OAuth flow](https://help.salesforce.com/s/articleView?language=en_US&id=sf.remoteaccess_oauth_web_server_flow.htm&type=5) to get the initial access token as well as a [refresh token](https://help.salesforce.com/s/articleView?id=sf.remoteaccess_oauth_refresh_token_flow.htm&type=5) for subsequent runs.
This means that when you run the GetTokens script, it will launch a browser and ask you to log into your Data Cloud org the first time. After that it will still launch the browser but automatically authenticate with the refresh token.

Navigate to the bash scripts folder and run `1-GetDataCloudToken.sh`

```bash
cd Bash

./1-GetDataCloudToken.sh
```

The script will run and do the following:
- Check for a refresh token. If one is not found, open the browser to the connecte app auth page and wait for an access token in the callback.
- Take the access token and call the OAuth endpoint to get an auth code. 
- Take the auth code and call the Data Cloud token exchange endpoint to get a Data Cloud token. 
**Note that this token expires after 15 minutes. When it has expired, you can rerun this script**

At the end, the script will provide a few lines to copy/paste into your terminal to store the Data Cloud access token, the Data Cloud tennant endpoint and the Refresh token as environment variables to be used by subsequent scripts.

### Use the Streaming API

The Data Cloud Streaming API is designed for high frequencey, near-realtime ingestion of small (max 200kb) data packets.

1. Streaming Ingestion

With the tokens stored in memory, execute the script `S1-StreamingPush.sh`

```bash
./S1-StreamingPush.sh
```

This script uses the sample data file `Sample Data/streaminginsertpayload.json` and makes 2 calls to the Ingestion API endpoint
- First it validates the data
- Then it inserts the data

After you have insertted the data via the API, the Data Stream within your Data Cloud org should show status `Pending` then `In Progress` while it processes the incoming data. The Refresh History of the Data Stream will show the 2 newly added records.

2. Streaming Deletion

The deletion script `S2-StreamingDelete.sh` will delete the 2 records that were just inserted.

```bash
./S2-StreamingDelete.sh
```

As with the insert, you can see the processing of the deletion in the Data Stream status and History.

### Use the Bulk API

The Bulk API is designed to ingest large volumes of data in batches.

There are a few steps involved in managing BulkAPI Jobs.

1. Create the Bulk Job

```bash
./B1-BulkJobCreate.sh
```
This script calls the Ingestion API endpoint to create an ingestion job.

When the script has finished executing, copy the line from the output which sets the `JOB_ID` environment variable.

2. View Bulk Jobs (optional)

The scripts `B2-BulkJobList.sh` and `B3-BulkJobStatus.sh` will both give details about open Bulk API Ingestion Jobs. List will show all open jobs. Status will give more details about the job defined by the `JOB_ID` environment variable.

```bash
./B2-BulkJobList.sh

./B3-BulkJobStatus.sh
```

3. Upload Data

Upload CSV file to the Bulk API Job to define the records to be added (or deleted).

For insertions, the CSV must match the schema of the API. All fields are required. 

```bash
./B4-BulkDataUpload_Insert.sh
```
This script will upload the file `Sample Data/Customers.csv` which has 50,000 records.

For deleteions, the CSV should have no headers and a single column containing IDs to be deleted. The ID should match the primary key defined when creating the [Data Stream](https://salesforce.quip.com/uDgmAbTYKmXQ)

```bash
./B5-BulkDataUpload_Delete.sh
```
This script uploads the file `Sample Data/DeleteCustomers.csv`

4. Complete the Job

The uploaded CSV files will begin processing when you have closed the job

```bash
./B6-BulkJobComplete.sh
```

This script sends a PATCH request to the bulk job endpoint signalling that upload is complete and the job should begin processing. You can also edit the script to send an abort request which will cancel the job.

5. Delete the Job

Deleting the job removes the raw uploaded CSV files and the metadata of the upload job after processing has been completed. Only completed or aborted jobs can be deleted.

```bash
./B7-BulkJobDelete.sh
```

### Extra Credit

There are 2 additional data files in the sample data. Feel free to use these to build processes for ingesting into the Orders and OrderItems objects. These objects were created inside Data Cloud during the initial setup.  