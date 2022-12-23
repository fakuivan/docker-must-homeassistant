#!/bin/bash
#
# Simple script to register the MQTT topics when the container starts for the first time...

get_config () {
    jq -r --arg param "$1" '.[$param]' < /app/mqtt.json
}

MQTT_SERVER="$(get_config server)"
MQTT_PORT="$(get_config port)"
MQTT_TOPIC="$(get_config topic)"
MQTT_DEVICENAME="$(get_config devicename)"
MQTT_USERNAME="$(get_config username)"
MQTT_PASSWORD="$(get_config password)"
MQTT_SERIAL_NO="$(get_config serial_number)"
CLIENT_ID="${MQTT_DEVICENAME}_${MQTT_SERIAL_NO}"

# Splits arguments pairwise and interprets them as key: value to put
# them into a json dict
pairs_to_dict () {
    jq -r '.*([
        range(($ARGS.positional | length) / 2 | floor) | .*2 |
        {"key": ($ARGS.positional[.]), "value": $ARGS.positional[.+1]}
    ] | from_entries)' --args "$@"
}

DEVICE="{ \"device\": $(echo '{}' | pairs_to_dict \
    name "$MQTT_DEVICENAME" \
    ids  "$MQTT_SERIAL_NO"
)}"

registerTopic () {
    mosquitto_pub \
        -h "$MQTT_SERVER" \
        -p "$MQTT_PORT" \
        -u "$MQTT_USERNAME" \
        -P "$MQTT_PASSWORD" \
        -i "$CLIENT_ID" \
        -t "$MQTT_TOPIC/sensor/$CLIENT_ID/_$1/config" \
        -m "$(echo "$DEVICE" | pairs_to_dict \
            name                "${MQTT_DEVICENAME}_$1" \
            unique_id           "${MQTT_SERIAL_NO}_$1" \
            unit_of_measurement "$2" \
            state_topic         "$MQTT_TOPIC/sensor/$CLIENT_ID/_$1" \
            icon                "mdi:$3"
        )"
}

registerInverterRawCMD () {
    mosquitto_pub \
        -h "$MQTT_SERVER" \
        -p "$MQTT_PORT" \
        -u "$MQTT_USERNAME" \
        -P "$MQTT_PASSWORD" \
        -i "$CLIENT_ID" \
        -t "$MQTT_TOPIC/sensor/$CLIENT_ID/COMMANDS/config" \
        -m "$(echo "$DEVICE" | pairs_to_dict \
            name        "${MQTT_DEVICENAME}_COMMANDS" \
            unique_id   "${MQTT_SERIAL_NO}" \
            state_topic "$MQTT_TOPIC/sensor/$CLIENT_ID/COMMANDS"
        )"
}

registerTopic   "WorkStateNo"                              ""                 "state-machine"
registerTopic   "AcVoltageGrade"                           "Vac"              "current-ac"
registerTopic   "RatedPower"                               "VA"               "lightbulb-outline"
registerTopic   "BatteryVoltage"                           "Vdc-batt"         "current-dc"
registerTopic   "InverterVoltage"                          "Vac"              "current-ac"
registerTopic   "GridVoltage"                              "Vac"              "current-ac"
registerTopic   "BusVoltage"                               "Vdc/Vac"          "cog-transfer-outline"
registerTopic   "ControlCurrent"                           "Aac"              "current-ac"
registerTopic   "InverterCurrent"                          "Aac"              "current-ac"
registerTopic   "GridCurrent"                              "Aac"              "current-ac"
registerTopic   "LoadCurrent"                              "Aac"              "current-ac"
registerTopic   "PInverter"                                "W"                "cog-transfer-outline"
registerTopic   "PGrid"                                    "W"                "transmission-tower"
registerTopic   "PLoad"                                    "W"                "lightbulb-on-outline"
registerTopic   "LoadPercent"                              "%"                "progress-download"
registerTopic   "SInverter"                                "VA"               "cog-transfer-outline"
registerTopic   "SGrid"                                    "VA"               "transmission-tower"
registerTopic   "SLoad"                                    "VA"               "lightbulb-on-outline"
registerTopic   "QInverter"                                "Var"              "cog-transfer-outline"
registerTopic   "QGrid"                                    "Var"              "transmission-tower"
registerTopic   "QLoad"                                    "Var"              "lightbulb-on-outline"
registerTopic   "InverterFrequency"                        "Hz"               "sine-wave"
registerTopic   "GridFrequency"                            "Hz"               "sine-wave"
registerTopic   "InverterMaxNumber"                        ""                 "format-list-numbered"
registerTopic   "CombineType"                              ""                 "format-list-bulleted-type"
registerTopic   "InverterNumber"                           ""                 "format-list-numbered"
registerTopic   "AcRadiatorTemp"                           "oC"               "thermometer"
registerTopic   "TransformerTemp"                          "oC"               "thermometer"
registerTopic   "DcRadiatorTemp"                           "oC"               "thermometer"
registerTopic   "InverterRelayStateNo"                     ""                 "electric-switch"
registerTopic   "GridRelayStateNo"                         ""                 "electric-switch"
registerTopic   "LoadRelayStateNo"                         ""                 "electric-switch"
registerTopic   "NLineRelayStateNo"                        ""                 "electric-switch"
registerTopic   "DcRelayStateNo"                           ""                 "electric-switch"
registerTopic   "EarthRelayStateNo"                        ""                 "electric-switch"
registerTopic   "Error1"                                   ""                 "alert-circle-outline"
registerTopic   "Error2"                                   ""                 "alert-circle-outline"
registerTopic   "Error3"                                   ""                 "alert-circle-outline"
registerTopic   "Warning1"                                 ""                 "alert-outline"
registerTopic   "Warning2"                                 ""                 "alert-outline"
registerTopic   "BattPower"                                "W"                "car-battery"
registerTopic   "BattCurrent"                              "Adc"              "current-dc"
registerTopic   "BattVoltageGrade"                         "Vdc-batt"         "current-dc"
registerTopic   "RatedPowerW"                              "W"                "certificate"
registerTopic   "CommunicationProtocalEdition"             ""                 "barcode"
registerTopic   "ArrowFlag"                                ""                 "state-machine"
registerTopic   "ChrWorkstateNo"                           ""                 "state-machine"
registerTopic   "MpptStateNo"                              ""                 "electric-switch"
registerTopic   "ChargingStateNo"                          ""                 "electric-switch"
registerTopic   "PvVoltage"                                "Vdc-pv"           "current-dc"
registerTopic   "ChrBatteryVoltage"                        "Vdc-batt"         "current-dc"
registerTopic   "ChargerCurrent"                           "Adc"              "current-dc"
registerTopic   "ChargerPower"                             "W"                "car-turbopower"
registerTopic   "RadiatorTemp"                             "oC"               "thermometer"
registerTopic   "ExternalTemp"                             "oC"               "thermometer"
registerTopic   "BatteryRelayNo"                           ""                 "electric-switch"
registerTopic   "PvRelayNo"                                ""                 "electric-switch"
registerTopic   "ChrError1"                                ""                 "alert-circle-outline"
registerTopic   "ChrWarning1"                              ""                 "alert-outline"
registerTopic   "BattVolGrade"                             "Vdc-batt"         "current-dc"
registerTopic   "RatedCurrent"                             "Adc"              "current-dc"
registerTopic   "AccumulatedDay"                           "day"              "calendar-day"
registerTopic   "AccumulatedHour"                          "hour"             "clock-outline"
registerTopic   "AccumulatedMinute"                        "min"              "timer-outline"

# Manually added
registerTopic   "ChargerSourcePriority"                    ""                 "state-machine"
registerTopic   "SolarUseAim"                              ""                 "state-machine"
registerTopic   "EnergyUseMode"                            ""                 "state-machine"
registerTopic   "BatteryStopDischargingVoltage"            "Vdc-batt"         "current-dc"
registerTopic   "BatteryStopChargingVoltage"               "Vdc-batt"         "current-dc"
registerTopic   "BatteryLowVoltage"                        "Vdc-batt"         "current-dc"
registerTopic   "BatteryHighVoltage"                       "Vdc-batt"         "current-dc"

# Register composite topics manually for now

registerTopic "BatteryPercent"                             "%"       "battery"

registerTopic "AccumulatedChargerPower"                    "KWH"     "chart-bell-curve-cumulative"
registerTopic "AccumulatedDischargerPower"                 "KWH"     "chart-bell-curve-cumulative"
registerTopic "AccumulatedBuyPower"                        "KWH"     "chart-bell-curve-cumulative"
registerTopic "AccumulatedSellPower"                       "KWH"     "chart-bell-curve-cumulative"
registerTopic "AccumulatedLoadPower"                       "KWH"     "chart-bell-curve-cumulative"
registerTopic "AccumulatedSelfusePower"                    "KWH"     "chart-bell-curve-cumulative"
registerTopic "AccumulatedPvsellPower"                     "KWH"     "chart-bell-curve-cumulative"
registerTopic "AccumulatedGridChargerPower"                "KWH"     "chart-bell-curve-cumulative"
registerTopic "AccumulatedPvPower"                         "KWH"     "chart-bell-curve-cumulative"

# Register topic for push commands
registerInverterRawCMD
