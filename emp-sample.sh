#!/bin/bash

# SEE https://github.com/forcedotcom/EMP-Connector/ for setup instructions

## Update with your specific settings
USER="YOUR USERNAME HERE"
LOGIN_URL=https://test.salesforce.com #Replace with custom domain if needed

## DO NOT MODIFY BELOW THIS LINE
TOPIC=/event/ACMN_Error_Log_PE__e

read -s -p "Password for $USER: " PASS
printf " \n"
read -p "Replay ID [optional]: " REPLAY_ID

javacmd="java -classpath EMP-Connector/target/emp-connector-0.0.1-SNAPSHOT-phat.jar com.salesforce.emp.connector.example.DevLoginExample $LOGIN_URL $USER ****** $TOPIC $REPLAY_ID"
echo -e "\nRunning: $javacmd `echo $'\n\n '`"

java -classpath EMP-Connector/target/emp-connector-0.0.1-SNAPSHOT-phat.jar com.salesforce.emp.connector.example.DevLoginExample $LOGIN_URL $USER $PASS $TOPIC $REPLAY_ID