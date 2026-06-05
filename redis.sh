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

dnf module disable redis -y &>> $LOG_FILE
validate $? "Redis module disable"

dnf module enable redis:7 -y &>> $LOG_FILE
validate $? "Redis module enable"

dnf install redis -y &>> $LOG_FILE
validate $? "Redis installation"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e 's/protected-mode yes/protected-mode no/g' /etc/redis/redis.conf &>> $LOG_FILE
validate $? "Redis bind address change"

systemctl enable redis &>> $LOG_FILE
validate $? "Redis enable"

systemctl start redis &>> $LOG_FILE
validate $? "Redis start"

    