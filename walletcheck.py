import requests
import time
import os

api_key = 'KR9NNX9cXq9KIiowcoDWaHKHsVakW1ZNoH0zWied5S8'
wallet_address = '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa'
TOKEN = '5564114282:AAGSjjJkjNH7RB-4dUH-aJW1pMmquFEq-m8'
ADMIN_ID = 90423887

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

# Unhash to debug Check the balance every 40 seconds
#while True:
#    check_balance()
#    time.sleep(40)
