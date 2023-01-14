#!/usr/bin/python
# -*- coding: utf-8 -*-

import time
# import random
# import datetime
import telepot
from telepot.loop import MessageLoop
import telegram
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters
import subprocess
import RPi.GPIO as GPIO
import re
import os
import threading
import requests
import bitcoin

os.system('pwd')
os.system('cd ~')
os.system('df -h')
os.system('ls -la')
stream = os.popen('ls -la')
stream = os.popen('df -h')
output = stream.readlines()

flag1 = False
flag2 = False
flag3 = False
flag4 = False
flag5 = False

# LED

def on(pin):
    GPIO.output(pin, GPIO.HIGH)
    return

def off(pin):
    GPIO.output(pin, GPIO.LOW)
    return

# Set up GPIO output channel
GPIO.setmode(GPIO.BOARD)
GPIO.setwarnings(False)
GPIO.setup(11, GPIO.OUT)
GPIO.setup(12, GPIO.OUT)

#Replace with https://www.blockonomics.co API key
api_key = 'replacewithyourapikey'

# Replace YOUR_BTC_WALLET_ADDRESS with the actual address of your Bitcoin wallet yourbtcwalletaddress 1LdJ4nyxrJqNB1oyr76rYerb2KDZk9wAvo
wallet_address = '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa'

# Replace this with your bot token
TOKEN = 'replacewithyourbottoken'

# Replace with the chat ID of the Admin you want to send the message to
ADMIN_ID = replacewithadminchatid

MESSAGE = 'BTC Loto BOT is back online!'

bot = telegram.Bot(token=TOKEN)
bot.send_message(chat_id=ADMIN_ID, text=MESSAGE)

# Function for /btc
def get_btc_price():
    # Make a request to the CryptoCompare API to get the latest BTC price in USD
    r = requests.get(
        'https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=USD')
    btc_price = r.json()['USD']

    return btc_price

# Function for /walletusd
def get_btc_value(wallet_address, api_key):
    # Make a request to the CryptoCompare API to get the current value of the Bitcoin wallet
    url = f'https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=USD&api_key={api_key}'
    r = requests.get(url)

def make_btc_address():
    # Generate a private key
    private_key = bitcoin.random_key()

    # Derive the public key and address
    public_key = bitcoin.privkey_to_pubkey(private_key)
    address = bitcoin.pubkey_to_address(public_key)

    # Generate a WIF private key
    wif_private_key = bitcoin.encode_privkey(private_key, 'wif')

    return f"New Public Key: {public_key}\n \nNew Public Address: \n{address}\n \nWIF Private Key: {wif_private_key}\n\nCheck at www.bitaddress.org"

# Function checks validity of WIF btc address
def check_private_key(check_address2):
    try:
        # Use the validateaddress() function to check if the given address is valid
        address_info = bitcoin.rpc.call('validateaddress', [check_address2])
        if address_info['isvalid']:
            message = f'{check_address2} is a valid bitcoin address'
        else:
            message = f'{check_address2} is not a valid bitcoin address'
    except:
        message = f'An error occurred while checking {check_address2} probably Bitcoin Core is not running'
    return message

# Function for /btc
def get_btc_price():
    # Make a request to the CryptoCompare API to get the latest BTC price in USD
    r = requests.get(
        'https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=USD')
    btc_price = r.json()['USD']

    return btc_price

# Function for /walletusd
def get_btc_value(wallet_address, api_key):
    # Make a request to the CryptoCompare API to get the current value of the Bitcoin wallet
    url = f'https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=USD&api_key={api_key}'
    r = requests.get(url)

    # Get the current value of BTC in USD
    btc_value = int(r.json()['USD'])

    # Make a request to the blockonomics API to get the balance of the Bitcoin wallet
    balance_url = f'https://www.blockonomics.co/api/balance'
    balance_headers = {'Authorization': f'Bearer {api_key}',
                       'Content-Type': 'application/json'}
    balance_payload = {'addr': wallet_address}
    balance_response = requests.post(
        balance_url, headers=balance_headers, json=balance_payload)

    # Get the balance of the Bitcoin wallet in satoshis
    satoshi_balance = balance_response.json()['response'][0]['confirmed']

    # Calculate the value of the Bitcoin wallet in USD
    wallet_value = btc_value * (satoshi_balance / 10**8)

    return wallet_value

# Function for /wallet
def get_btc_balance(wallet_address, api_key):
    # Make a request to the blockonomics API to get the current balance of the Bitcoin wallet
    url = f'https://www.blockonomics.co/api/balance'
    headers = {'Authorization': f'Bearer {api_key}',
               'Content-Type': 'application/json'}
    payload = {'addr': wallet_address}
    r = requests.post(url, headers=headers, json=payload)
    print(r.text)

    # Get the balance in satoshis
    satoshi_balance = r.json()['response'][0]['confirmed']

    # Convert the balance to BTC
    btc_balance = satoshi_balance / 100000000

    return btc_balance

# Function for /walletusd
def send_btc_value(bot, chat_id, wallet_address, api_key):
    # Get the current value of the Bitcoin wallet
    btc_value = get_btc_value(wallet_address, api_key)

    # Send a message to the user with the current value of the Bitcoin wallet in usd
    message = f'The current value of your BTC wallet is ${btc_value:.0f} USD'
    bot.send_message(chat_id=chat_id, text=message)

# Function for /wallet
def send_btc_balance(bot, chat_id, wallet_address, api_key):
    # Get the current balance of the Bitcoin wallet
    btc_balance = get_btc_balance(wallet_address, api_key)

    # Send a message to the user with the current balance of the Bitcoin wallet
    message = f'The current balance of your BTC wallet is: {btc_balance} BTC'
    bot.send_message(chat_id=chat_id, text=message)

# Function for /walletcheck
def check_wallet_balance(wallet_address2, api_key):
    # Make a request to the blockonomics API to get the current balance of the Bitcoin wallet
    url = f'https://www.blockonomics.co/api/balance'
    headers = {'Authorization': f'Bearer {api_key}',
               'Content-Type': 'application/json'}
    payload = {'addr': wallet_address2}
    r = requests.post(url, headers=headers, json=payload)

    # Check if the request was successful
    if r.status_code != 200:
        # There was an error with the request
        return f"Error: {r.text}"

    # Get the balance in satoshis
    data = r.json()['response'][0]['confirmed']

    # Convert the balance from satoshis to BTC
    btc_balance = data / 100000000

    # Return the balance
    return f"The balance of the wallet is {btc_balance} BTC"

# Function for leds blink
def blink_led():
    global flag3
    # Set the flag to True
    flag3 = True
    while flag3:
        # Blink the LED
        GPIO.output(11, GPIO.HIGH)
        time.sleep(0.5)
        GPIO.output(11, GPIO.LOW)
        time.sleep(0.5)

# Function for security
def read_chat_ids():
    with open('/home/pi/chat_ids.txt', 'r') as f:
        chat_ids = [int(line.strip()) for line in f]
    return chat_ids

def message_received(update, context):
    chat_id = update.message.chat_id
    allowed_chat_ids = read_chat_ids()
    if chat_id in allowed_chat_ids:
        command = update.message.text
        print('Got command: %s' % command)

        global flag1
        global flag2
        global flag3
        global flag4
        global flag5
        if command == '/who':
            run = subprocess.run(['whoami'], capture_output=True)
            context.bot.send_message(chat_id, run.stdout.decode())
        elif command == '/tailsup':
            run = subprocess.run(['sudo tailscale up'], capture_output=True)
            context.bot.send_message(chat_id, run.stdout.decode())
        elif command == '/walletcheck':
            # Set the flag to True
            flag4 = True
            context.bot.send_message(chat_id, 'Enter a bitcoin wallet address')
        elif flag4:
            wallet_address2 = command
            balance = check_wallet_balance(wallet_address2, api_key)
            context.bot.send_message(chat_id, balance)
            # Reset the flag to False
            flag4 = False
        elif command == '/wallet':
            send_btc_balance(bot, chat_id, wallet_address, api_key)
        elif command == '/walletusd':
            send_btc_value(bot, chat_id, wallet_address, api_key)
        elif command == '/generate': 
            btc_gen = make_btc_address()
            context.bot.send_message(
                chat_id,btc_gen)  
        elif command == '/checkadd':
            # Set the flag to True
            flag5 = True
            context.bot.send_message(chat_id, 'Enter the private key to check')
        elif flag5:
            check_address2 = command
            check = check_private_key(check_address2)
            context.bot.send_message(chat_id, check)
            # Reset the flag to False
            flag5 = False
        elif command == '/btc':
            btc_price = get_btc_price()
            context.bot.send_message(
                chat_id, f'The current price of BTC in USD is: ${btc_price:.0f} USD')
        elif command == '/mywallet':
            my_wallet = wallet_address 
            context.bot.send_message(
                chat_id, f'The public address of your wallet is:{my_wallet}')
        elif command == '/ping':
            # Set the flag to True
            flag1 = True
            context.bot.send_message(chat_id, 'Which IP do you want to ping?')
        elif flag1:
            # Ping the specified IP
            ip = command
            run = subprocess.run(['ping', '-c', '3', ip], capture_output=True)
            context.bot.send_message(chat_id, run.stdout.decode())
            # Reset the flag to False
            flag1 = False
        elif command == '/sudo':
            # Set the flag to True
            flag2 = True
            context.bot.send_message(chat_id, 'Type your cmd')
        elif flag2:
            sudo2 = command.split()
            run = subprocess.run(['sudo'] + sudo2, capture_output=True)
            context.bot.send_message(chat_id, run.stdout.decode())
            # Reset the flag to False
            flag2 = False
        elif command == '/ledon':
            GPIO.output(11, GPIO.HIGH)
            context.bot.send_message(chat_id, 'LED turned on')
        elif command == '/ledoff':
            GPIO.output(11, GPIO.LOW)
            context.bot.send_message(chat_id, 'LED turned off')
        elif command == '/blinkon':
            # Start the LED blinking in a new thread
            thread = threading.Thread(target=blink_led)
            thread.start()
            context.bot.send_message(chat_id, 'LED blinking started')
        elif command == '/blinkoff':
            # Set the flag to False to stop the LED from blinking
            flag3 = False
            GPIO.output(11, GPIO.LOW)
            context.bot.send_message(chat_id, 'LED stopped blinking')
        elif command == '/fanon':
            context.bot.send_message(chat_id, 'FAN turned on', on(12))
        elif command == '/fanoff':
            context.bot.send_message(chat_id, 'FAN turned off', off(12))
        elif command == '/model':
            run = subprocess.run(
                ['cat', '/proc/device-tree/model'], capture_output=True)
            context.bot.send_message(chat_id, run.stdout.decode())
        elif command == '/time':
            run = subprocess.run(
                ['date'], capture_output=True)
            context.bot.send_message(chat_id, run.stdout.decode())
        elif command == '/uptime':
            run = subprocess.run(['uptime', '-p'], capture_output=True)
            context.bot.sendMessage(chat_id, run.stdout.decode()[2:])
        elif command == '/where':
            run = subprocess.run(
                ["""curl https://extreme-ip-lookup.com/json/?key=ACJdcEKqljZrmlXp1GZA | jq -r '.country' | tr '[:lower:]' '[:upper:]'"""], shell=True, capture_output=True)
            context.bot.sendMessage(chat_id, run.stdout.decode())
        elif command == '/hd':
            run = subprocess.run(
                ["""df -h | grep "/$" | awk '{ print $5 }'"""], shell=True, capture_output=True)
            context.bot.sendMessage(
                chat_id, text='SD HD Used: ' + run.stdout.decode('utf-8'))
        elif command == '/volts':
            run = subprocess.run(
                ["""vcgencmd measure_volts $id | awk '{print substr($0, 6, length($0) - 9),"V"}'"""], shell=True, capture_output=True)
            context.bot.sendMessage(
                chat_id, text='Volts Used: ' + run.stdout.decode('utf-8'))
        elif command == '/speed':
            context.bot.send_message(chat_id, 'Be Patient Speed Test Started')
            run = subprocess.run(['speedtest-cli --simple'],
                                 shell=True, capture_output=True)
            context.bot.sendMessage(
                chat_id, text='Speed Test: ' + run.stdout.decode('utf-8'))
        elif command == '/cpughz':
            run = subprocess.run(
                ["""vcgencmd measure_clock arm | awk ' BEGIN { FS="=" } ; { printf( $2 / 1000000000) } '"""], shell=True, capture_output=True)
            context.bot.sendMessage(
                chat_id, text='CPU : ' + run.stdout.decode('utf-8')[:3] + 'GHz')
        elif command == '/cpu':
            run = subprocess.run(
                ["""vmstat 1 2 | tail -1 | awk '{print $13}' | tr -d '\n'"""], shell=True, capture_output=True)
            context.bot.sendMessage(
                chat_id, text='CPU% : ' + run.stdout.decode('utf-8')[:3] + '%')
        elif command == '/macchange':
            run = subprocess.run(
                ['sudo python3 /home/pi/mymacchanger.py'], shell=True, capture_output=True)
        elif command == '/eth0':
            run = subprocess.run(
                ["""ip link show eth0 | awk '/ether/ {print $2}'"""], shell=True, capture_output=True)
            context.bot.sendMessage(
                chat_id, text='Mac Eth0: ' + run.stdout.decode('utf-8'))
        elif command == '/wlan0':
            run = subprocess.run(
                ["""ip link show wlan0 | awk '/ether/ {print $2}'"""], shell=True, capture_output=True)
            context.bot.sendMessage(
                chat_id, text='Mac Wlan0: ' + run.stdout.decode('utf-8'))
        elif command == '/wanip':
            run = subprocess.run(['curl ifconfig.co'],
                                 shell=True, capture_output=True)
            context.bot.sendMessage(
                chat_id, text='Public IP: ' + run.stdout.decode('utf-8'))
        elif command == '/lanip':
            run = subprocess.run(
                ['hostname -I'], shell=True, capture_output=True)
            context.bot.sendMessage(
                chat_id, text='Local IP: ' + run.stdout.decode('utf-8'))
        elif command == '/hdex':
            run = subprocess.run(
                ["""df -h | grep "/dev/sd" | awk '{print$5}'"""], shell=True, capture_output=True)
            context.bot.sendMessage(
                chat_id, text='External HD Used: ' + run.stdout.decode('utf-8'))
        elif command == '/htop':
            run = subprocess.run(['ps -e --sort -%mem | head -10'],
                                 shell=True, capture_output=True)
            context.bot.sendMessage(chat_id, text='Proccese Running: '
                                    + run.stdout.decode('utf-8'))
        elif command == '/temp':
            run = \
                subprocess.run(['cat /sys/class/thermal/thermal_zone0/temp'
                                ], shell=True, capture_output=True)
            context.bot.sendMessage(chat_id, text='Temperature: '
                                    + str(int(run.stdout.decode('utf-8'
                                                                )) / 1000)[:-4] + 'C')
        elif command == '/sync':
            run = \
                subprocess.run(["""bitcoin-cli -rpcuser=USER -rpcpassword=PASS getblockchaininfo 2> /dev/null  | jq -r '.verificationprogress' | awk '{print 100 * $1}'"""
                                ], shell=True, capture_output=True)
            context.bot.sendMessage(chat_id,
                                    text='Blockchain Sync is at: '
                                    + run.stdout.decode('utf-8')[:4]
                                    + '%')
        elif command == '/Fuck':
            context.bot.sendMessage(chat_id, 'Are you from NYC ?')
        elif command == '/guide':
            context.bot.sendMessage(chat_id, '/help: Shows you all the commands available\n '
                                    '/reboot: Reboots the device\n '
                                    '/shutdown: Shuts down the device\n '
                                    '/time: Shows the device time\n '
                                    '/startminer: Starts the BTC miner\n '
                                    '/stopminer: Stops the BTC miner\n '
                                    '/btc: Shows the current value of BTC in USD\n '
                                    '/wallet: Shows the current balance of your BTC wallet\n'
                                    '/mywallet: Shows the current wallet public address\n'
                                    '/walletusd: Shows the current value in USD of your wallet\n '
                                    '/walletcheck: Checks the wallet balance of your choice\n'
                                    '/generate: Generates Public / Private key set\n' 
                                    '/checkadd: Checks Validity of BTC Address\n'
                                    '/fanon: Turns the fan on\n '
                                    '/fanoff: Turns the fan off\n '
                                    '/ledon: Turns LED on\n '
                                    '/ledoff: Turns LED off\n '
                                    '/blinkon: Turns LED on Blinking mode\n '
                                    '/blinkoff: Turns LED off Blinking mode\n '
                                    '/eth0: Shows Eth0 Mac address\n '
                                    '/wlan0: Shows Wlan0 Mac address\n '
                                    '/macchange: Changes the wlan Mac address\n'
                                    '/ping: Promts for ping IP or Domain & gives you results\n '
                                    '/sudo: Prompts for sudo cmd and then executes it\n '
                                    '/htop: Runs htop limited to top processes\n '
                                    '/sync: Shows Blockchain Sync state in percentage \n '
                                    '/model: Shows device model \n '
                                    '/uptime: Shows device uptime \n '
                                    '/where: Shows country location of device based on ip \n '
                                    '/who: Shows user \n '
                                    '/hd: Shows percent usage of SD card \n '
                                    '/hdex: Shows percent usage exterior usb connected HD \n '
                                    '/volts: Shows energy usage of device \n '
                                    '/speed: Runs a speed test \n '
                                    '/cpughz: Shows Ghz cpu usage \n '
                                    '/cpu: Shows cpu usage in percentage \n '
                                    '/wanip: Shows public IP \n '
                                    '/lanip: Shows local network IP \n '
                                    '/temp: Shows device temperature \n '
                                    )
        elif command == '/help':
            context.bot.sendMessage(chat_id,
                                    '/start /help /guide /reboot /shutdown /time /startminer /stopminer /walletcheck /btc '
                                    '/wallet /mywallet /generate /checkadd /walletusd /fanon /fanoff /ledon /ledoff /blinkon /blinkoff /eth0 /wlan0 '
                                    '/macchange /ping /sudo /htop /sync /model /uptime /where /who /hd /hdex '
                                    '/volts /speed /cpughz /cpu /wanip /lanip /temp '
                                    )
        elif command == '/start':
            context.bot.sendMessage(chat_id,
                                    '/start /help / guide /reboot /shutdown /time /startminer /stopminer /walletcheck /btc '
                                    '/wallet /mywallet /generate /checkadd /walletusd /fanon /fanoff /ledon /ledoff /blinkon /blinkoff /eth0 /wlan0 '
                                    '/macchange /ping /sudo /htop /sync /model /uptime /where /who /hd /hdex '
                                    '/volts /speed /cpughz /cpu /wanip /lanip /temp '
                                    )
        elif command == '/reboot':
            context.bot.sendMessage(chat_id, 'Rebooting Now !')
            os.system('sudo reboot')
        elif command == '/shutdown':
            context.bot.sendMessage(chat_id, 'Shutting Down Now !')
            os.system('sudo shutdown')
        elif command == '/startminer':
            context.bot.sendMessage(chat_id, 'Miner Started !')
            os.system('sudo systemctl start bfgminer.service')
        elif command == '/stopminer':
            context.bot.sendMessage(chat_id, 'Miner Stopped !')
            os.system('sudo systemctl stop bfgminer.service')
        else:
            context.bot.send_message(chat_id, 'Try /help')
    else:
        # Send a message to the user telling them they are not authorized
        context.bot.send_message(chat_id=chat_id, text='Unauthorized Access')

updater = Updater(token=TOKEN, use_context=True)
dispatcher = updater.dispatcher
dispatcher.add_handler(MessageHandler(Filters.text, message_received))
updater.start_polling()
updater.idle(
