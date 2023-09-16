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
#file='/etc/sudoers'
#line="www-data ALL=(ALL) NOPASSWD: /var/www/sipisp/scripts/*.sh"
echo 'Allowing execution of scripts without password'
#sudo echo $line >> $file
sudo cat <<EOF >> /etc/sudoers
www-data ALL=(ALL) NOPASSWD: /var/www/sipisp/scripts/*.sh
EOF

# Setting up wlan0 to eth0 bridge
# https://www.youtube.com/watch?v=TtLNue7gzZA
echo "Installing dnsmasq"
sudo apt install dnsmasq
echo "Setting static IP for bridged eth0"
cat <<EOF >> /etc/dhcpcd.conf
interface eth0
static ip_address=192.168.4.1/24
EOF
echo "Backing up dnsmasq conf"
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
echo "Creating dnsmasq conf"
sudo touch /etc/dnsmasq.conf
cat <<EOF >> /etc/dnsmasq.conf
interface=eth0
dhcp-range=192.168.4.8,192.168.4.250,255.255.255.0,12h
EOF
echo "Allowing IPv4 forward"
sudo sed -i '/^#.*net.ipv4.ip_forward=1/s/^#//' /etc/sysctl.conf
echo "Adding iptables rule to /etc/rc.local"
sudo sed -i '/^exit 0.*/i iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE' /etc/rc.local

# Pass port 8080 to ethernet
echo "Creating virtual server on port 8080 for ATA passthrough"
cat <<EOF >> /etc/apache2/sites-available/000-default.conf
<VirtualHost *:8080>
    ProxyPreserveHost On
    ProxyPass / http://192.168.4.250/
    ProxyPassReverse / http://192.168.4.250/
</VirtualHost>
EOF
echo "Setting apache to listen on port 8080"
cat <<EOF >> /etc/apache2/ports.conf 
Listen 8080
EOF
echo "Restarting apache2"
sudo systemctl restart apache2.service

# Install mgetty and ppp
echo "Installing mgetty and ppp"
sudo apt install -y ppp mgetty
echo "Creating mgetty service"
sudo cat <<EOF >> /lib/systemd/system/mgetty.service
[Unit]
Description=External Modem
Documentation=man:mgetty(8)
Requires=systemd-udev-settle.service
After=systemd-udev-settle.service

[Service]
Type=simple
ExecStart=/sbin/mgetty /dev/ttyACM0
Restart=always
PIDFile=/var/run/mgetty.pid.ttyACM0

[Install]
WantedBy=multi-user.target
EOF
echo "Enabling and starting mgetty service"
sudo systemctl enable mgetty.service
sudo systemctl start mgetty.service

# Configure ppp
ehco "Backing up ppp options"
sudo mv /etc/ppp/options /etc/ppp/options.bak
touch /etc/ppp/options
sudo cat <<EOF >> /etc/ppp/options
ms-dns 8.8.8.8
asyncmap 0
auth
crtscts
lock
show-password
+pap
debug
lcp-echo-interval 30
lcp-echo-failure 4
proxyarp
noipx
EOF
touch /etc/ppp/options.ttyACM0
cat <<EOF >> /etc/ppp/options.ttyACM0
local
lock
nocrtscts
192.168.32.1:192.168.32.105
netmask 255.255.255.0
noauth
proxyarp
lcp-echo-failure 60
EOF

# Create the first user
echo "creating a dial in user with the username 'dial' and password 'dial'"
sudo useradd -G dialout,dip,users -m -g users -s /usr/sbin/pppd dial
sudo usermod --password $(echo "dial" | openssl passwd -1 -stdin) "dial"
sudo cat <<EOF >> /etc/ppp/pap-secrets
dial    *   "dial"  *
EOF
echo "Adding iptables rule to pass through to dial in"
sudo sed -i '/^exit 0.*/i iptables -t nat -A POSTROUTING -s 192.168.32.0/24 -o eth0 -j MASQUERADE' /etc/rc.local