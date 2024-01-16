

OBJECT_NAME=customers
API_NAME=CustomerOrders
DATA_CLOUD_API_ENDPOINT=https://$DATA_CLOUD_URL/api/v1/ingest/sources/$API_NAME/$OBJECT_NAME
RECORDS_TO_DELETE="100000000,100000001"
echo Deleting Data via Streaming API: API Name $API_NAME Object Name: $OBJECT_NAME


echo "\n Deleting Data..."

echo Command:
echo curl -s  -L -H \"Authorization: Bearer $DATA_CLOUD_ACCESS_TOKEN\"  -X DELETE  \"$DATA_CLOUD_API_ENDPOINT?ids=$RECORDS_TO_DELETE\"

RESPONSE=$( curl -s  -L -H "Authorization: Bearer $DATA_CLOUD_ACCESS_TOKEN"  -X DELETE  "$DATA_CLOUD_API_ENDPOINT?ids=$RECORDS_TO_DELETE")

echo $RESPONSE | jq .