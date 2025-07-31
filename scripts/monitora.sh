#!/bin/bash

LOG_FILE="/var/log/monitoramento.log"
TARGET_URL="http://localhost" # Monitore o site localmente
DISCORD_WEBHOOK_URL="seu_webhook"

HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" $TARGET_URL)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "[$TIMESTAMP] Site disponível (Status: $HTTP_STATUS)." | sudo tee -a $LOG_FILE
else
    MESSAGE="[$TIMESTAMP]-ERRO:Serviço indisponível! Código: $HTTP_STATUS em $(hostname)."
    echo "$MESSAGE" | sudo tee -a $LOG_FILE
    curl -H "Content-Type: application/json" -X POST -d '{"content": "'"$MESSAGE"'"}' $DISCORD_WEBHOOK_URL
fi
