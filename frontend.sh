#!/bin/bash

USER_ID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOG_FOLDER/$0.log"


if [ $? -ne 0 ]; then
    echo "Please try with root user"
    exit 1
fi

mkdir -p $LOG_FOLDER

validate(){
    if [ $1 -ne 0 ]; then
        echo "$2 Intallation failed"
    else
        echo "$2 Installation successfull"
    fi
}

dnf module disable nginx -y
dnf module enable nginx:1.24 -y
dnf install nginx -y

rm -rf /usr/share/nginx/html/* 

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip

rm -rf /etc/nginx/nginx.conf

cp /$SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
validate $? "Copied our nginx conf file"



systemctl enable nginx 
systemctl start nginx 


systemctl restart nginx
validate $? "Restarted Nginx"
