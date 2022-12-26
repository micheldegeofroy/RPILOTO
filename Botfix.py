if command == '/who':
        run = subprocess.run(["whoami"], capture_output=True)
        context.bot.send_message(chat_id, run.stdout.decode()) 
    elif command == '/onled':
        GPIO.output(11, GPIO.HIGH)
        context.bot.send_message(chat_id, "LED turned on")
    elif command == '/offled':
        GPIO.output(11, GPIO.LOW)
        context.bot.send_message(chat_id, "LED turned off")
    elif command == '/blink':
        for i in range(5):
            GPIO.output(11, GPIO.HIGH)
            time.sleep(0.5)
            GPIO.output(11, GPIO.LOW)
            time.sleep(0.5)
        context.bot.send_message(chat_id, "LED blinked")
    elif command == '/fanon':
        context.bot.sendMessage(chat_id, on(12))
    elif command =='/fanoff':
        context.bot.sendMessage(chat_id, off(12))
