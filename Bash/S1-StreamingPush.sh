

OBJECT_NAME=customers
API_NAME=CustomerOrders
DATA_FILE=streaminginsertpayload.json
DATA_PATH=../Sample\ Data
DATA_CLOUD_API_ENDPOINT=https://$DATA_CLOUD_URL/api/v1/ingest/sources/$API_NAME/$OBJECT_NAME

echo Pushing Data to Streaming API: API Name $API_NAME Object Name: $OBJECT_NAME

echo "\n Performing inline streaming validation..."
cd "$DATA_PATH"
echo Command:
echo curl -s  -L -H \"Authorization: Bearer $DATA_CLOUD_ACCESS_TOKEN\" -H \"Content-Type: application/json\" -d @$DATA_FILE -X POST  $DATA_CLOUD_API_ENDPOINT/actions/test
RESPONSE=$(curl -s  -L -H "Authorization: Bearer $DATA_CLOUD_ACCESS_TOKEN" -H "Content-Type: application/json" -d @$DATA_FILE -X POST  $DATA_CLOUD_API_ENDPOINT/actions/test)

echo $RESPONSE | jq .

echo "\n Inserting Data..."

echo curl -s  -L -H \"Authorization: Bearer $DATA_CLOUD_ACCESS_TOKEN\" -H \"Content-Type: application/json\" -d @$DATA_FILE -X POST  $DATA_CLOUD_API_ENDPOINT

RESPONSE=$(curl -s  -L -H "Authorization: Bearer $DATA_CLOUD_ACCESS_TOKEN" -H "Content-Type: application/json" -d @$DATA_FILE -X POST  $DATA_CLOUD_API_ENDPOINT)

echo $RESPONSE | jq .