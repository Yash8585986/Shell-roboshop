#!/bin/bash

USERID=$(id -u)

if [ $USERID -ne 0]; then
    echo "Please run the script with root or sudo user "
    exit 1
fi

dnf install rabbitmq-server -y

systemctl enable rabbitmq-server
systemctl start rabbitmq-server
