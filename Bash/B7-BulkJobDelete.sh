DATA_CLOUD_API_ENDPOINT=https://$DATA_CLOUD_URL/api/v1/ingest/jobs


echo "\n Deleting Bulk API Job $JOB_ID..."
echo Command:
echo curl -L -H \"Authorization: Bearer $DATA_CLOUD_ACCESS_TOKEN\" -H \"Content-Type: application/json\"  -X DELETE  $DATA_CLOUD_API_ENDPOINT/$JOB_ID
RESPONSE=$(curl -s -L -H "Authorization: Bearer $DATA_CLOUD_ACCESS_TOKEN"  -H "Content-Type: application/json"   -X DELETE  $DATA_CLOUD_API_ENDPOINT/$JOB_ID)

echo $RESPONSE | jq .
