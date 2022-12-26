#!/bin/bash

# Read the first and second line of the botdata.txt file
replace_value1=$(head -n 1 botdata.txt)
replace_value2=$(tail -n +2 botdata.txt | head -n 1)

# Replace the target value in the Bot.py script with the replacement values from botdata.txt
sed -i "s/replacewithyourbottoken/$replace_value2/g" /Bots/Bot.py 
sed -i "s/replacewithadminchatid/$replace_value1/g" /Bots/Bot.py

# Confirm that the replacement has been made
echo "The Admin User Chat ID and Bot Token have been set in Bot.py file."
