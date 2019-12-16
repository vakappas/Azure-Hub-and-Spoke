# These actions will be run at provisioning time

# Install Apache and PHP
sudo apt-get update
sudo apt-get install apache2 -y
sudo apt-get install php libapache2-mod-php php-mcrypt php-mysql -y
sudo systemctl restart apache2

# Delete default web site and download a new one
sudo rm /var/www/html/index.html
sudo apt-get install wget -you
sudo wget https://raw.githubusercontent.com/erjosito/AzureBlackMagic/master/index.php -P /var/www/html/
sudo wget https://raw.githubusercontent.com/erjosito/AzureBlackMagic/master/styles.css -P /var/www/html/
sudo wget https://raw.githubusercontent.com/erjosito/AzureBlackMagic/master/apple-touch-icon.png -P /var/www/html/
sudo wget https://raw.githubusercontent.com/erjosito/AzureBlackMagic/master/favicon.ico -P /var/www/html/


 #assign static IP and change default gw to LISP Router for Intra-Subnet communication across sites:

#cd /etc/network/interfaces.d
#sudo nano 50-cloud-init.cfg

#auto eth0
#iface eth0 inet static
#        address 10.100.100.101
#        netmask 255.255.255.255
#        gateway 10.100.100.4


