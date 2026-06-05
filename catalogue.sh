#!/bin/bash

USERID=$(id -u)
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.ramyaboutique.shop

if [ $USERID -ne 0 ]; then
    echo "Please run the script with root user" | tee -a $LOG_FILE
    exit 1
    
fi

LOG_FOLDER="/var/logs/shell-mongodb"
LOG_FILE="/var/logs/shell-mongodb/$0.log"

mkdir -p $LOG_FOLDER

validate(){

if [ $1 -ne 0 ]; then
    echo "$2..failure" | tee -a $LOG_FILE
    exit 1
else
    echo "$2..success" | tee -a $LOG_FILE
fi

}

dnf module disable nodejs -y &>> $LOG_FILE
validate $? "Nodejs module disable"

dnf module enable nodejs:20 -y &>> $LOG_FILE
validate $? "Nodejs module enable"

dnf install nodejs -y &>> $LOG_FILE
validate $? "Nodejs installation"

id roboshop &>> $LOG_FILE

if [ $? -ne 0 ]; then

    echo "roboshop user is not present, creating now" | tee -a $LOG_FILE

    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "roboshop user creation"
else
    echo "roboshop user is already present, skipping user creation" | tee -a $LOG_FILE
fi

mkdir -p /app &>> $LOG_FILE
validate $? "app directory creation"


curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>> $LOG_FILE
validate $? "catalogue zip download"

cd /app  &>> $LOG_FILE
validate $? "app directory change"

rm -rf /app/* &>> $LOG_FILE
validate $? "app directory cleanup"

unzip /tmp/catalogue.zip &>> $LOG_FILE
validate $? "catalogue unzip"

npm install &>> $LOG_FILE
validate $? "catalogue npm install"

cp /$SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>> $LOG_FILE
validate $? "catalogue service file copy"

systemctl daemon-reload &>> $LOG_FILE
validate $? "systemd daemon reload"

systemctl enable catalogue &>> $LOG_FILE
validate $? "catalogue service enable"

systemctl start catalogue &>> $LOG_FILE
validate $? "catalogue service start"

cp /$SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE
validate $? "MongoDB repo file copy"

dnf install mongodb-mongosh -y &>> $LOG_FILE
validate $? "MongoDB shell installation"

mongosh --host $MONGODB_HOST </app/db/master-data.js