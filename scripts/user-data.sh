#!/bin/bash
### Get the latest bug fixes and security updates by updating the software on your EC2 instance
yum update -y
### Install Apache Websever
yum install httpd -y
### Start the web server
systemctl start httpd
### Configure the web server to start with each system boot
systemctl enable httpd
echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
echo "<h2>You have successfully hit your EC2 instance from either your ALB or CloudFront distribution!</h2>" >> /var/www/html/index.html