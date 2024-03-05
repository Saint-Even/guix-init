# guix-init

# set UEFI to boot from USB
       at boot: [fn][F12...]
       reset to defaults
       reboot with standared guixSD image on stick
       at boot: [fn][F12...]
       choose usb
       at blue screen: [ctl][alt][fn][F3]

# setup eth connection
       ifconfig -a
       ifconfig eno1 up
       dhclient -v eno1
       ping -c 3 gnu.org

# clone init files (shell)
       guix install git
       cd ~
       git config --global http.sslVerify false
       git clone "https://github.com/Saint-Even/guix-init.git"
       #follow these instructions.txt
