DATA_FILE=DeleteCustomers.csv
DATA_PATH=../Sample\ Data
DATA_CLOUD_API_ENDPOINT=https://$DATA_CLOUD_URL/api/v1/ingest/jobs/$JOB_ID/batches

echo Pushing Data to Bulk API: API Name $API_NAME Object Name: $OBJECT_NAME Job ID: $JOB_ID

echo "\n Uploading CSV..."
cd "$DATA_PATH"
echo Command:
echo curl -L -H \"Authorization: Bearer $DATA_CLOUD_ACCESS_TOKEN\" -H \"Content-Type: text/csv\" --data-binary @DeleteCustomers.csv -X PUT $DATA_CLOUD_API_ENDPOINT
RESPONSE=$(curl -s -L -H "Authorization: Bearer $DATA_CLOUD_ACCESS_TOKEN" -H "Content-Type: text/csv" --data-binary @DeleteCustomers.csv -X PUT $DATA_CLOUD_API_ENDPOINT)

echo $RESPONSE | jq .