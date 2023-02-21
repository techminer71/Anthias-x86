#!/bin/bash

IS_CONNECTED=''

if [[ ! -z $CHECK_CONN_FREQ ]]
    then
        freq=$CHECK_CONN_FREQ
    else
        freq=120
fi


sleep 5

while [[ "$IS_CONNECTED" != 'true' ]]; do
    if [[ "$VERBOSE" != 'false' ]]; then echo "Checking internet connectivity ..."; fi
    wget --spider --no-check-certificate 1.1.1.1 > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        if [[ "$VERBOSE" != 'false' ]]; then
            echo "Your device is already connected to the internet."
            echo "Skipping setting up Wifi-Connect Access Point."
        fi

        if [[ "$IS_CONNECTED" = 'false' ]]; then
            python send_zmq_message.py --action='show_splash'
        fi

        IS_CONNECTED='true'
        exit 0
    else
        if [[ "$VERBOSE" != 'false' ]]; then
            echo "Your device is not connected to the internet."
            echo "Starting up Wifi-Connect."
            echo "Connect to the Access Point and configure the SSID and Passphrase for the network to connect to."
        fi

        if [[ "$IS_CONNECTED" = 'true' ]] || [[ "$IS_CONNECTED" = '' ]]; then
            python send_zmq_message.py --action='setup_wifi'
        fi

        IS_CONNECTED='false'

        /usr/src/app/wifi-connect -u /usr/src/app/ui
    fi

    sleep $freq
done
