echo Reading Connected App settings from Environment.env
export $(cat Environment.env | xargs)

echo Consumer Key: $CONSUMER_KEY
echo Client Secret: $CLIENT_SECRET
echo Redirect URI: $REDIRECT_URI

LOGIN_SITE="https://login.salesforce.com"
ACCESS_URL="$LOGIN_SITE/services/oauth2/authorize?client_id=$CONSUMER_KEY&redirect_uri=$REDIRECT_URI&response_type=code"
AUTH_URL=$LOGIN_SITE/services/oauth2/token



if [ -z "$REFRESH_TOKEN" ] 
then 
    echo "\nNo Refresh Token. Using Web Server Flow to get the Access Code"
    echo "Opening the browser to the login URL:\n\n$ACCESS_URL"

    open "$ACCESS_URL"
    echo "\n Listening for Callback..."
    ENCCODE=$(echo "OK" | nc -l 5555 | sed -nr 's/.*code=(.*) .*/\1/p')
    AUTH_CODE=$(printf '%b' "${ENCCODE//%/\\x}")
    echo Auth Code Received: $AUTH_CODE

    echo "\n Requesting Access Token..."
    echo Command:
    echo curl -s -d \"grant_type=authorization_code\" -d \"code=$AUTH_CODE\" -d \"client_id=$CONSUMER_KEY\" -d \"client_secret=$CLIENT_SECRET\" -d \"redirect_uri=$REDIRECT_URI\" -X POST $AUTH_URL
    RESPONSE=$(curl -s -d "grant_type=authorization_code" -d "code=$AUTH_CODE" -d "client_id=$CONSUMER_KEY" -d "client_secret=$CLIENT_SECRET" -d "redirect_uri=$REDIRECT_URI" -X POST $AUTH_URL)

    echo Response:
    echo $RESPONSE | jq .

    ACCESS_TOKEN=$(echo $RESPONSE | jq -r '.access_token')
    REFRESH_TOKEN=$(echo $RESPONSE | jq -r '.refresh_token')
    INSTANCE_URL=$(echo $RESPONSE | jq -r '.instance_url')


else
    echo "\nUsing Refresh Token"

    echo "\n Requesting Access Token..."
    echo Command:
    echo curl -s  -d \"grant_type=refresh_token\" -d \"client_id=$CONSUMER_KEY\" -d \"client_secret=$CLIENT_SECRET\" -d \"refresh_token=$REFRESH_TOKEN\" -X POST $AUTH_URL
    RESPONSE=$(curl -s -d "grant_type=refresh_token" -d "client_id=$CONSUMER_KEY" -d "client_secret=$CLIENT_SECRET" -d "refresh_token=$REFRESH_TOKEN" -X POST $AUTH_URL)
    echo Response:
    echo $RESPONSE | jq .

    ACCESS_TOKEN=$(echo $RESPONSE | jq -r '.access_token')
    INSTANCE_URL=$(echo $RESPONSE | jq -r '.instance_url')
fi

TOKEN_EXCHANGE_URL=$INSTANCE_URL/services/a360/token

echo "\n Requesting Data Cloud Token from $INSTANCE_URL...\n"
echo Command:
echo curl -s  -d \"grant_type=urn:salesforce:grant-type:external:cdp\" -d \"subject_token=$ACCESS_TOKEN\" -d \"subject_token_type=urn:ietf:params:oauth:token-type:access_token\" -X POST $TOKEN_EXCHANGE_URL

RESPONSE=$(curl -s  -d "grant_type=urn:salesforce:grant-type:external:cdp" -d "subject_token=$ACCESS_TOKEN" -d "subject_token_type=urn:ietf:params:oauth:token-type:access_token" -X POST $TOKEN_EXCHANGE_URL)

echo $RESPONSE | jq .

DATA_CLOUD_ACCESS_TOKEN=$(echo $RESPONSE | jq -r '.access_token')
DATA_CLOUD_ACCESS_TOKEN_EXPIRATION=$(echo $RESPONSE | jq -r '.expires_in')
DATA_CLOUD_URL=$(echo $RESPONSE | jq -r '.instance_url')


echo "\nTo store the tokens as an variable for subsequent access, copy/paste the following:\n\n"
echo export REFRESH_TOKEN=$REFRESH_TOKEN
echo export DATA_CLOUD_ACCESS_TOKEN=$DATA_CLOUD_ACCESS_TOKEN
echo export DATA_CLOUD_URL=$DATA_CLOUD_URL

