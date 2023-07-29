#!/bin/sh

# Add the PHP 8.x repo
echo 'Updating repositories'
sudo apt update
echo 'Installing lsb-release'
sudo apt install -y lsb-release
echo 'Adding PHP 8.x repo'
curl https://packages.sury.org/php/apt.gpg | sudo tee /usr/share/keyrings/suryphp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/suryphp-archive-keyring.gpg] https://packages.sury.org/php/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/sury-php.list
echo 'Updating repositories'
sudo apt update
# Install Apache and PHP
echo 'Installing Apache2 and PHP8.2'
sudo apt install -y apache2 libapache2-mod-php php8.2 php8.2-cgi
# Empty contents of /var/www/html
echo 'Emptying the default contents of /var/www/html/'
sudo rm -rf /var/www/html/*
# Make directories
echo 'Making directories'
sudo mkdir /var/www/html/img/
sudo mkdir /var/www/sipisp/
sudo mkdir /var/www/sipisp/scripts/
# Move scripts
echo 'Copying scripts'
sudo cp ./sipisp/scripts/users.sh /var/www/sipisp/scripts/
sudo cp ./sipisp/scripts/network.sh /var/www/sipisp/scripts/
sudo cp ./sipisp/scripts/internet.sh /var/www/sipisp/scripts/
# Chmod scripts
echo 'Making scripts executable'
sudo chmod +x /var/www/sipisp/scripts/users.sh
sudo chmod +x /var/www/sipisp/scripts/network.sh
sudo chmod +x /var/www/sipisp/scripts/internet.sh
# Move web contents
echo 'Moving web contents'
sudo cp ./html/home.php /var/www/html/
sudo cp ./html/index.php /var/www/html/
sudo cp ./html/internet.php /var/www/html/
sudo cp ./html/menu.php /var/www/html/
sudo cp ./html/network.php /var/www/html/
sudo cp ./html/users.php /var/www/html/ 
sudo cp ./html/img/dialup.gif /var/www/html/img/
# Allow execution of scripts without password
file='/etc/sudoers'
line='www-data ALL=NOPASSWD /var/www/sipisp/scripts/*'
echo 'Allowing execution of scripts without password'
sudo echo $line >> $file

# sudo apt install -y mgetty ppp