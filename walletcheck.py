import requests
import time
import os
import RPi.GPIO as GPIO
import threading
import datetime
import subprocess

flag = False

flag = False

#Replace with https://www.blockonomics.co API key
api_key = 'replacewithyourapikey'

# Replace 1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa with the actual address of your Bitcoin wallet yourbtcwalletaddress 
wallet_address = '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa'

# Replace this with your telegram bot bot token
TOKEN = 'replacewithyourbottoken'

# Replace with the chat ID of the telegram Admin
ADMIN_ID = replacewithadminchatid

# LED control functions
def on(pin):
    GPIO.output(pin, GPIO.HIGH)

def off(pin):
    GPIO.output(pin, GPIO.LOW)

# Set up GPIO output channel
GPIO.setmode(GPIO.BOARD)
GPIO.setwarnings(False)
GPIO.setup(11, GPIO.OUT)

# Function for LED blink
def blink_led():
    global flag
    flag = True  # Set the flag to True
    while flag:
        GPIO.output(11, GPIO.HIGH)
        time.sleep(0.5)
        GPIO.output(11, GPIO.LOW)
        time.sleep(0.5)

def fetch_balance():
    """Fetch Bitcoin balance from Blockonomics API."""
    url = "https://www.blockonomics.co/api/balance"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    payload = {"addr": wallet_address}

    try:
        response = requests.post(url, headers=headers, json=payload, timeout=10)
        response.raise_for_status()  # Raise error for non-200 responses
        data = response.json()
        
        if "response" in data and len(data["response"]) > 0:
            return data["response"][0]["confirmed"]  # Balance in satoshis
        else:
            print("Error: Unexpected API response format.")
            return None
    except requests.exceptions.RequestException as e:
        print(f"API Request Failed: {e}")
        return None

def check_balance():
    """Check the Bitcoin wallet balance and notify if changed."""
    now = datetime.datetime.now()
    print(f"Current date and time: {now}")

    # Get system uptime
    uptime = subprocess.run(["uptime"], stdout=subprocess.PIPE).stdout.decode().strip()

    # Fetch current balance
    current_balance = fetch_balance()
    if current_balance is None:
        print("Error: Unable to fetch balance.")
        return

    # File path for balance tracking
    file_path = "/home/pi/Bots/btcbalance.txt"

    # Ensure the file exists
    if not os.path.exists(file_path):
        with open(file_path, "w") as f:
            f.write("0,0")

    # Read previous balance
    with open(file_path, "r") as f:
        previous_balance_str = f.readline().strip()

    try:
        previous_balance, _ = map(int, previous_balance_str.split(","))
    except ValueError:
        print("Error: Corrupt balance file. Resetting...")
        previous_balance = 0

    # Convert to BTC
    current_balance_btc = current_balance / 100000000
    previous_balance_btc = previous_balance / 100000000

    # Compare balances
    if current_balance != previous_balance:
        thread = threading.Thread(target=blink_led)
        thread.start()
        change = current_balance_btc - previous_balance_btc
        text = (f"BTC balance CHANGED! Previous: {previous_balance_btc} BTC, "
                f"Current: {current_balance_btc} BTC. Change: {change} BTC")
    else:
        text = f"BTC wallet UNCHANGED @ {current_balance_btc} BTC\nINFO: {uptime}"

    # Send Telegram notification
    requests.get(f"https://api.telegram.org/bot{TOKEN}/sendMessage?chat_id={ADMIN_ID}&text={text}")

    # Update balance file
    with open(file_path, "w") as f:
        f.write(f"{current_balance},{current_balance}")

# Run balance check every 24 hours
while True:
    check_balance()
    time.sleep(86400)
