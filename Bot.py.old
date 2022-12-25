import time
import random
import datetime
import telepot
from telepot.loop import MessageLoop
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
def handle(msg):
    chat_id = msg['chat']['id']
    command = msg['text']

    print('Got command: %s' % command)

    if command == '/who':
        run = subprocess.run(["whoami"], capture_output=True)
        bot.sendMessage(chat_id, run.stdout)
    elif command == '/ledon':
       bot.sendMessage(chat_id, on(11))
    elif command =='/ledoff':
       bot.sendMessage(chat_id, off(11))    
    elif command == '/fanon':
       bot.sendMessage(chat_id, on(12))
    elif command =='/fanoff':
       bot.sendMessage(chat_id, off(12))   
    elif command == '/model':
        run = subprocess.run(["cat", "/proc/device-tree/model"], capture_output= True)
        bot.sendMessage(chat_id, run.stdout)
    elif command == '/uptime':
        run = subprocess.run(["uptime","-p"], capture_output= True)
        bot.sendMessage(chat_id, run.stdout[2:])
    elif command == '/where':
        run = subprocess.run(["""curl https://extreme-ip-lookup.com/json/?key=ACJdcEKqljZrmlXp1GZA | jq -r '.country' | tr '[:lower:]' '[:upper:]'"""],shell=True,capture_output= True) 
        bot.sendMessage(chat_id, run.stdout)
    elif command == '/hd':
        run = subprocess.run(["""df -h | grep "/$" | awk '{ print $5 }'"""], shell=True, capture_output= True)
        bot.sendMessage(chat_id, text = "SD HD Used: "+ run.stdout.decode('utf-8'))
    elif command == '/volts':
        run = subprocess.run(["""vcgencmd measure_volts $id | awk '{print substr($0, 6, length($0) - 9),"V"}'"""], shell=True, capture_output= True)
        bot.sendMessage(chat_id, text = "Volts Used: "+run.stdout.decode('utf-8' ))
    elif command == '/speed':
        run = subprocess.run(['speedtest-cli --simple'], shell=True, capture_output= True)
        bot.sendMessage(chat_id, text = "Speed Test: "+run.stdout.decode('utf-8'))
    elif command == '/cpughz':
        run = subprocess.run(["""vcgencmd measure_clock arm | awk ' BEGIN { FS="=" } ; { printf( $2 / 1000000000) } '"""], shell=True, capture_output= True)
        bot.sendMessage(chat_id,text = "CPU : " + run.stdout.decode('utf-8')[:3] + "GHz")
    elif command == '/cpu':
        run = subprocess.run(["""vmstat 1 2 | tail -1 | awk '{print $13}'"""], shell=True, capture_output= True)
        bot.sendMessage(chat_id,text = "CPU% : " + run.stdout.decode('utf-8')[:3] + "%")
    elif command == '/wanip':
        run = subprocess.run(['curl ifconfig.co'], shell=True, capture_output= True)
        bot.sendMessage(chat_id,text = "Public IP: "+run.stdout.decode('utf-8'))
    elif command == '/lanip':
        run = subprocess.run(['hostname -I'], shell=True, capture_output= True)
        bot.sendMessage(chat_id,text = "Local IP: "+run.stdout.decode('utf-8'))
    elif command == '/hdex':
        run = subprocess.run(["""df -h | grep "/dev/sd" | awk '{print$5}'"""], shell=True, capture_output= True)
        bot.sendMessage(chat_id, text = "External HD Used: "+ run.stdout.decode('utf-8'))
    elif command == '/htop':
        run = subprocess.run(['ps -e --sort -%mem | head -10'], shell=True, capture_output= True)
        bot.sendMessage(chat_id,text = "Proccese Running: "+run.stdout.decode('utf-8'))
    elif command == '/temp':
        run = subprocess.run(['cat /sys/class/thermal/thermal_zone0/temp'], shell=True, capture_output= True)
        bot.sendMessage(chat_id,text = "Temperature: " + str(int(run.stdout.decode('utf-8'))/1000)[:-4] + "C")
    elif command == '/sync': 
        run = subprocess.run(["""bitcoin-cli -rpcuser=USER -rpcpassword=PASS getblockchaininfo 2> /dev/null  | jq -r '.verificationprogress' | awk '{print 100 * $1}'"""], shell=True, capture_output= True)
        bot.sendMessage(chat_id,text = "Blockchain Sync is at: " + run.stdout.decode('utf-8')[:4] + "%")
    elif re.search("magnet:", command):
        run = subprocess.run(["transmission-remote -a '%s'  " %  command  ], shell=True, capture_output = True)
        print(run.stdout)
        bot.sendMessage(chat_id, "Well, something happened, maybe good, maybe shit")
    elif re.search("ping", command):
        run = subprocess.run([ command + """ -c 3 | awk -F ' ' '{print substr($7, 1, length($1) 0)}' | sed -e 's/\(data.\|packet\)//'"""], shell=True, capture_output = True)
        bot.sendMessage(chat_id, "Ping" + run.stdout.decode('utf-8'))
        print(run.stdout)
    elif re.search("sudo", command):
        run = subprocess.run([command], shell=True, capture_output = True)
        bot.sendMessage(chat_id, "Sudo " + run.stdout.decode('utf-8'))
        print(run.stdout)
    elif command == '/Fuck':      
        bot.sendMessage(chat_id, "Are you from NYC ?")
    elif command == '/help':
        bot.sendMessage(chat_id, "/start /shutdown /startminer /stopminer /fanon /fanoff /ledon /ledoff /ping /sudo /help /htop /sync /model /uptime /where /who /hd /hdex /volts /speed /cpughz /cpu /wanip /lanip /temp /reboot ")
    elif command == '/start':
        bot.sendMessage(chat_id, "/start /shutdown /startminer /stopminer /fanon /fanoff /ledon /ledoff /ping /sudo /help /htop /sync /model /uptime /where /who /hd /hdex /volts /speed /cpughz /cpu /wanip /lanip /temp /reboot ")
    elif command == '/reboot':
         bot.sendMessage(chat_id,'Rebooting Now ')
         os.system('sudo reboot')
    elif command == '/shutdown':
         bot.sendMessage(chat_id,'Shutting Down Now !')
         os.system('sudo shutdown')
    elif command == '/startminer':
         bot.sendMessage(chat_id,'Miner Started')
         os.system('sudo systemctl start bfgminer.service')
    elif command == '/stopminer':
         bot.sendMessage(chat_id,'Miner Stopped')
         os.system('sudo systemctl stop bfgminer.service')
    else: bot.sendMessage(chat_id,'Try /help')

bot = telepot.Bot('5564114282:AAGSjjJkjNH7RB-4dUH-aJW1pMmquFEq-m8')

bot.sendMessage(90423887, "BTC Loto BOT  is back online")

MessageLoop(bot, handle).run_as_thread()
print('I am listening ...')

while 1:
    time.sleep(10)
