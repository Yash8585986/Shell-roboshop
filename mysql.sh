#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"

if [ $USERID -ne 0 ]; then
    echo "Please run the script with root user" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

validate(){

if [ $1 -ne 0 ]; then
    echo "$2..failure" | tee -a $LOG_FILE
    exit 1
else
    echo "$2..success" | tee -a $LOG_FILE
fi

}

dnf install mysql-server -y &>> $LOGS_FILE
validate $? "mysql-server"

systemctl enable mysqld   &>> $LOGS_FILE
validate $? "mysql-server enable"

systemctl start mysqld  &>> $LOGS_FILE
validate $? "mysql-server start"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGS_FILE
validate $? "mysql_secure_installation"