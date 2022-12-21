#!/bin/bash

# ###########################################
# ###########################################
#
# BTCLOTO BITCOIN MINER ON RPI 4
# by Michel de Geofroy
# 
# This script is intended as a basic set up 
# & should be run on a clean install of
# Raspberry Pi OS Lite (64-bit) Debian Bullseye
# Using Raspberry Pi Imager for use on a RPI 4
#
# ###########################################
# ###########################################
#
#
#ssh into your pi
#ssh pi@YOURDEVICEIP 
#
#If you get this msg
#
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
#Someone could be eavesdropping on you right now (man-in-the-middle attack)!
#It is also possible that a host key has just been changed.
#The fingerprint for the ECDSA key sent by the remote host is
#
# Use this below command and ssh again
#
#ssh-keygen -R YOURDEVICEIP
#
#nano install.sh
#
#copy this code in file save and close (ctrl X , y , return)
#
# ###############################
# Set root password
# ###############################
#
#Then create a root password
#sudo passwd root
#
#
# ###############################
# This needs to be run as root !
# ###############################
#
#
#su
#
#
# ###############################
# Execute basic install
# ###############################
#
#bash install.sh
#
# ###############################
# Update the software sources
# ###############################

apt update -y
apt upgrade -y

# ###############################
# Fix Language Local
# ###############################

#Start Install

touch /etc/environment

echo "LANGUAGE=en_US" >> /etc/environment
echo "LC_ALL=en_US" >> /etc/environment
echo "LANG=en_US" >> /etc/environment
echo "LC_TYPE=en_US" >> /etc/environment

touch /etc/default/locale

echo "LANG=en_US.UTF-8" >> /etc/default/locale
echo "LC_CTYPE=en_US.UTF-8" >> /etc/default/locale
echo "LC_MESSAGES=en_US.UTF-8" >> /etc/default/locale
echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale

localedef -f UTF-8 -i en_US en_US.UTF-8 

sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/en_GB.UTF-8 UTF-8/# en_GB.UTF-8 UTF-8/g' /etc/locale.gen 



# ###############################
# Web Interface
# ###############################

apt install php7.4 -y

sudo apt-get purge apache2 -y
sudo apt-get purge php7.4 libapache2-mod-php7.4 -y
sudo apt-get purge autoremove -y
sudo apt-get install apache2 libapache2-mod-php7.4 php7.4 -y

wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/index.php -P /var/www/html/

wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/miner.php -P /var/www/html/

# ###############################
# Install Tailscale
# ###############################

#Start Install

apt install apt-transport-https

curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

apt update -y
apt install tailscale -y

#tailscale up


# ###############################
# Disable Swap
# ###############################

#Clean Up

#swapon --all
#apt install dphys-swapfile -y

#Start Install

swapoff --all
apt remove dphys-swapfile -y

# ###############################
# Install glances
# ###############################

#Clean Up

#pip uninstall glances -y
#apt purge python3-pip -y

#Start Install

apt install python3-pip -y
pip install glances

# ###############################
# Install Speed Test
# ###############################

#Start Install

wget -O /usr/local/bin/speedtest-cli https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/speedtest.py
chmod a+x /usr/local/bin/speedtest-cli

# ###############################
# Install watchdog
# ###############################

#Start Install

echo '#Watchdog On' >> /boot/config.txt
echo 'dtparam=watchdog=on' >> /boot/config.txt

apt install watchdog -y

echo 'watchdog-device = /dev/watchdog' >> /etc/watchdog.conf
echo 'watchdog-timeout = 15' >> /etc/watchdog.conf
echo 'max-load-1 = 24' >> /etc/watchdog.conf

systemctl enable watchdog
systemctl start watchdog
systemctl status watchdog

# ###############################
# Stop IPV6
# ###############################

#Start Install

echo net.ipv6.conf.all.disable_ipv6=1 | sudo tee /etc/sysctl.d/disable-ipv6.conf
sysctl --system
sed -i -e 's/$/ipv6.disable=1/' /boot/cmdline.txt

# ###############################
# Disable BT
# ###############################

#Start Install

echo '# Disable Bluetooth' >> /boot/config.txt
echo 'dtoverlay=disable-bt' >> /boot/config.txt

systemctl disable hciuart.service 
systemctl disable bluetooth.service


# ###############################
# Install macchanger
# ###############################

#Start Install

touch /home/pi/mymacchanger.py

echo 'import random' >> /home/pi/mymacchanger.py
echo 'import subprocess' >> /home/pi/mymacchanger.py
echo 'random_mac = [random.randint(0x00, 0xff) for _ in range(6)]' >> /home/pi/mymacchanger.py
echo "new_mac = ':'.join(map(lambda x: '%02x' % x, random_mac))" >> /home/pi/mymacchanger.py
echo 'subprocess.call("ifconfig wlan0 down", shell=True)' >> /home/pi/mymacchanger.py
echo 'subprocess.call("ifconfig wlan0 hw ether " + new_mac, shell=True)' >> /home/pi/mymacchanger.py
echo 'subprocess.call("ifconfig wlan0 up", shell=True)' >> /home/pi/mymacchanger.py
echo 'print("New Mac address: " + new_mac)' >> /home/pi/mymacchanger.py

touch /var/spool/cron/root
/usr/bin/crontab /var/spool/cron/root
echo "*/180 * * * * /usr/bin/python3 /home/pi/mymacchanger.py" >> /var/spool/cron/root


# ###############################
# Install telegram bot
# ###############################

#Clean Up

#apt purge jq -y
#apt purge python3-pip -y
#pip uninstall telepot -y
#rm -r /home/pi/Bots
#systemctl stop bot.services
#rm -r /etc/systemd/system/bot.service
#systemctl disable bot.service
#systemctl daemon-reload

#Start Install
                                                                                                                                                             
apt install jq -y
apt install python3-pip -y
pip install telepot

wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/script.py

python3 script.py

rm script.py

mkdir /home/pi/Bots/

wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/Bot.py -P /home/pi/Bots/


wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/bot.service -P /etc/systemd/system/

pip3 install --upgrade RPi.GPIO

systemctl enable bot.service
systemctl start bot.service

# ###############################
# Heartbeat Telegram
# ###############################

#Clean Up

#sed -i '1d' /var/spool/cron/root
#sed -i '2d' /var/spool/cron/root
#sed -i '3d' /var/spool/cron/root

#Start Install

echo -e '30 8 * * * curl -s -X POST https://api.telegram.org/bot5564114282:AAGSjjJkjNH7RB-4dUH-aJW1pMmquFEq-m8/sendMessage -d chat_id=90423887 -d text="BTC Loto is Alive !"' >> /var/spool/cron/root

# ###############################
# SSH Custom Login Splash Screen
# ###############################

#Clean Up

#rm /etc/motd

#Start Install

touch /etc/motd

echo ' ' >> /etc/motd
echo 'GENERAL DEBUG' >> /etc/motd
echo 'sudo nano /var/log/messages' >> /etc/motd
echo 'sudo nano /var/log/kern.log' >> /etc/motd
echo 'sudo nano /var/log/syslog' >> /etc/motd
echo 'sudo tail -n 100 -f /var/log/syslog' >> /etc/motd
echo 'sudo tail -n 100 -f /var/log/messages' >> /etc/motd
echo 'sudo journalctl -xe' >> /etc/motd
echo '  ' >> /etc/motd
echo 'BOT' >> /etc/motd
echo 'sudo systemctl stop bot.service' >> /etc/motd
echo 'sudo systemctl restart bot.service' >> /etc/motd
echo 'sudo systemctl status bot.service' >> /etc/motd
echo 'sudo systemctl daemon-reload' >> /etc/motd
echo 'sudo systemctl enable bot.service' >> /etc/motd
echo 'sudo systemctl start bot.service' >> /etc/motd
echo 'sudo nano /Bots/Bot.py' >> /etc/motd
echo '  ' >> /etc/motd
echo 'BTC' >> /etc/motd
echo 'sudo tail -n 100 -f /mnt/hdd/debug.log' >> /etc/motd
echo 'bitcoin-cli getblockchaininfo' >> /etc/motd
echo '  ' >> /etc/motd
echo 'OTHER' >> /etc/motd
echo 'To reload this Splash Screen: sudo run-parts --lsbsysinit /etc/update-motd.d' >> /etc/motd
echo 'To edit the Web Monitor script: sudo nano /var/www/html/index.php' >> /etc/motd
echo 'To edit the Login Welcome script: sudo nano /etc/update-motd.d/20-raspberry-bitcoin' >> /etc/motd
echo 'To launch Glances: glances' >> /etc/motd
echo 'To Add to this splash screen edit with sudo nano  /etc/motd' >> /etc/motd
echo '  ' >> /etc/motd

# ###############################
# SSH Welcome Interface
# ###############################

#Clean Up

#rm -r /etc/update-motd.d/20-raspberry-bitcoin
#rm -r /etc/update-motd.d/30-swap-warning
#apt purge jq -y

#Start Install

#apt install -y jq

wget -qO- https://gist.githubusercontent.com/meeDamian/0006c766340e0afd16936b13a0c7dbd8/raw/3b7ea819617f645ca4675f7351df70d1622863bd/na%25C3%25AFve-rbp-btc.sh | sudo sh

sudo chmod +x /etc/update-motd.d/20-raspberry-bitcoin
rm -r /etc/update-motd.d/20-raspberry-bitcoin
touch /etc/update-motd.d/20-raspberry-bitcoin

echo '#!/bin/bash' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "ram_total=\u0024(free -m | grep Mem | awk '{ print \u00242 }')" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "ram_total=\u0024(free -m | grep Mem | awk '{ print \u00242 }')" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "ram_avail=\u0024(free -m | grep Mem | awk '{ print \u00247 }')" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "ram_used=\u0024(free -m | grep Mem | awk '{ print \u00243 }')" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "ram_Xused=\u0024(echo \u0024{ram_used} \u0024{ram_total}| awk '{print \u00241 / \u00242 *100}' | sed 's/\.[^[:blank:]]*//')" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "hdd_total=\u0024(df -h | grep '\u002F\u0024' | awk '{ print \u00242 }')" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "hdd_free=\u0024(df -h | grep '\u002F\u0024' | awk '{ print \u00244 }')" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "hdd_used=\u0024(df -h | grep '\u002F\u0024' | awk '{ print \u00243 }')" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "hdd_Xused=\u0024(df -h | grep '\u002F\u0024' | awk '{ print \u00245 }')" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "ram_swap=\u0024(free -m | grep Swap | awk '{ print \u00243 }')" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "external_storage=\u0024(df -h | grep '/dev/sd')" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'if [ ! -z "\u0024{external_storage}" ]; then' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "external_total=\u0024(echo \u0024{external_storage} | awk '{ print \u00242 }')" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "external_avail=\u0024(echo \u0024{external_storage} | awk '{ print \u00243 }')" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'external_Xused=\u0024(df -h | grep "/dev/sd" | awk \u0027{print\u00245}\u0027)' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'external_info="EXTERNAL STORAGE: \u0024{BOLD}\u0024{external_avail} / \u0024{external_total} \u0024{external_Xused} \u0024{RESET_STYLE}"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "else" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'external_info=\u0024(echo "EXTERNAL STORAGE: N/A ")' >> /etc/update-motd.d/20-raspberry-bitcoin
echo "fi" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "swap_check=\u0024(free -mh | grep -i swap | awk '{print substr(\u00242, 1,1)}')" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "swap_memory=\u0024(free -mh | grep -i swap)" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "swap_total=\u0024(echo \u0024{swap_memory} | awk '{print substr(\u00242, 1, length(\u00242) - 2)}')" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'if [ "\u0024{swap_check}" != "0" ]; then' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'swap_info="SWAP: \u0024{BOLD}\u0024{ram_swap}M / \u0024{swap_total}G\u0024{RESET_STYLE}"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo "else" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'swap_info="\u0024(tput -T xterm setaf 2)SWAP: N/A"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo "fi" >> /etc/update-motd.d/20-raspberry-bitcoin  
echo -e 'GEOLOC="\u0024(curl https://extreme-ip-lookup.com/json/?key=ACJdcEKqljZrmlXp1GZA)"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'geoloc=\u0022\u0024(echo \u0024{GEOLOC} | jq -r \u0027.country\u0027 | tr \u0027[:lower:]\u0027 \u0027[:upper:]\u0027)\u0022' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "geoloc=\u0022\u0024(echo \u0024{GEOLOC} | jq -r \u0027.country\u0027 | tr \u0027[:lower:]\u0027 \u0027[:upper:]\u0027)\u0022" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "RPI=\u0022\u0024(tr -d '\0' < /proc/device-tree/model)\u0022" >> /etc/update-motd.d/20-raspberry-bitcoin  
echo -e "rpimod=\u0022\u0024(echo \u0024{RPI} | tr '[:lower:]' '[:upper:]')\u0022" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "TIME=\u0022\u0024(uptime | sed 's/.*up \([^,]*\), .*/\1/')\u0022" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'uptime="\u0024(echo \u0024{TIME})"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "GHZ=\u0022\u0024(vcgencmd measure_clock arm | awk ' BEGIN { FS=\u0022=\u0022 } ; { printf(\u0022%.1fGHz\u005C\u006E\u0022, \u00242 / 1000000000) } ')\u0022" >> /etc/update-motd.d/20-raspberry-bitcoin  
echo -e 'ghz="\u0024(echo \u0024{GHZ})"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "VOLTS=\u0022\u0024(vcgencmd measure_volts \u0024id | awk '{print substr(\u00240, 6, length(\u00240) - 9)} ')\u0022" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'volts="\u0024(echo \u0024{VOLTS})"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'PUBIP="\u0024(curl ifconfig.co)"' >> /etc/update-motd.d/20-raspberry-bitcoin  
echo -e 'pubip="\u0024(echo \u0024{PUBIP})"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'IP="\u0024(hostname -I)"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'ip="\u0024(echo \u0024{IP})"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "TEMPCPU=\u0022\u0024(awk '{printf(\u0022\u005C\u006E%.1f°C\u005C\u006E\u005C\u006E\u0022,\u00241/1e3)}' /sys/class/thermal/thermal_zone0/temp)\u0022" >> /etc/update-motd.d/20-raspberry-bitcoin  
echo -e 'temp="\u0024(echo \u0024{TEMPCPU})"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "CPUUSED=\u0022\u0024(vmstat 1 2 | tail -1 | awk '{print \u002413}')\u0022" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'cpuused=\u0022\u0024(echo \u0024{CPUUSED})\u0022' >> /etc/update-motd.d/20-raspberry-bitcoin
echo 'data_dir="/mnt/hdd/bitcoin"' >> /etc/update-motd.d/20-raspberry-bitcoin    
echo -e "btc_path=\u0024(command -v bitcoin-cli)" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "if [ ! -z \u0024{btc_path} ]; then" >> /etc/update-motd.d/20-raspberry-bitcoin
echo 'btc_line1="BITCOIN CORE"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'BLOCKCHAIN_INFO="\u0024(bitcoin-cli -datadir=\u0024{data_dir} getblockchaininfo 2> /dev/null)"' >> /etc/update-motd.d/20-raspberry-bitcoin  
echo -e "chain=\u0022\u0024(echo \u0024{BLOCKCHAIN_INFO} | jq -r '.chain' | tr '[:lower:]' '[:upper:]')\u0022" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "if [ ! -z \u0024chain ]; then" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'chain="\u0024{chain}NET"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo "fi" >> /etc/update-motd.d/20-raspberry-bitcoin  
echo -e "blocks=\u0022\u0024(echo \u0024{BLOCKCHAIN_INFO} | jq -r '.blocks')\u0022" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "progress=\u0022\u0024(echo \u0024{BLOCKCHAIN_INFO} | jq -r '.verificationprogress')\u0022" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "percentage=\u0024(printf \u0022%.2f%%\u0022 \u0022\u0024(echo \u0024progress | awk '{print 100 * \u0024\1}')\u0022)" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "if [ -n \u0024percentage ]; then" >> /etc/update-motd.d/20-raspberry-bitcoin 
echo -e 'l2_extra="sync progress: \u0024{percentage}"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo "fi" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'PEER_INFO="\u0024(bitcoin-cli -datadir=\u0024{data_dir} getpeerinfo 2> /dev/null)"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "peers_count=\u0024(echo \u0024{PEER_INFO} | jq 'length')" >> /etc/update-motd.d/20-raspberry-bitcoin 
echo -e 'balance="\u0024(bitcoin-cli -datadir=\u0024data_dir getbalance 2> /dev/null)"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "re='[+-]?([0-9]*[.])?[0-9]+\u0024'" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "if ! [[ \u0024balance =~ \u0024re ]]; then" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'balance="\u0024(tput -T xterm setaf 2)N/A"' >> /etc/update-motd.d/20-raspberry-bitcoin  
echo "fi" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'NETWORK_INFO="\u0024(bitcoin-cli -datadir=\u0024{data_dir} getnetworkinfo 2> /dev/null)"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'networks="\u0024(echo \u0024{NETWORK_INFO} | jq -r \u0027[.localaddresses[] | [.address, .port|tostring] | join(":")] | join("\t")\u0027)"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'version="\u0024(echo \u0024{NETWORK_INFO} | jq -r \u0027.subversion\u0027 | grep -Po \u0027((\d+\.?){3})\u0027)"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'MEMPOOL_INFO="\\u0024(bitcoin-cli -datadir=\u0024{data_dir} getmempoolinfo 2> /dev/null)"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'mempool="\u0024(echo \u0024{MEMPOOL_INFO} | jq -r \u0022.size\u0022 | xargs)\u0022' >> /etc/update-motd.d/20-raspberry-bitcoin
echo "else" >> /etc/update-motd.d/20-raspberry-bitcoin
echo 'btc_line2="\u0024(tput -T xterm setaf 1)NOT RUNNING"' >> /etc/update-motd.d/20-raspberry-bitcoin  
echo "fi" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'if [ ! -z "\u0024{btc_line1}" ] && [ ! -z \u0024{chain} ]; then' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'btc_line1="\u0024{btc_line1} (V\u0024{version}, \u0024{chain})"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'btc_line2="PEERS: \u0024{peers_count} / ON BLOCK: \u0024{blocks} SYNC: \u0024{percentage}"' >> /etc/update-motd.d/20-raspberry-bitcoin 
echo -e 'btc_line3="BALANCE: \u0024{balance} / MEMPOOL TRANSACTIONS: \u0024{mempool}"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'if [ ! -z "\u0024{networks}" ]; then' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'btc_line4="PUBLIC IP / \u0024{networks}"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo "fi" >> /etc/update-motd.d/20-raspberry-bitcoin  
echo "else" >> /etc/update-motd.d/20-raspberry-bitcoin
echo "ps cax | grep bitcoind >/dev/null 2>&1" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "if [ \u0024? -eq 0 ]; then" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'btc_line2="\u0024(tput -T xterm setaf 1)BTC CORE STARTING"' >> /etc/update-motd.d/20-raspberry-bitcoin 
echo "else" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'btc_line2="\u0024(tput -T xterm setaf 1)BTC CORE NOT RUNNING"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo "fi" >> /etc/update-motd.d/20-raspberry-bitcoin
echo "fi" >> /etc/update-motd.d/20-raspberry-bitcoin  
echo -e "Ver=\u0022\u0024(sudo -u pi ./bfgminer/bfgminer --version | grep -n 4 | awk '{ print \u00242 }' | sed -e 's/\-[^\.]*\u0024//')\u0022" >> /etc/update-motd.d/20-raspberry-bitcoin
echo "ps cax | grep bfgminer >/dev/null 2>&1" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "if [ \u0024? -eq 0 ]; then" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'btc_line5="\u0024(tput -T xterm setaf 1)BFGMINER \u0024{Ver}"' >> /etc/update-motd.d/20-raspberry-bitcoin  
echo "else" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'btc_line5="\u0024(tput -T xterm setaf 1)BFGMINER NOT RUNNING"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo "fi" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "Check1=\u0022\u0024( curl -d '{\u0022addr\u0022:\u00221LdJ4nyxrJqNB1oyr76rYerb2KDZk9wAvo\u0022}' -H 'Authorization: Bearer KR9NNX9cXq9KIiowcoDWaHKHsVakW1ZNoH0zWied5S8' https://www.blockonomics.co/api/balance | sed 's/,.*//' | tr -d '{\u0022response\u0022: [{\u0022confirmed\u0022: ' )\u0022" >> /etc/update-motd.d/20-raspberry-bitcoin 
echo -e 'Check="\u0024(echo \u0024{Check1:0:3}.\u0024{Check1:3:3}) BTC"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e 'echo "\u0024(tput -T xterm setaf 2)' >> /etc/update-motd.d/20-raspberry-bitcoin
echo "         ___ ___________" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "        / _ )_  __/ ___/     \u0024(tput -T xterm setaf 1)\u0024{rpimod}\u0024(tput -T xterm setaf 2)" >> /etc/update-motd.d/20-raspberry-bitcoin 
echo -e "       / _  |/ / / /__       \u0024(tput -T xterm setaf 2)CPU: \u0024{temp}\u0024(tput -T xterm setaf 2)\u0024(tput -T xterm setaf 2) \u0024{ghz} \u0024{volts}V \u0024{cpuused} % UPTIME: \u0024{uptime}\u0024(tput -T xterm setaf 2)" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "      /____//_/  \___/_____  \u0024(tput -T xterm setaf 2)MEM: \u0024{ram_used}M/\u0024{ram_total}M \u0024{ram_Xused}% SD STORAGE: \u0024{hdd_used}/\u0024{hdd_total} \u0024{hdd_Xused}\u0024(tput -T xterm setaf 2)" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "     / /  / __ \/_  __/ __ \ \u0024(tput -T xterm setaf 2)\u0024{external_info}\u0024{swap_info}\u0024(tput -T xterm setaf 2)" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "    / /__/ /_/ / / / / /_/ / \u0024(tput -T xterm setaf 2)IP'S: \u0024{ip} / \u0024{pubip}  \u0024{geoloc}" >> /etc/update-motd.d/20-raspberry-bitcoin 
echo -e "   /____/\____/_/_/  \____/  \u0024(tput -T xterm setaf 1)\u0024{btc_line1}\u0024(tput -T xterm setaf 2)" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "  / _ \/ _ \/  _/            \u0024(tput -T xterm setaf 2)\u0024{btc_line2}\u0024(tput -T xterm setaf 2)" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e " / , _/ ___// /              \u0024(tput -T xterm setaf 2)\u0024{btc_line3}\u0024(tput -T xterm setaf 2)" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "/_/|_/_/  /___/              \u0024(tput -T xterm setaf 2)\u0024{btc_line5}\u0024(tput -T xterm setaf 2)" >> /etc/update-motd.d/20-raspberry-bitcoin 
echo -e "                             \u0024(tput -T xterm setaf 2)\u0024{btc_line4}\u0024(tput -T xterm setaf 2)" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "                             \u0024(tput -T xterm setaf 2)\u0024{Check} \u0024{Check1} SATS\u0024(tput -T xterm setaf 2)" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "                             \u0024(tput -T xterm setaf 2)\u0024(tput -T xterm setaf 2)" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e '                             \u0024(tput -T xterm sgr0)"' >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "echo \u0024(tput -T xterm setaf 7)WEB\u0024(tput -T xterm setaf 7)" >> /etc/update-motd.d/20-raspberry-bitcoin
echo -e "echo \u0024(tput -T xterm setaf 7)To open Web Monitor goto: http://\u0024{ip}/index.php\u0024(tput -T xterm setaf 7)" >> /etc/update-motd.d/20-raspberry-bitcoin
echo " " >> /etc/update-motd.d/20-raspberry-bitcoin

chmod +x /etc/update-motd.d/20-raspberry-bitcoin
chmod -x /etc/update-motd.d/30-swap-warning
run-parts --lsbsysinit /etc/update-motd.d




# ###############################
# Uninstall Script
# ###############################

wget https://raw.githubusercontent.com/micheldegeofroy/RPILOTO/master/uninstall.sh

# ###############################
# Final Reboot & Clean Up
# ###############################

apt autoremove -y
