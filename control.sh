#!/bin/bash

# Configuration (ตั้งค่าที่นี่)
# Home Assistant URL
HA_URL="http://192.168.1.50:1234" 
# Long-Lived Access Token
HA_TOKEN="YOUR_LONG_LIVED_ACCESS_TOKEN" 
# Header สำหรับการอนุญาต (Authentication)
AUTH_HEADER="Authorization: Bearer $HA_TOKEN"
# Entity ID ของอุปกรณ์ไฟที่จะควบคุม
ENTITY_ID="light.living_room_lamp" 

# --- Functionality ---

# ฟังก์ชันสำหรับส่งคำสั่ง
send_command() {
    SERVICE=$1
    
    echo "Sending command to Home Assistant..."
    echo "Service: light.$SERVICE | Entity ID: $ENTITY_ID"

    # JSON Payload ที่ระบุ Entity ที่ต้องการควบคุม
    PAYLOAD="{\"entity_id\": \"$ENTITY_ID\"}"
    
    curl -s -X POST \
        -H "Content-Type: application/json" \
        -H "$AUTH_HEADER" \
        -d "$PAYLOAD" \
        "$HA_URL/api/services/light/$SERVICE" | jq '.'
    
    # jq (ถ้าติดตั้ง) จะช่วยจัดรูปแบบ JSON Output 
    # ถ้าไม่มี jq ให้ลบ | jq '.' ออก
}

# --- Main CLI Logic ---
case "$1" in
    on)
        send_command "turn_on"
        ;;
    off)
        send_command "turn_off"
        ;;
    status)
        echo "Retrieving status for $ENTITY_ID..."
        curl -s -X GET \
            -H "$AUTH_HEADER" \
            "$HA_URL/api/states/$ENTITY_ID" | jq '.state'
        ;;
    *)
        echo "Usage: $0 [on|off|status]"
        exit 1
        ;;
esac
