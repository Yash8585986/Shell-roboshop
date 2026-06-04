#!/bin/bash

USERID=$(id -u)

if [ $USERID -ne 0]; then
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

cp mongodb-repo /etc/yum.repos.d/mongo.repo
validate $? "Mongodb repo copy"

dnf install mongodb-org -y 
validate $? "Mongodb installation"

systemctl enable mongod 
validate $? "Mongodb enable"

systemctl start mongod
validate $? "Mongodb start"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
validate $? "Mongodb bind address change"
