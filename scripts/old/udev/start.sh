touch /etc/auto.usb
service autofs restart
udevadm control --reload_rules
udevadm trigger
