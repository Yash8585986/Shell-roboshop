#!/bin/bash

USERID=$(id -u)
LOG_FOLDER="/var/log/shell-scripts"
LOG_FILE="$LOG_FOLDER/$0.log"
SCRIPT_DIR="$PWD"

if [ $? -ne 0 ]; then
    echo "Please run the script with root or sudo user"
    exit 1
fi

mkdir -p $LOG_FOLDER

validate(){
    if [ $1 -ne 0 ]; then
        echo "$2 istallation is failed"
    else
        echo "$2 installation is success"
    fi
}

dnf install python3 gcc python3-devel -y &>> $LOG_FILE
validate $? "Python installation"

id roboshop

if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else 
    echo "user already exist....skipping"
fi

mkdir -p /app

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
validate $? "Downloading payment code"

cd /app
validate $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/payment.zip
validate $? "Unzip payment code"

cd /app 
pip3 install -r requirements.txt &>>$LOGS_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Created systemctl service"

systemctl daemon-reload
systemctl enable payment 

systemctl start payment
VALIDATE $? "Enabled and started payment"

