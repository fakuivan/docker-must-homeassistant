#!/bin/bash

get_config () {
    jq -r --arg param "$1" '.[$param]' < /app/mqtt.json
}

MQTT_SERVER="$(get_config server)"
MQTT_PORT="$(get_config port)"
MQTT_TOPIC="$(get_config topic)"
MQTT_DEVICENAME="$(get_config devicename)"
MQTT_USERNAME="$(get_config username)"
MQTT_PASSWORD="$(get_config password)"

while read -r rawcmd;
do

    echo "Incoming request send: [$rawcmd] to inverter."
    # https://superuser.com/a/1627765/551612
    echo "$rawcmd" | xargs dotnet /app/inverter.dll set;

done < <(
    mosquitto_sub \
        -h "$MQTT_SERVER" \
        -p "$MQTT_PORT" \
        -u "$MQTT_USERNAME" \
        -P "$MQTT_PASSWORD" \
        -t "$MQTT_TOPIC/sensor/$MQTT_DEVICENAME" \
        -q 1
)
