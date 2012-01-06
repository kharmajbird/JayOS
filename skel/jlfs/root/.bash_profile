# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin
ADDFLAG=/tmp/.addons
export PATH

if [ ! -f $ADDFLAG ]; then
    for i in `cat /proc/cmdline`; do
        case $i in
            addons)
                /initrd/bin/busybox rune /dev/ram1| \
                    /usr/bin/aespipe -d -e aes128| \
                    tar jxvf - -C / >/dev/null 2>&1

                if [ $? -eq 0 ]; then
                    /addonsrc 2>/dev/null
                    rm -f /addonsrc
                    touch $ADDFLAG
                fi
                ;;
        esac
    done
fi

if [ -z "$DISPLAY" ] && [ $(tty) == /dev/tty1 ]; then
  startx
fi

cat /etc/issue
