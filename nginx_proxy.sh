#!/bin/bash
sudo apt-get update
sudo apt-get install nginx
sudo unlink /etc/nginx/sites-enabled/default
sudo echo 'server {
    listen 80;
     location ^~ /jenkins/ {
          proxy_pass "http://192.168.49.2:32000/" ;
     }

     location ^~ /nexus/ {
          proxy_pass "http://192.168.49.2:32001/" ;
     }
}' > /etc/nginx/sites-available/reverse-proxy.conf
sudo ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf
sudo service nginx configtest
sudo service nginx restart
