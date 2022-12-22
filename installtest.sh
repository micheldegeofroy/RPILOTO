crontab -u pi -r
sudo passwd -l root
sudo shutdown -r +3 "Install Script // Reboot in 3 min"
mkdir done.sh
rm installtest.sh
rm loader.sh
