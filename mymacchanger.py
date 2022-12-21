import random
import subprocess
random_mac = [random.randint(0x00, 0xff) for _ in range(6)]
new_mac = ':'.join(map(lambda x: '%02x' % x, random_mac))
subprocess.call("ifconfig wlan0 down", shell=True)
subprocess.call("ifconfig wlan0 hw ether " + new_mac, shell=True)
subprocess.call("ifconfig wlan0 up", shell=True)
print("New Mac address: " + new_mac)
