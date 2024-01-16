

OBJECT_NAME=customers
API_NAME=CustomerOrders
DATA_FILE=Customers.csv
DATA_PATH=Sample\ Data
DATA_CLOUD_API_ENDPOINT=https://$DATA_CLOUD_URL/api/v1/ingest/jobs
PAYLOAD=$(jq --null-input --arg object "$OBJECT_NAME" --arg sourceName "$API_NAME" --arg operation "upsert" '{"object": $object, "sourceName": $sourceName, "operation": $operation}')


echo Pushing Data to Bulk API: API Name $API_NAME Object Name: $OBJECT_NAME

echo "\n Creating Bulk API Job..."
echo Command:

echo curl -s -L -H \"Authorization: Bearer $DATA_CLOUD_ACCESS_TOKEN\" -H \"Content-Type: application/json\" -d \'"${PAYLOAD}"\' -X POST  $DATA_CLOUD_API_ENDPOINT

RESPONSE=$(curl -s -L -H "Authorization: Bearer $DATA_CLOUD_ACCESS_TOKEN" -H "Content-Type: application/json" -d "${PAYLOAD}" -X POST  $DATA_CLOUD_API_ENDPOINT)
echo $RESPONSE
echo $RESPONSE | jq .

JOB_ID=$(echo $RESPONSE | jq -r '.id')

echo Job ID: $JOB_ID

echo "\nTo store the Job ID as an variable for subsequent access, copy/paste the following:\n\n"
echo export JOB_ID=$JOB_ID