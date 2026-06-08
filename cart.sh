#!/bin/bash

cartID=$(id -u)
SCRIPT_DIR="$PWD"

if [ $cartID -ne 0 ]; then
    echo "Please run the script with root cart" | tee -a $LOG_FILE
    exit 1
    
fi

LOG_FOLDER="/var/logs/shell-cart"
LOG_FILE="/var/logs/shell-cart/$0.log"

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

    echo "roboshop cart is not present, creating now" | tee -a $LOG_FILE

    cartadd --system --home /app --shell /sbin/nologin --comment "roboshop system cart" roboshop
    validate $? "roboshop cart creation"
else
    echo "roboshop cart is already present, skipping cart creation" | tee -a $LOG_FILE
fi

mkdir -p /app &>> $LOG_FILE
validate $? "app directory creation"


curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip  &>> $LOG_FILE
validate $? "cart zip download"

cd /app  &>> $LOG_FILE
validate $? "app directory change"

rm -rf /app/* &>> $LOG_FILE
validate $? "app directory cleanup"

unzip /tmp/cart.zip &>> $LOG_FILE
validate $? "cart unzip"

npm install &>> $LOG_FILE
validate $? "cart npm install"

cp /$SCRIPT_DIR/cart.service /etc/systemd/system/cart.service &>> $LOG_FILE
validate $? "cart service file copy"

systemctl daemon-reload &>> $LOG_FILE
validate $? "systemd daemon reload"

systemctl enable cart &>> $LOG_FILE
validate $? "cart service enable"

systemctl start cart &>> $LOG_FILE
validate $? "cart service start"


