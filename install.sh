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
apt dist-upgrade
apt full-upgrade -y 
apt autoremove -y

# ###############################
# Install Tailscale
# ###############################

#Clean Up

#rm -r /usr/share/keyrings/tailscale-archive-keyring.gpg
#rm -r /etc/apt/sources.list.d/tailscale.list
#apt remove apt-transport-http
#apt purge tailscale -y

#Start Install

apt install apt-transport-https

curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
curl -fsSL https://pkgs.tailscale.com/stable/raspbian/bullseye.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

apt update -y
apt install tailscale -y

#tailscale up

# ###############################
# Fix Language Local
# ###############################

#Clean Up

rm -r /etc/environment
rm -r /etc/default/locale
#sed -i 's/en_US.UTF-8 UTF-8/# en_US.UTF-8 UTF-8/g' /etc/locale.gen 

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

#########Code here to hash old value

sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen 


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

#Clean Up

#rm -r /usr/local/bin/speedtest-cli

#Start Install

wget -O /usr/local/bin/speedtest-cli https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
chmod a+x /usr/local/bin/speedtest-cli

# ###############################
# Install watchdog
# ###############################

#Clean Up

#sed -i 's/#Watchdog On/ /g' /boot/config.txt
#sed -i 's/dtparam=watchdog=on/ /g' /boot/config.txt
#systemctl stop watchdog
#systemctl disable watchdog
#rm -r /etc/watchdog.conf
#apt purge watchdog

#Start Install

echo '#Watchdog On' >> /boot/config.txt
echo 'dtparam=watchdog=on' >> /boot/config.txt

apt update
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

#Clean Up

#rm -r /etc/sysctl.d/disable-ipv6.conf
#sed -i 's/ipv6.disable=1/ /g' /boot/cmdline.txt

#Start Install

echo net.ipv6.conf.all.disable_ipv6=1 | sudo tee /etc/sysctl.d/disable-ipv6.conf
sysctl --system
sed -i -e 's/$/ipv6.disable=1/' /boot/cmdline.txt

# ###############################
# Disable BT
# ###############################

#Clean Up

#systemctl enable hciuart.service 
#systemctl enable bluetooth.service

#sed -i 's/# Disable Bluetooth/ /g' /boot/config.txt
#sed -i 's/dtoverlay=disable-bt/ /g' /boot/config.txt


#Start Install

echo '# Disable Bluetooth' >> /boot/config.txt
echo 'dtoverlay=disable-bt' >> /boot/config.txt

systemctl disable hciuart.service 
systemctl disable bluetooth.service


# ###############################
# Install macchanger
# ###############################

#Clean Up

#rm -r /home/pi/mymacchanger.py
#sed -i '1d' /var/spool/cron/root
#sed -i '2d' /var/spool/cron/root
#sed -i '3d' /var/spool/cron/root
#rm -r /var/spool/cron/root

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
#apt install python3-pip -y
pip install telepot

cat >script.py <<'END_SCRIPT'
import telepot
bot = telepot.Bot('5564114282:AAGSjjJkjNH7RB-4dUH-aJW1pMmquFEq-m8')
bot.getMe()
END_SCRIPT

python3 script.py

rm script.py

mkdir /home/pi/Bots/

touch /home/pi/Bots/Bot.py

echo 'import time' >> /home/pi/Bots/Bot.py
echo 'import time' >> /home/pi/Bots/Bot.py
echo 'import random' >> /home/pi/Bots/Bot.py
echo 'import datetime' >> /home/pi/Bots/Bot.py
echo 'import telepot' >> /home/pi/Bots/Bot.py
echo 'from telepot.loop import MessageLoop' >> /home/pi/Bots/Bot.py
echo 'import subprocess' >> /home/pi/Bots/Bot.py
echo 'import RPi.GPIO as GPIO' >> /home/pi/Bots/Bot.py
echo 'import re' >> /home/pi/Bots/Bot.py
echo 'import os' >> /home/pi/Bots/Bot.py
echo 'os.system("pwd")' >> /home/pi/Bots/Bot.py
echo "os.system('cd ~')" >> /home/pi/Bots/Bot.py
echo "os.system('df -h')" >> /home/pi/Bots/Bot.py
echo "os.system('ls -la')" >> /home/pi/Bots/Bot.py
echo "stream = os.popen('ls -la')" >> /home/pi/Bots/Bot.py
echo "stream = os.popen('df -h')" >> /home/pi/Bots/Bot.py
echo "output = stream.readlines()" >> /home/pi/Bots/Bot.py
echo "def on(pin):" >> /home/pi/Bots/Bot.py
echo '        GPIO.output(pin,GPIO.HIGH)' >> /home/pi/Bots/Bot.py
echo '        return' >> /home/pi/Bots/Bot.py
echo 'def off(pin):' >> /home/pi/Bots/Bot.py
echo '        GPIO.output(pin,GPIO.LOW)' >> /home/pi/Bots/Bot.py
echo '        return' >> /home/pi/Bots/Bot.py
echo 'GPIO.setmode(GPIO.BOARD)' >> /home/pi/Bots/Bot.py
echo 'GPIO.setwarnings(False)' >> /home/pi/Bots/Bot.py
echo 'GPIO.setup(11, GPIO.OUT)' >> /home/pi/Bots/Bot.py
echo 'GPIO.setup(12, GPIO.OUT)' >> /home/pi/Bots/Bot.py
echo 'def handle(msg):' >> /home/pi/Bots/Bot.py
echo "    chat_id = msg['chat']['id']" >> /home/pi/Bots/Bot.py
echo "    command = msg['text']" >> /home/pi/Bots/Bot.py
echo "    print('Got command: %s' % command)" >> /home/pi/Bots/Bot.py
echo "    if command == '/who':" >> /home/pi/Bots/Bot.py
echo '        run = subprocess.run(["whoami"], capture_output=True)' >> /home/pi/Bots/Bot.py
echo '        bot.sendMessage(chat_id, run.stdout)' >> /home/pi/Bots/Bot.py
echo "    elif command == '/ledon':" >> /home/pi/Bots/Bot.py
echo '       bot.sendMessage(chat_id, on(11))' >> /home/pi/Bots/Bot.py
echo "    elif command =='/ledoff':" >> /home/pi/Bots/Bot.py
echo '       bot.sendMessage(chat_id, off(11))' >> /home/pi/Bots/Bot.py
echo "    elif command == '/fanon':" >> /home/pi/Bots/Bot.py
echo "       bot.sendMessage(chat_id, on(12))" >> /home/pi/Bots/Bot.py
echo "    elif command =='/fanoff':" >> /home/pi/Bots/Bot.py
echo '       bot.sendMessage(chat_id, off(12))' >> /home/pi/Bots/Bot.py
echo "    elif command == '/model':" >> /home/pi/Bots/Bot.py
echo '       run = subprocess.run(["cat", "/proc/device-tree/model"], capture_output= True)' >> /home/pi/Bots/Bot.py
echo '       bot.sendMessage(chat_id, run.stdout)' >> /home/pi/Bots/Bot.py
echo "    elif command == '/uptime':" >> /home/pi/Bots/Bot.py
echo '       run = subprocess.run(["uptime","-p"], capture_output= True)' >> /home/pi/Bots/Bot.py
echo '       bot.sendMessage(chat_id, run.stdout[2:])' >> /home/pi/Bots/Bot.py
echo "    elif command == '/where':" >> /home/pi/Bots/Bot.py
echo -e '       run = subprocess.run(["""curl https://extreme-ip-lookup.com/json/?key=ACJdcEKqljZrmlXp1GZA | jq -r \u0027.country\u0027 | tr \u0027[:lower:]\u0027 \u0027[:upper:]\u0027"""],shell=True,capture_output= True)' >> /home/pi/Bots/Bot.py
echo '       bot.sendMessage(chat_id, run.stdout)' >> /home/pi/Bots/Bot.py
echo "    elif command == '/hd':" >> /home/pi/Bots/Bot.py
echo -e '       run = subprocess.run(["""df -h | grep "\u0024" | awk \u0027{ print \u00245 }\u0027"""], shell=True, capture_output= True)' >> /home/pi/Bots/Bot.py
echo "       bot.sendMessage(chat_id, text = 'SD HD Used: '+ run.stdout.decode('utf-8'))" >> /home/pi/Bots/Bot.py
echo "    elif command == '/volts':" >> /home/pi/Bots/Bot.py
echo -e '        run = subprocess.run(["""vcgencmd measure_volts \u0024id | awk \u0027{print substr(\u00240, 6, length(\u00240) - 9),"V"}\u0027"""], shell=True, capture_output= True)' >> /home/pi/Bots/Bot.py
echo -e '        bot.sendMessage(chat_id, text = "Volts Used: "+run.stdout.decode(\u0027utf-8\u0027))' >> /home/pi/Bots/Bot.py
echo "    elif command == '/speed':" >> /home/pi/Bots/Bot.py
echo "        run = subprocess.run(['speedtest-cli --simple'], shell=True, capture_output= True)" >> /home/pi/Bots/Bot.py
echo -e '        bot.sendMessage(chat_id, text = "Speed Test: "+run.stdout.decode(\u0027utf-8\u0027))' >> /home/pi/Bots/Bot.py
echo "    elif command == '/cpughz':" >> /home/pi/Bots/Bot.py
echo -e '        run = subprocess.run(["""vcgencmd measure_clock arm | awk \u0027 BEGIN { FS="=" } ; { printf( \u00242 / 1000000000) } \u0027"""], shell=True, capture_output= True)' >> /home/pi/Bots/Bot.py
echo -e '        bot.sendMessage(chat_id,text = "CPU : " + run.stdout.decode(\u0027utf-8\u0027)[:3] + "GHz")' >> /home/pi/Bots/Bot.py
echo "    elif command == '/cpu':" >> /home/pi/Bots/Bot.py
echo -e '        run = subprocess.run(["""vmstat 1 2 | tail -1 | awk \u0027{print \u002413}\u0027"""], shell=True, capture_output= True)' >> /home/pi/Bots/Bot.py
echo -e '        bot.sendMessage(chat_id,text = "CPU% : " + run.stdout.decode(\u0027utf-8\u0027)[:3] + "%")' >> /home/pi/Bots/Bot.py
echo "    elif command == '/wanip':" >> /home/pi/Bots/Bot.py
echo "        run = subprocess.run(['curl ifconfig.co'], shell=True, capture_output= True)" >> /home/pi/Bots/Bot.py
echo -e '        bot.sendMessage(chat_id,text = "Public IP: "+run.stdout.decode(\u0027utf-8\u0027))' >> /home/pi/Bots/Bot.py
echo "    elif command == '/lanip':" >> /home/pi/Bots/Bot.py
echo "        run = subprocess.run(['hostname -I'], shell=True, capture_output= True)" >> /home/pi/Bots/Bot.py
echo -e '        bot.sendMessage(chat_id,text = "Local IP: "+run.stdout.decode(\u0027utf-8\u0027))' >> /home/pi/Bots/Bot.py
echo "    elif command == '/hdex':" >> /home/pi/Bots/Bot.py
echo -e '        run = subprocess.run(["""df -h | grep "/dev/sd" | awk \u0027{print\u00245}\u0027"""], shell=True, capture_output= True)' >> /home/pi/Bots/Bot.py
echo -e '        bot.sendMessage(chat_id, text = "External HD Used: "+ run.stdout.decode(\u0027utf-8\u0027))' >> /home/pi/Bots/Bot.py
echo "    elif command == '/htop':" >> /home/pi/Bots/Bot.py
echo "        run = subprocess.run(['ps -e --sort -%mem | head -10'], shell=True, capture_output= True)" >> /home/pi/Bots/Bot.py
echo '        bot.sendMessage(chat_id,text = "Proccese Running: "+run.stdout.decode("utf-8"))' >> /home/pi/Bots/Bot.py
echo "    elif command == '/temp':" >> /home/pi/Bots/Bot.py
echo '        run = subprocess.run(["cat /sys/class/thermal/thermal_zone0/temp"], shell=True, capture_output= True)' >> /home/pi/Bots/Bot.py
echo -e '        bot.sendMessage(chat_id,text = "Temperature: " + str(int(run.stdout.decode(\u0027utf-8\u0027))/1000)[:-4] + "C")' >> /home/pi/Bots/Bot.py
echo "    elif command == '/sync':" >> /home/pi/Bots/Bot.py
echo -e '        run = subprocess.run(["""bitcoin-cli -rpcuser=USER -rpcpassword=PASS getblockchaininfo 2> /dev/null  | jq -r \u0027.verificationprogress\u0027 | awk \u0027{print 100 * \u00241}\u0027"""], shell=True, capture_output= True)' >> /home/pi/Bots/Bot.py
echo -e '        bot.sendMessage(chat_id,text = "Blockchain Sync is at: " + run.stdout.decode(\u0027utf-8\u0027)[:4] + "%")' >> /home/pi/Bots/Bot.py
echo '    elif re.search("magnet:", command):' >> /home/pi/Bots/Bot.py
echo -e '        run = subprocess.run(["transmission-remote -a \u0027%s\u0027  " %  command  ], shell=True, capture_output = True)' >> /home/pi/Bots/Bot.py
echo '        print(run.stdout)' >> /home/pi/Bots/Bot.py
echo '        bot.sendMessage(chat_id, "Well, something happened, maybe good, maybe shit")' >> /home/pi/Bots/Bot.py
echo '    elif re.search("ping", command):' >> /home/pi/Bots/Bot.py
echo -e '        run = subprocess.run([ command + """ -c 3 | awk -F \u0027 \u0027 \u0027{print substr(\u00247, 1, length(\u00241) 0)}\u0027 | sed -e \u0027s/\(data.\|packet\)//\u0027"""], shell=True, capture_output = True)' >> /home/pi/Bots/Bot.py
echo -e '        bot.sendMessage(chat_id, "Ping" + run.stdout.decode(\u0027utf-8\u0027))' >> /home/pi/Bots/Bot.py
echo '        print(run.stdout)' >> /home/pi/Bots/Bot.py
echo '    elif re.search("sudo", command):' >> /home/pi/Bots/Bot.py
echo '        run = subprocess.run([command], shell=True, capture_output = True)' >> /home/pi/Bots/Bot.py
echo -e '        bot.sendMessage(chat_id, "Sudo " + run.stdout.decode(\u0027utf-8\u0027))' >> /home/pi/Bots/Bot.py
echo '        print(run.stdout)' >> /home/pi/Bots/Bot.py
echo "    elif command == '/Fuck':" >> /home/pi/Bots/Bot.py
echo '        bot.sendMessage(chat_id, "Are you from NYC ?")' >> /home/pi/Bots/Bot.py
echo "    elif command == '/help':" >> /home/pi/Bots/Bot.py
echo '        bot.sendMessage(chat_id, "/start /shutdown /startminer /stopminer /fanon /fanoff /ledon /ledoff /ping /sudo /help /htop /sync /model /uptime /where /who /hd /hdex /volts /speed /cpughz /cpu /wanip /lanip /temp /reboot ")' >> /home/pi/Bots/Bot.py
echo "    elif command == '/start':" >> /home/pi/Bots/Bot.py
echo '        bot.sendMessage(chat_id, "/start /shutdown /startminer /stopminer /fanon /fanoff /ledon /ledoff /ping /sudo /help /htop /sync /model /uptime /where /who /hd /hdex /volts /speed /cpughz /cpu /wanip /lanip /temp /reboot ")' >> /home/pi/Bots/Bot.py
echo "    elif command == '/reboot':" >> /home/pi/Bots/Bot.py
echo "        bot.sendMessage(chat_id,'Rebooting Now ')" >> /home/pi/Bots/Bot.py
echo "        os.system('sudo reboot')" >> /home/pi/Bots/Bot.py
echo "    elif command == '/shutdown':" >> /home/pi/Bots/Bot.py
echo "        bot.sendMessage(chat_id,'Shutting Down Now !')" >> /home/pi/Bots/Bot.py
echo "        os.system('sudo shutdown')" >> /home/pi/Bots/Bot.py
echo "    elif command == '/startminer':" >> /home/pi/Bots/Bot.py
echo "        bot.sendMessage(chat_id,'Miner Started')" >> /home/pi/Bots/Bot.py
echo "        os.system('sudo systemctl start bfgminer.service')" >> /home/pi/Bots/Bot.py
echo "    elif command == '/stopminer':" >> /home/pi/Bots/Bot.py
echo "        bot.sendMessage(chat_id,'Miner Stopped')" >> /home/pi/Bots/Bot.py
echo "        os.system('sudo systemctl stop bfgminer.service')" >> /home/pi/Bots/Bot.py
echo "    else: bot.sendMessage(chat_id,'Try /help')" >> /home/pi/Bots/Bot.py
echo "bot = telepot.Bot('5564114282:AAGSjjJkjNH7RB-4dUH-aJW1pMmquFEq-m8')" >> /home/pi/Bots/Bot.py
echo 'bot.sendMessage(90423887, "BTC Loto BOT  is back online")' >> /home/pi/Bots/Bot.py
echo "MessageLoop(bot, handle).run_as_thread()" >> /home/pi/Bots/Bot.py
echo "print('I am listening ...')" >> /home/pi/Bots/Bot.py
echo 'while 1:' >> /home/pi/Bots/Bot.py
echo '    time.sleep(10)' >> /home/pi/Bots/Bot.py

touch /etc/systemd/system/bot.service

echo '[Unit]' >> /etc/systemd/system/bot.service
echo 'Description=Telegram Bot Service' >> /etc/systemd/system/bot.service
echo 'After=multi-user.target' >> /etc/systemd/system/bot.service
echo '[Service]' >> /etc/systemd/system/bot.service
echo 'Type=simple' >> /etc/systemd/system/bot.service
echo 'Restart=always' >> /etc/systemd/system/bot.service
echo 'ExecStart=/usr/bin/python3 /home/pi/Bots/Bot.py' >> /etc/systemd/system/bot.service
echo '[Install]' >> /etc/systemd/system/bot.service
echo 'WantedBy=multi-user.target' >> /etc/systemd/system/bot.service

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
# Web Interface
# ###############################

#Clean Up


apt purge php -y
apt purge apache2 -y
rm -rf /etc/apache2
rm /var/www/html/index.php


#Start Install

apt install php -y

touch /var/www/html/index.php

echo "<?php" >> /var/www/html/index.php
echo -e "echo \u0022<body style='background-color:black' text='green' link='green' vlink= 'green' alink='green'>\u0022;" >> /var/www/html/index.php
echo -e "echo '<span style=\u0022color: green; font-size: 12px; font-family: times;\u0022>';" >> /var/www/html/index.php
echo -e "\u0024page = \u0024_SERVER['PHP_SELF'];" >> /var/www/html/index.php
echo -e "\u0024sec = \u002260\u0022;" >> /var/www/html/index.php
echo -e "header(\u0022Refresh: \u0024sec; url=\u0024page\u0022);" >> /var/www/html/index.php
echo -e "\u0024ver = shell_exec(\u0022sudo -u bitcoin /usr/local/bin/bitcoin-cli getnetworkinfo 2> /dev/null | jq -r '.subversion'\u0022);" >> /var/www/html/index.php
echo -e "\u0024chain1 = shell_exec(\u0022sudo -u bitcoin /usr/local/bin/bitcoin-cli getblockchaininfo 2> /dev/null | jq -r '.chain'\u0022);" >> /var/www/html/index.php
echo -e "\u0024chain2 = \u0022Net \u0022;" >> /var/www/html/index.php
echo -e "\u0024chain3 = \u0022Bitcoin Core \u0022;" >> /var/www/html/index.php
echo -e "\u0024chain4 = substr(\u0024chain1, 0, -1);" >> /var/www/html/index.php
echo -e "\u0024chain5 = str_replace(str_split('/:Satoshi'),'',\u0024ver);" >> /var/www/html/index.php
echo -e "\u0024chain = \u0024chain3.ucfirst(\u0024chain4).\u0024chain2.\u0022V\u0022.\u0024chain5;" >> /var/www/html/index.php
echo -e "\u0024diff = shell_exec(\u0022sudo -u bitcoin /usr/local/bin/bitcoin-cli getblockchaininfo 2> /dev/null | jq -r '.difficulty'\u0022);" >> /var/www/html/index.php
echo -e "\u0024mempool = shell_exec(\u0022sudo -u bitcoin /usr/local/bin/bitcoin-cli getmempoolinfo 2> /dev/null | jq -r '.size'\u0022);" >> /var/www/html/index.php
echo -e "\u0024balance = shell_exec(\u0024sudo -u bitcoin /usr/local/bin/bitcoin-cli getbalance 2> /dev/null\u0024);" >> /var/www/html/index.php
echo -e "\u0024balance = shell_exec(\u0024sudo -u bitcoin /usr/local/bin/bitcoin-cli getbalance 2> /dev/null\u0024);" >> /var/www/html/index.php
echo -e "\u0024btcblock = shell_exec(\u0024sudo -u bitcoin /usr/local/bin/bitcoin-cli getblockchaininfo 2> /dev/null | jq -r '.blocks'\u0024);" >> /var/www/html/index.php
echo -e "\u0024btcpeers = shell_exec(\u0024sudo -u bitcoin /usr/local/bin/bitcoin-cli getpeerinfo 2> /dev/null | jq 'length'\u0024);" >> /var/www/html/index.php
echo -e "\u0024btcsync = shell_exec(\u0024sudo -u bitcoin /usr/local/bin/bitcoin-cli getblockchaininfo 2> /dev/null | jq -r '.verificationprogress' | awk '{print 100 * $1}'\u0024);" >> /var/www/html/index.php
echo -e "\u0024cpu = shell_exec(\u0022vcgencmd measure_clock arm | sed 's/frequency(48)=//g' | awk  '{ printf(\u00241 / 1000000000)}'\u0022);" >> /var/www/html/index.php
echo -e "\u0024exstoragepercentused = shell_exec(\u0022df -h | grep '/dev/sd' | awk '{print(\u00245)}'\u0022);" >> /var/www/html/index.php
echo -e "\u0024exstoragefree = shell_exec(\u0022df -h | grep '/dev/sd' | awk '{print(\u00244)}'\u0022);" >> /var/www/html/index.php
echo -e "\u0024exstoragesize = shell_exec(\u0022df -h | grep '/dev/sd' | awk '{print(\u00242)}'\u0022);" >> /var/www/html/index.php
echo -e "\u0024exstorageused = shell_exec(\u0022df -h | grep '/dev/sd' | awk '{print(\u00243)}'\u0022);" >> /var/www/html/index.php
echo -e "\u0024ip = shell_exec(\u0022hostname -I\u0022);" >> /var/www/html/index.php
echo -e "\u0024temp = round(shell_exec('cat /sys/class/thermal/thermal_zone*/temp')/1000, 1);" >> /var/www/html/index.php
echo -e "\u0024geoloc= shell_exec(\u0022curl https://extreme-ip-lookup.com/json/?key=ACJdcEKqljZrmlXp1GZA | jq -r '.country' | tr '[:lower:]' '[:upper:]'\u0022);" >> /var/www/html/index.php
echo -e "\u0024localtime= shell_exec(\u0022uptime | awk '{print(\u00241)}'\u0022);" >> /var/www/html/index.php
echo -e "\u0024users= shell_exec(\u0022uptime | awk '{print substr(\u00245, 1, length(\u00242)-1)}'\u0022);" >> /var/www/html/index.php
echo -e "\u0024voltage = shell_exec('vcgencmd measure_volts | tr -d \volt=');" >> /var/www/html/index.php
echo -e "\u0024pubip = shell_exec('curl ifconfig.co');" >> /var/www/html/index.php
echo -e "\u0024HW = shell_exec('cat /proc/device-tree/model');" >> /var/www/html/index.php
echo -e "\u0024cpupercent1 = shell_exec(\u0022vmstat 1 2 | tail -1 | awk '{print \u002413}'\u0022);" >> /var/www/html/index.php
echo -e "\u0024cpupercent = trim(\u0024cpupercent1);" >> /var/www/html/index.php
echo -e "\u0024uptime1 = shell_exec(\u0022uptime -p\u0022);"  >> /var/www/html/index.php
echo -e "\u0024uptime2 = str_replace(str_split('upoteu,'),'',\u0024uptime1);" >> /var/www/html/index.php
echo -e "\u0024uptime = rtrim(\u0024uptime2);" >> /var/www/html/index.php
echo -e "\u0024raw = array();" >> /var/www/html/index.php
echo -e "\u0024handle = popen('free -mt 2>&1', 'r');" >> /var/www/html/index.php
echo -e "while (!feof(\u0024handle)) {" >> /var/www/html/index.php
echo -e "    \u0024raw[] = fgets(\u0024handle);" >> /var/www/html/index.php
echo -e "}" >> /var/www/html/index.php
echo -e "pclose(\u0024handle);" >> /var/www/html/index.php
echo -e "foreach(\u0024raw as \u0024key => \u0024val) {" >> /var/www/html/index.php
echo -e "  if (strpos(\u0024val,\u0022Mem:\u0022) !== FALSE) {" >> /var/www/html/index.php
echo -e "    list(\u0024junk,\u0024trmem,\u0024tumem, \u0024tfmem) = preg_split('/ +/',\u0024val);" >> /var/www/html/index.php
echo -e "  }" >> /var/www/html/index.php
echo -e "  if (strpos(\u0024val,\u0022Swap:\u0022) !== FALSE) {" >> /var/www/html/index.php
echo -e "    list(\u0024junk,\u0024trswap,\u0024tuswap, \u0024tfswap) = preg_split('/ +/',\u0024val);" >> /var/www/html/index.php
echo -e "  }" >> /var/www/html/index.php
echo -e "  if (strpos(\u0024val,\u0022Total:\u0022) !== FALSE) {" >> /var/www/html/index.php
echo -e "    list(\u0024junk,\u0024tmem,\u0024umem, \u0024fmem) = preg_split('/ +/',\u0024val);" >> /var/www/html/index.php
echo -e "  }" >> /var/www/html/index.php
echo -e "}" >> /var/www/html/index.php
echo -e "echo \u0022<pre>               ___ ___________ \u0022;" >> /var/www/html/index.php
echo -e "echo \u0022<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022              / _ )_  __/ ___/\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022             / _  |/ / / /__  \u0022;" >> /var/www/html/index.php
echo -e "echo \u0022<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022            /____//_/  \___/_____ \u0022;" >> /var/www/html/index.php
echo -e "echo \u0022<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022           / /  / __ \/_  __/ __ \ \u0022;" >> /var/www/html/index.php
echo -e "echo \u0022<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022          / /__/ /_/ / / / / /_/ /\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022         /____/\____/_/_/  \____/ \u0022;" >> /var/www/html/index.php
echo -e "echo \u0022<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022        / _ \/ _ \/  _/ \u0022;" >> /var/www/html/index.php
echo -e "echo \u0022<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022       / , _/ ___// /    \u0022;" >> /var/www/html/index.php
echo -e "echo \u0022<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022      /_/|_/_/  /___/</pre>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022<ul><pre>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022\u0022 . \u0024HW . \u0022<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022Local Time:   \u0022 . substr_replace(\u0024localtime ,\u0022\u0022, -4) .\u0022<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022Geo Location: \u0022 . \u0024geoloc .\u0022\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022Public IP:    \u0022 . \u0024pubip .\u0022\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022Local IP:     \u0022 . \u0024ip .\u0022\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022CPU:          \u0022 . substr_replace(\u0024cpu ,\u0022 GHz\u0022,-2) . \u0022<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022CPU % Used:   \u0022 . \u0024cpupercent .\u0022 % <br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022Uptime:      \u0022 . \u0024uptime .\u0022<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022Volts:        \u0022 . substr(\u0024voltage, 0, -4) . \u0022 V<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022VTemp:         \u0022 . \u0024temp . \u0022 °C<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022Ex HD % Used: \u0022. \u0024exstoragepercentused;" >> /var/www/html/index.php
echo -e "echo \u0022Ex HD Free:   \u0022. \u0024exstoragefree;" >> /var/www/html/index.php
echo -e "echo \u0022Ex HD Used:   \u0022. \u0024exstorageused;" >> /var/www/html/index.php
echo -e "echo \u0022Ex HD Total:  \u0022. \u0024exstoragesize;" >> /var/www/html/index.php
echo -e "echo \u0022Free Mem:     \u0022. \u0024tfmem  . \u0022MB<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022Used Mem:     \u0022. \u0024tumem  . \u0022MB<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022Total Mem:    \u0022. \u0024trmem  . \u0022MB<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0024chain;" >> /var/www/html/index.php
echo -e "echo \u0022<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022BTC Peers:    \u0022 . \u0024btcpeers;" >> /var/www/html/index.php
echo -e "echo \u0022BTC Block:    \u0022 . \u0024btcblock;" >> /var/www/html/index.php
echo -e "echo \u0022BTC Diff:     \u0022 . \u0024diff;" >> /var/www/html/index.php
echo -e "if (empty(\u0024mempool)) {echo \u0022BTC Mempool:  N/A\u0022;}else{echo \u0022BTC Mempool:  \u0022 . \u0024mempool .\u0022\u0022;};" >> /var/www/html/index.php
echo -e "if (empty(\u0024balance)) {echo \u0022BTC Balance:  N/A\u0022;}else{echo \u0022BTC Balance:    \u0022 . \u0024balance .\u0022\u0022;};" >> /var/www/html/index.php
echo -e "echo \u0022<br>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022BTC Sync:     \u0022 . substr(\u0024btcsync, 0, strpos(\u0024btcsync, \u0022.\u0022)) . \u0022%</pre>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022<a href='http://192.168.0.98/miner.php' style='color: green; font: bold font-size: 12px; font-family: courier' >MINER STATS</a>\u0022;" >> /var/www/html/index.php
echo -e "echo \u0022<ul>\u0022;" >> /var/www/html/index.php
echo -e "?>" >> /var/www/html/index.php


# ###############################
# Uninstall Script
# ###############################

touch uninstall.sh

echo "rm -r /usr/share/keyrings/tailscale-archive-keyring.gpg" >> uninstall.sh
echo "rm -r /etc/apt/sources.list.d/tailscale.list" >> uninstall.sh
echo "apt remove apt-transport-https -y" >> uninstall.sh
echo "apt purge tailscale -y" >> uninstall.sh
echo "rm -r /etc/environment" >> uninstall.sh
echo "rm -r /etc/default/locale" >> uninstall.sh
echo "sed -i 's/en_US.UTF-8 UTF-8/# en_US.UTF-8 UTF-8/g' /etc/locale.gen " >> uninstall.sh
echo "swapon --all" >> uninstall.sh
echo "apt install dphys-swapfile -y" >> uninstall.sh
echo "pip uninstall glances -y" >> uninstall.sh
echo "apt purge python3-pip -y" >> uninstall.sh
echo "rm -r /usr/local/bin/speedtest-cli" >> uninstall.sh
echo "sed -i 's/#Watchdog On/ /g' /boot/config.txt" >> uninstall.sh
echo "sed -i 's/dtparam=watchdog=on/ /g' /boot/config.txt" >> uninstall.sh
echo "systemctl stop watchdog" >> uninstall.sh
echo "systemctl disable watchdog" >> uninstall.sh
echo "rm -r /etc/watchdog.conf" >> uninstall.sh
echo "apt purge watchdog -y" >> uninstall.sh
echo "rm -r /etc/sysctl.d/disable-ipv6.conf" >> uninstall.sh
echo "sed -i 's/ipv6.disable=1/ /g' /boot/cmdline.txt" >> uninstall.sh
echo "systemctl enable hciuart.service" >> uninstall.sh
echo "systemctl enable bluetooth.service" >> uninstall.sh
echo "sed -i 's/# Disable Bluetooth/ /g' /boot/config.txt" >> uninstall.sh
echo "sed -i 's/dtoverlay=disable-bt/ /g' /boot/config.txt" >> uninstall.sh
echo "rm -r /home/pi/mymacchanger.py" >> uninstall.sh
echo "sed -i '1d' /var/spool/cron/root" >> uninstall.sh
echo "sed -i '2d' /var/spool/cron/root" >> uninstall.sh
echo "sed -i '3d' /var/spool/cron/root" >> uninstall.sh
echo "rm -r /var/spool/cron/root" >> uninstall.sh
echo "apt purge jq -y" >> uninstall.sh
echo "apt purge python3-pip -y" >> uninstall.sh
echo "pip uninstall telepot -y" >> uninstall.sh
echo "rm -r /home/pi/Bots" >> uninstall.sh
echo "systemctl stop bot.service" >> uninstall.sh
echo "rm -r /etc/systemd/system/bot.service" >> uninstall.sh
echo "systemctl disable bot.service" >> uninstall.sh
echo "systemctl daemon-reload" >> uninstall.sh
echo "sed -i '1d' /var/spool/cron/root" >> uninstall.sh
echo "sed -i '2d' /var/spool/cron/root" >> uninstall.sh
echo "sed -i '3d' /var/spool/cron/root" >> uninstall.sh
echo "rm /etc/motd" >> uninstall.sh
echo "rm -r /etc/update-motd.d/20-raspberry-bitcoin" >> uninstall.sh
echo "rm -r /etc/update-motd.d/30-swap-warning" >> uninstall.sh
echo "apt purge jq -y" >> uninstall.sh
echo "rm -r /var/www/html/index.php" >> uninstall.sh
echo "apt purge php -y" >> uninstall.sh
echo "apt purge apache2 -y" >> uninstall.sh
echo "rm -rf /etc/apache2" >> uninstall.sh
echo "apt autoremove -y" >> uninstall.sh
echo "rm -r install.sh" >> uninstall.sh

# ###############################
# Final Reboot & Clean Up
# ###############################

apt autoremove -y
reboot
