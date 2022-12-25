import time
import random
import datetime
import telepot
from telepot.loop import MessageLoop
import subprocess
import RPi.GPIO as GPIO
import re
import os
import telegram
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters

os.system('pwd')
os.system('cd ~')
os.system('df -h')
os.system('ls -la')
stream = os.popen('ls -la')
stream = os.popen('df -h')
output = stream.readlines()

token = "replacewithyourbottoken"

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
    
def read_chat_ids():
    with open('chat_ids.txt', 'r') as f:
        chat_ids = [int(line.strip()) for line in f]
    return chatids
def message_received(update, context):
    # Get the chat ID of the sender
    chat_id = update.message.chat_id
    # Read the list of allowed chat IDs
    allowed_chat_ids = read_chat_ids()
    # Check if the chat ID is in the list of allowed chat IDs
    if chat_id in allowed_chat_ids:
       def handle(msg):
    chat_id = msg['chat']['id']
    command = msg['text']
    else:
        # Send a message to the user telling them to contact the admin
        bot.send_message(chat_id=chat_id, text='Unauthorized')
      
      # Create the Updater and pass it the bot's token
updater = Updater(TOKEN, use_context=True)

# Get the dispatcher to register handlers
dispatcher = updater.dispatcher

# Add a message handler to the dispatcher
message_handler = MessageHandler(Filters.all, message_received)
dispatcher.add_handler(message_handler)

# Start the bot
updater.start_polling()

    print('Got command: %s' % command)

    if command == '/who':
        run = subprocess.run(["whoami"], capture_output=True)
        bot.sendMessage(chat_id, run.stdout)
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

bot = telepot.Bot(token=token)

bot.sendMessage(90423887, "BTC Loto BOT  is back online")

MessageLoop(bot, handle).run_as_thread()
print('I am listening ...')

while 1:
    time.sleep(10)
