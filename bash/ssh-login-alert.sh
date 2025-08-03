ssh_details=($SSH_CONNECTION)
  

curl -sX POST -d "Body=SSH Login from $ssh_details" \
    -d "From=${TWILIO__NUMBER}" -d "To=${PHONE}" \
    "https://api.twilio.com/2010-04-01/Accounts/${TWILIO__ID}/Messages" \
    -u "${TWILIO__ID}:${TWILIO__TOKEN}"
