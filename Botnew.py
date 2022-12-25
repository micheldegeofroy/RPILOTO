import telegram
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters

# Replace this with your own bot token
TOKEN = "5564114282:AAGSjjJkjNH7RB-4dUH-aJW1pMmquFEq-m8"

def message_received(update, context):
    # Get the chat ID of the sender
    chat_id = update.message.chat_id
    # Read the list of allowed chat IDs
    allowed_chat_ids = read_chat_ids()
    # Check if the chat ID is in the list of allowed chat IDs
    if chat_id in allowed_chat_ids:
        # Get the message text and command
        command = update.message.text
        print('Got command: %s' % command)

        if command == '/who':
            run = subprocess.run(["whoami"], capture_output=True)
            context.bot.send_message(chat_id, run.stdout.decode())
        elif command == '/model':
            run = subprocess.run(["cat", "/proc/device-tree/model"], capture_output=True)
            context.bot.send_message(chat_id, run.stdout)
        else:
            context.bot.send_message(chat_id, 'Try /help')
    else:
        # Send a message to the user telling them to contact the admin
        context.bot.send_message(chat_id=chat_id, text='Unauthorized')

# Create the Updater and pass it the bot's token.
updater = Updater(TOKEN, use_context=True)

# Get the dispatcher to register handlers
dispatcher = updater.dispatcher

# Add a handler


import time
import random
import datetime
import telepot
from telepot.loop import MessageLoop
import subprocess
import re
import os
import telegram
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters

# Replace this with your own bot token
TOKEN = "5564114282:AAGSjjJkjNH7RB-4dUH-aJW1pMmquFEq-m8"

def read_chat_ids():
    with open('chat_ids.txt', 'r') as f:
        chat_ids = [int(line.strip()) for line in f]
    return chat_ids

def message_received(update, context):
    # Get the chat ID of the sender
    chat_id = update.message.chat_id
    # Read the list of allowed chat IDs
    allowed_chat_ids = read_chat_ids()
    # Check if the chat ID is in the list of allowed chat IDs
    if chat_id in allowed_chat_ids:
        # Get the message text and command
        command = update.message.text
        print('Got command: %s' % command)

        if command == '/who':
            run = subprocess.run(["whoami"], capture_output=True)
            bot.sendMessage(chat_id, run.stdout)
        elif command == '/model':
            run = subprocess.run(["cat", "/proc/device-tree/model"], capture_output=True)
            bot.sendMessage(chat_id, run.stdout)
        else:
            bot.sendMessage(chat_id, 'Try /help')
    else:
        # Send a message to the user telling them to contact the admin
        bot.send_message(chat_id=chat_id, text='Unauthorized')

# Create the bot and set up the message handler
bot = telepot.Bot(token=TOKEN)
MessageLoop(bot, message_received).run_as_thread()
print('I am listening ...')

# Run the bot indefinitely
while True:
    time.sleep(10)

