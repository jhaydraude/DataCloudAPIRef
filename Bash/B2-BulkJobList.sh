
DATA_CLOUD_API_ENDPOINT=https://$DATA_CLOUD_URL/api/v1/ingest/jobs


echo "\n Querying Bulk API Jobs..."
echo Command:
echo curl -L -H \"Authorization: Bearer $DATA_CLOUD_ACCESS_TOKEN\"  -X GET  $DATA_CLOUD_API_ENDPOINT

RESPONSE=$(curl -s -L -H "Authorization: Bearer $DATA_CLOUD_ACCESS_TOKEN"  -X GET  $DATA_CLOUD_API_ENDPOINT)

echo $RESPONSE | jq .
