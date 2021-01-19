#! /bin/bash
node /web/api/mqttpasswd.js
mosquitto_passwd -U /etc/mosquitto/password.txt
systemctl restart mosquitto

