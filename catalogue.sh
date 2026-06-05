#!/bin/bash

USERID=$(id -u)

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

dnf module disable nodejs -y
validate $? "Nodejs module disable"

dnf module enable nodejs:20 -y
validate $? "Nodejs module enable"

dnf install nodejs -y
validate $? "Nodejs installation"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "roboshop user creation"

mkdir /app 
validate $? "app directory creation"


curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
validate $? "catalogue zip download"