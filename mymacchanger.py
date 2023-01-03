import random
import subprocess

# Generate a random MAC address for wlan0
while True:
  random_mac_wlan0 = [random.randint(0x00, 0xff) for _ in range(6)]
  new_mac_wlan0 = ':'.join(map(lambda x: '%02x' % x, random_mac_wlan0))

  # Check if the MAC address is a valid unicast address
  first_byte = int(new_mac_wlan0.split(":")[0], 16)
  if (first_byte & 1) == 0:
    # The first byte is even, so the MAC address is likely a unicast address
    break

# Generate a random MAC address for eth0
while True:
  random_mac_eth0 = [random.randint(0x00, 0xff) for _ in range(6)]
  new_mac_eth0 = ':'.join(map(lambda x: '%02x' % x, random_mac_eth0))

  # Check if the MAC address is a valid unicast address
  first_byte = int(new_mac_eth0.split(":")[0], 16)
  if (first_byte & 1) == 0:
    # The first byte is even, so the MAC address is likely a unicast address
    break

# Bring the interfaces down
subprocess.call("ifconfig wlan0 down", shell=True)
subprocess.call("ifconfig eth0 down", shell=True)

# Set the MAC addresses
subprocess.call("ifconfig wlan0 hw ether " + new_mac_wlan0, shell=True)
subprocess.call("ifconfig eth0 hw ether " + new_mac_eth0, shell=True)

# Bring the interfaces up
subprocess.call("ifconfig wlan0 up", shell=True)
subprocess.call("ifconfig eth0 up", shell=True)

# Print the new MAC addresses
print("New Mac address wlan0: " + new_mac_wlan0)
print("New Mac address eth0: " + new_mac_eth0)
