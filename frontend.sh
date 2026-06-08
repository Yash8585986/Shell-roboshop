#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$(basename $0).log"      # FIX 1: basename
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.daws88s.online

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N"
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

# ── Check port 80 not already in use ──────────────────────────────
if ss -tlnp | grep -q ":80 "; then
    echo -e "$Y Port 80 already in use, stopping conflicting service... $N" | tee -a $LOGS_FILE
    systemctl stop httpd &>>$LOGS_FILE
fi

# ── Install Nginx ──────────────────────────────────────────────────
dnf module disable nginx -y &>>$LOGS_FILE
VALIDATE $? "Disable default nginx module"

dnf module enable nginx:1.24 -y &>>$LOGS_FILE
VALIDATE $? "Enable nginx 1.24 module"

dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "Installing Nginx"

# ── Copy config BEFORE starting ───────────────────────────────────
if [ ! -f "$SCRIPT_DIR/nginx.conf" ]; then                  # FIX 4: check file exists
    echo -e "nginx.conf not found in $SCRIPT_DIR ... $R FAILURE $N" | tee -a $LOGS_FILE
    exit 1
fi

rm -rf /etc/nginx/nginx.conf &>>$LOGS_FILE
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOGS_FILE
VALIDATE $? "Copied nginx.conf"

# ── Validate config syntax before starting ────────────────────────
nginx -t &>>$LOGS_FILE
VALIDATE $? "Nginx config syntax check"

# ── Enable and start ──────────────────────────────────────────────
systemctl enable nginx &>>$LOGS_FILE
systemctl start nginx &>>$LOGS_FILE                          # FIX 2: log output
VALIDATE $? "Enabled and started nginx"

# ── Deploy frontend ───────────────────────────────────────────────
rm -rf /usr/share/nginx/html/*
VALIDATE $? "Remove default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloaded frontend zip"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOGS_FILE
VALIDATE $? "Unzipped frontend"

# ── Restart with final config ─────────────────────────────────────
systemctl restart nginx &>>$LOGS_FILE
VALIDATE $? "Restarted Nginx"