#!/bin/bash

USERID=$(id -u)
LOG_FOLDER="/var/log/shell-scripts"
LOG_FILE="$LOG_FOLDER/$0.sh"
SCRIPT_DIR="$PWD"

if [ $USERID -ne 0]; then
    echo "Please run the script with root or sudo user "
    exit 1
fi

validate (){
    if [ $1 -ne 0 ]; then
        echo "$2 installation is failed"
    else
        echo "$2 installation is success"
    fi
}

cp /SCRIPT_DIR/rabbitmq.rep0 /etc/yum.repos.d/rabbitmq.repo
validate $? "added rabbitmq repo"

dnf install rabbitmq-server -y &>> $LOG_FILE
validate $? "rabbitmq-server"

rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

systemctl enable rabbitmq-server &>> $LOG_FILE
validate $? "Enable rabbitmq"

systemctl start rabbitmq-server &>> $LOG_FILE
validate $? "Starting rabbitmq"

