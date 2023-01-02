import random
import subprocess

random_mac_wlan0 = [random.randint(0x00, 0xff) for _ in range(6)]
new_mac_wlan0 = ':'.join(map(lambda x: '%02x' % x, random_mac_wlan0))
subprocess.call("ifconfig wlan0 down", shell=True)
subprocess.call("ifconfig wlan0 hw ether " + new_mac_wlan0, shell=True)
subprocess.call("ifconfig wlan0 up", shell=True)

random_mac_eth0 = [random.randint(0x00, 0xff) for _ in range(6)]
new_mac_eth0 = ':'.join(map(lambda x: '%02x' % x, random_mac_eth0))
subprocess.call("ifconfig eth0 down", shell=True)
subprocess.call("ifconfig eth0 hw ether " + new_mac_eth0, shell=True)
subprocess.call("ifconfig eth0 up", shell=True)

print("New Mac address wlan0: " + new_mac_wlan0)
print("New Mac address eth0: " + new_mac_eth0)
