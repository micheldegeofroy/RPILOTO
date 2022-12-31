import requests
import time
import os
import RPi.GPIO as GPIO
import threading

flag = False

#Replace with https://www.blockonomics.co API key
api_key = 'replacewithyourapikey'

# Replace 1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa with the actual address of your Bitcoin wallet yourbtcwalletaddress 
wallet_address = '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa'

# Replace this with your telegram bot bot token
TOKEN = 'replacewithyourbottoken'

# Replace with the chat ID of the telegram Admin
ADMIN_ID = replacewithadminchatid

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

# Function for leds blink
def blink_led():
    global flag
    # Set the flag to True
    flag = True
    while flag:
        # Blink the LED
        GPIO.output(11, GPIO.HIGH)
        time.sleep(0.5)
        GPIO.output(11, GPIO.LOW)
        time.sleep(0.5)

def check_balance():
    # Make a request to the blockonomics API to get the current balance of the Bitcoin wallet
    url = f'https://www.blockonomics.co/api/balance'
    headers = {'Authorization': f'Bearer {api_key}', 'Content-Type': 'application/json'}
    payload = {'addr': wallet_address}
    r = requests.post(url, headers=headers, json=payload)
    current_balance = r.json()['response'][0]['confirmed']

    # Read btcbalance 
    with open("btcbalance.txt", "r") as f:
        previous_balance_str = f.readline().strip()
        current_balance_str = f.readline().strip()
    previous_balance_from_file, current_balance_from_file = previous_balance_str.split(',')
    previous_balance_from_file = int(previous_balance_from_file)
    current_balance_from_file = int(current_balance_from_file)

    #Update btcbalance 
    with open("btcbalance.txt", "w") as f:
            f.write("{},{}".format(current_balance_from_file, current_balance))

    # Read btcbalance 
    with open("btcbalance.txt", "r") as f:
        previous_balance_str = f.readline().strip()
        current_balance_str = f.readline().strip()
    previous_balance_from_file, current_balance_from_file = previous_balance_str.split(',')
    previous_balance_from_file = int(previous_balance_from_file)
    current_balance_from_file = int(current_balance_from_file)

    current_balance_btc = current_balance_from_file / 100000000   
    previous_balance_btc = previous_balance_from_file / 100000000

    # Compare the current balance to the previous balance
    if current_balance_btc != previous_balance_btc:
        thread = threading.Thread(target=blink_led)
        thread.start()
        change = current_balance_btc - previous_balance_btc
        text = f"The balance of the BTC wallet has CHANGED !!! The previous value was {previous_balance_btc} BTC and the current value is {current_balance_btc} BTC The change in balance is {change} BTC"
        requests.get(f"https://api.telegram.org/bot{TOKEN}/sendMessage?chat_id={ADMIN_ID}&text={text}")
    else:
        requests.get(f"https://api.telegram.org/bot{TOKEN}/sendMessage?chat_id={ADMIN_ID}&text=The balance of the BTC wallet has NOT changed it is: {current_balance_btc} BTC the previous value was also: {previous_balance_btc} BTC")


# Check if the file exists
if not os.path.exists("btcbalance.txt"):
    # Create the file if it does not exist
    open("btcbalance.txt", "a").close()

# Check if file btc ballance is empty if yes Initialize 0,0
if os.stat("btcbalance.txt").st_size == 0:
    # Write to the file if it is empty
    with open("btcbalance.txt", "w") as f:
        f.write("0,0")

while True:
    check_balance()
    time.sleep(600)
