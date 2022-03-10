#!/bin/bash
# Script to deploy a very simple web application.
# The web app has a customizable image and some text.

apt -y update
apt -y install apache2
systemctl start apache2

cat << EOM > /var/www/html/index.html
<html>
  <head><title>Networking DU</title></head>
  <body>
  <div style="width:800px;margin: 0 auto">
  <!-- BEGIN -->
    <center><h2>Fellow Network Engineers </h2></center>
  <center>Welcome to the LABTIME Session 3!=^._.^=</center>
  <!-- END -->
  
  </div>
  </body>
</html>
EOM

echo "Script complete."