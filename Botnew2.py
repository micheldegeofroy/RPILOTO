import time
import random
import datetime
import telepot
from telepot.loop import MessageLoop
import telegram
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters
import subprocess
import RPi.GPIO as GPIO
import re
import os
os.system('pwd')
os.system('cd ~')
os.system('df -h')
os.system('ls -la')
stream = os.popen('ls -la')
stream = os.popen('df -h')
output = stream.readlines()


 #          +-----+-----+-----------+------+---+---Pi 4B--+---+------+---------+-----+-----+
 #          | BCM | wPi |    Name   | Mode | V | Physical | V | Mode | Name    | wPi | BCM |
 #          +-----+-----+---------+------+---+----++----+---+------+---------+-----+-----+
 #          |     |     |     +3.3v |      |   |  1 || 2  |   |      | 5v      |     |     |
 #          |   2 |   8 |   GPIO  2 |   IN | 1 |  3 || 4  |   |      | 5v      |     |     |
 #          |   3 |   9 |   GPIO  3 |   IN | 1 |  5 || 6  |   |      | 0v      |     |     |
 #          |   4 |   7 |   GPIO  4 |   IN | 1 |  7 || 8  | 0 | IN   | TxD     | 15  | 14  |
 #          |     |     |   GND  0v |      |   |  9 || 10 | 1 | IN   | RxD     | 16  | 15  |
 #          |  17 |   0 |   GPIO 17 |   IN | 0 | 11 || 12 | 0 | IN   | GPIO. 1 | 1   | 18  |
 #          |  27 |   2 |   GPIO 27 |   IN | 0 | 13 || 14 |   |      | 0v      |     |     |
 #          |  22 |   3 |   GPIO 22 |   IN | 0 | 15 || 16 | 0 | IN   | GPIO. 4 | 4   | 23  |
 #          |     |     |     +3.3v |      |   | 17 || 18 | 0 | IN   | GPIO. 5 | 5   | 24  |
 #          |  10 |  12 | SPIO_MOSI | ALT0 | 0 | 19 || 20 |   |      | 0v      |     |     |
 #          |   9 |  13 | SPIO_MISO | ALT0 | 0 | 21 || 22 | 0 | IN   | GPIO. 6 | 6   | 25  |
 #          |  11 |  14 | SPIO_SCLK | ALT0 | 0 | 23 || 24 | 1 | OUT  | CE0     | 10  | 8   |
 #          |     |     |   GND  0v |      |   | 25 || 26 | 1 | OUT  | CE1     | 11  | 7   |
 #          |   0 |  30 |   GPIO  0 |   IN | 1 | 27 || 28 | 1 | IN   | SCL.0   | 31  | 1   |
 #          |   5 |  21 |   GPIO  5 |   IN | 1 | 29 || 30 |   |      | 0v      |     |     |
 #          |   6 |  22 |   GPIO  6 |   IN | 1 | 31 || 32 | 0 | IN   | GPIO.26 | 26  | 12  |
 #          |  13 |  23 |   GPIO 13 |   IN | 0 | 33 || 34 |   |      | 0v      |     |     |
 #          |  19 |  24 |   GPIO 19 |   IN | 0 | 35 || 36 | 0 | IN   | GPIO.27 | 27  | 16  |
 #          |  26 |  25 |   GPIO 26 |   IN | 0 | 37 || 38 | 0 | IN   | GPIO.28 | 28  | 20  |
 #          |     |     |   GND  0v |      |   | 39 || 40 | 0 | IN   | GPIO.29 | 29  | 21  |
 #          +-----+-----+-----------+------+---+----++----+---+------+---------+-----+-----+

#    ---------------------------------------
#   |
#   |     3V3 (1)  (2)  +5V
#   |    SDA1 (3)  (4)  +5V----------------
#   |    SCL1 (5)  (6)  GND
#   |     GND (7)  (8)  TXD1
#   |    SDA2 (9)  (10) RXD1
#    --- SCL2 (11) (12) GPCLK0
#         GND (13) (14) GND
#       GPFS0 (15) (16) GPFS1
#         3V3 (17) (18) GPFS2
#       MOSI0 (19) (20) GND
#       MISO0 (21) (22) GPFS3
#        SDA0 (23) (24) MOSI1
#        SCL0 (25) (26) MISO1
#         GND (27) (28) SCLK1
#       GPFS4 (29) (30) GND
#       GPFS5 (31) (32) GPFS6
#         GND (33) (34) GND
#       GPFS7 (35) (36) GPFS8
#        SDA3 (37) (38) GPFS9
#        SCL3 (39) (40) GPFS10
#         GND (41) (42) GPFS11

# Note: 
# "GND" stanss for "Ground"
# "SDA" stands for "Serial Data Line" 
# "SCL" stands for "Serial Clock Line" 
# "TXD" stands for "Transmit Data" 
# "RXD" stands for "Receive Data" 
# "GPCLK" stands for "General Purpose Clock"
# "GPFS" stands for "General Purpose Function Select" 
# "MOSI" stands for "Master Out, Slave In" 
# "MISO" stands for "Master In, Slave Out" 
# "SCLK" stands for "Serial Clock"


#LED
def on(pin):
        GPIO.output(pin,GPIO.HIGH)
        return
def off(pin):
        GPIO.output(pin,GPIO.LOW)
        return
# to use Raspberry Pi board pin numbers
GPIO.setmode(GPIO.BOARD)
GPIO.setwarnings(False)
# set up GPIO output channel
GPIO.setup(11, GPIO.OUT)
GPIO.setup(12, GPIO.OUT)

# Replace this with your bot token
TOKEN = "5564114282:AAGSjjJkjNH7RB-4dUH-aJW1pMmquFEq-m8"

# Replace with the chat ID of the Admin you want to send the message to
ADMIN_ID = 90423887

# Replace with the message you want to send
MESSAGE = "BTC Loto BOT is back online!"

bot = telegram.Bot(token=TOKEN)
bot.send_message(chat_id=ADMIN_ID, text=MESSAGE)

def read_chat_ids():
    with open('chat_ids.txt', 'r') as f:
        chat_ids = [int(line.strip()) for line in f]
    return chat_ids

def message_received(update, context):
    chat_id = update.message.chat_id
    allowed_chat_ids = read_chat_ids()
    if chat_id in allowed_chat_ids:
        command = update.message.text
        print('Got command: %s' % command)
        
        if command == '/who':
            run = subprocess.run(["whoami"], capture_output=True)
            context.bot.send_message(chat_id, run.stdout.decode()) 
        elif command == '/ledon':
            context.bot.sendMessage(chat_id, on(11))
        elif command =='/ledoff':
            context.bot.sendMessage(chat_id, off(11))    
        elif command == '/fanon':
            context.bot.sendMessage(chat_id, on(12))
        elif command =='/fanoff':
            context.bot.sendMessage(chat_id, off(12)) 
        elif command == '/model':
            run = subprocess.run(["cat", "/proc/device-tree/model"], capture_output=True)
            context.bot.send_message(chat_id, run.stdout.decode())
        elif command == '/uptime':
            run = subprocess.run(["uptime","-p"], capture_output= True)
            context.bot.sendMessage(chat_id, run.stdout.decode()[2:])
        elif command == '/where':
            run = subprocess.run(["""curl https://extreme-ip-lookup.com/json/?key=ACJdcEKqljZrmlXp1GZA | jq -r '.country' | tr '[:lower:]' '[:upper:]'"""],shell=True,capture_output= True) 
            context.bot.sendMessage(chat_id, run.stdout.decode())
        elif command == '/hd':
            run = subprocess.run(["""df -h | grep "/$" | awk '{ print $5 }'"""], shell=True, capture_output= True)
            context.bot.sendMessage(chat_id, text = "SD HD Used: "+ run.stdout.decode('utf-8'))
        elif command == '/volts':
            run = subprocess.run(["""vcgencmd measure_volts $id | awk '{print substr($0, 6, length($0) - 9),"V"}'"""], shell=True, capture_output= True)
            context.bot.sendMessage(chat_id, text = "Volts Used: "+run.stdout.decode('utf-8' ))
        elif command == '/speed':
            run = subprocess.run(['speedtest-cli --simple'], shell=True, capture_output= True)
            context.bot.sendMessage(chat_id, text = "Speed Test: "+run.stdout.decode('utf-8'))
        elif command == '/cpughz':
            run = subprocess.run(["""vcgencmd measure_clock arm | awk ' BEGIN { FS="=" } ; { printf( $2 / 1000000000) } '"""], shell=True, capture_output= True)
            context.bot.sendMessage(chat_id,text = "CPU : " + run.stdout.decode('utf-8')[:3] + "GHz")
        elif command == '/cpu':
            run = subprocess.run(["""vmstat 1 2 | tail -1 | awk '{print $13}'"""], shell=True, capture_output= True)
            context.bot.sendMessage(chat_id,text = "CPU% : " + run.stdout.decode('utf-8')[:3] + "%")
        elif command == '/eth0':
            run = subprocess.run(["""ip link show eth0 | awk '/ether/ {print $2}'"""], shell=True, capture_output= True)
            context.bot.sendMessage(chat_id,text = "Public IP: "+run.stdout.decode('utf-8'))           
        elif command == '/wlan0':
            run = subprocess.run(["""ip link show wlan0 | awk '/ether/ {print $2}'"""], shell=True, capture_output= True)
            context.bot.sendMessage(chat_id,text = "Public IP: "+run.stdout.decode('utf-8'))
        elif command == '/wanip':
            run = subprocess.run(['curl ifconfig.co'], shell=True, capture_output= True)
            context.bot.sendMessage(chat_id,text = "Public IP: "+run.stdout.decode('utf-8'))
        elif command == '/lanip':
            run = subprocess.run(['hostname -I'], shell=True, capture_output= True)
            context.bot.sendMessage(chat_id,text = "Local IP: "+run.stdout.decode('utf-8'))
        elif command == '/hdex':
            run = subprocess.run(["""df -h | grep "/dev/sd" | awk '{print$5}'"""], shell=True, capture_output= True)
            context.bot.sendMessage(chat_id, text = "External HD Used: "+ run.stdout.decode('utf-8'))
        elif command == '/htop':
            run = subprocess.run(['ps -e --sort -%mem | head -10'], shell=True, capture_output= True)
            context.bot.sendMessage(chat_id,text = "Proccese Running: "+run.stdout.decode('utf-8'))
        elif command == '/temp':
            run = subprocess.run(['cat /sys/class/thermal/thermal_zone0/temp'], shell=True, capture_output= True)
            context.bot.sendMessage(chat_id,text = "Temperature: " + str(int(run.stdout.decode('utf-8'))/1000)[:-4] + "C")
        elif command == '/sync': 
            run = subprocess.run(["""bitcoin-cli -rpcuser=USER -rpcpassword=PASS getblockchaininfo 2> /dev/null  | jq -r '.verificationprogress' | awk '{print 100 * $1}'"""], shell=True, capture_output= True)
            context.bot.sendMessage(chat_id,text = "Blockchain Sync is at: " + run.stdout.decode('utf-8')[:4] + "%")
        elif re.search("magnet:", command):
            run = subprocess.run(["transmission-remote -a '%s'  " %  command  ], shell=True, capture_output = True)
            print(run.stdout)
            context.bot.sendMessage(chat_id, "Well, something happened, maybe good, maybe shit")
        elif re.search("ping", command):
            run = subprocess.run([ command + """ -c 3 | awk -F ' ' '{print substr($7, 1, length($1) 0)}' | sed -e 's/\(data.\|packet\)//'"""], shell=True, capture_output = True)
            context.bot.sendMessage(chat_id, "Ping" + run.stdout.decode('utf-8'))
            print(run.stdout)
        elif re.search("sudo", command):
            run = subprocess.run([command], shell=True, capture_output = True)
            context.bot.sendMessage(chat_id, "Sudo " + run.stdout.decode('utf-8'))
            print(run.stdout)
        elif command == '/Fuck':      
            context.bot.sendMessage(chat_id, "Are you from NYC ?")
        elif command == '/help':
            context.bot.sendMessage(chat_id, "/start /shutdown /startminer /stopminer /fanon /fanoff /ledon /ledoff /ping /sudo /help /htop /sync /model /uptime /where /who /hd /hdex /volts /speed /cpughz /cpu /wanip /lanip /temp /reboot ")
        elif command == '/start':
            context.bot.sendMessage(chat_id, "/start /shutdown /startminer /stopminer /fanon /fanoff /ledon /ledoff /ping /sudo /help /htop /sync /model /uptime /where /who /hd /hdex /volts /speed /cpughz /cpu /wanip /lanip /temp /reboot ")
        elif command == '/reboot':
            context.bot.sendMessage(chat_id,'Rebooting Now ')
            os.system('sudo reboot')
        elif command == '/shutdown':
            context.bot.sendMessage(chat_id,'Shutting Down Now !')
            os.system('sudo shutdown')
        elif command == '/startminer':
            context.bot.sendMessage(chat_id,'Miner Started')
            os.system('sudo systemctl start bfgminer.service')
        elif command == '/stopminer':
            context.bot.sendMessage(chat_id,'Miner Stopped')
            os.system('sudo systemctl stop bfgminer.service')
        else:
            context.bot.send_message(chat_id, 'Try /help')
    else:
        # Send a message to the user telling them to contact the admin
        context.bot.send_message(chat_id=chat_id, text='Unauthorized Access')

updater = Updater(TOKEN, use_context=True)

dispatcher = updater.dispatcher

dispatcher.add_handler(MessageHandler(Filters.text, message_received))

updater.start_polling()

updater.idle()
