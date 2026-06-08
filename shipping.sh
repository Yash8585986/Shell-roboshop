#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-scripts"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR="$PWD"
MYSQL_HOST=mysql.ramyaboutique.shop

mkdir -p $LOGS_FOLDER

if [ $USERID -ne 0 ]; then
    echo "Please run the script with root or sudo"
    exit 1
fi

validate() {
if [ $1 -ne 0 ]; then
    echo "Installation of $2 failed"
    exit 1
else 
    echo "Installation of $2 successful"
fi
}

dnf install maven -y &>> $LOGS_FILE
validate $? "maven"

id roboshop

if [ $? -ne 0 ]; then

    echo " Creating roboshop user"

    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop    
    validate $? "roboshop user creation"

else
    echo "roboshop user already exists..skipping user creation"

fi

mkdir -p /app 
validate $? "app directory creation"


curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>> $LOG_FILE
validate $? "shipping zip download"

cd /app  &>> $LOG_FILE
validate $? "app directory change"

rm -rf /app/* &>> $LOG_FILE
validate $? "app directory cleanup"

unzip /tmp/shipping.zip &>> $LOG_FILE
validate $? "shipping unzip"

cd /app &>> $LOG_FILE

mvn clean package  &>> $LOG_FILE
validate $? "shipping maven build"

mv target/shipping-1.0.jar shipping.jar
validate $? "moving code " 


cp /$SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>> $LOG_FILE
validate $? "shipping service file copy"

dnf install mysql -y  &>> $LOG_FILE
validate $? "mysql install"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql 
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql


systemctl daemon-reload &>> $LOG_FILE
validate $? "systemd daemon reload"

systemctl enable shipping &>> $LOG_FILE
validate $? "shipping service enable"

systemctl start shipping &>> $LOG_FILE
validate $? "shipping service start"