     (use-modules (gnu) (guix packages))
     (use-package-modules glib certs xdisorg xorg)
     (use-service-modules avahi base dbus desktop networking xorg)

     (operating-system
       (host-name "len")
       (locale "en_US.utf8")
       (timezone "Europe/Madrid")
       (users
        (cons*
         (user-account
          (name "main")
          (comment "Main user account")
          (group "users")
          (supplementary-groups '("wheel" "netdev" "audio" "video" "input")))
         %base-user-accounts))
       (keyboard-layout
        (keyboard-layout "us" "dvorak" #:options '("ctrl:swapcaps_hyper" "compose:ralt")))
       (bootloader
        (bootloader-configuration
         (bootloader grub-bootloader)
         (targets '("/dev/sda"))
         (keyboard-layout keyboard-layout)))
       (file-systems
        (cons*
         (file-system
           (mount-point "/")
           (device (file-system-label "system"))
           (type "ext4"))
         %base-file-systems))
       (packages
        (cons* dbus nss-certs sx xhost %base-packages))
       (services
        (cons* 	    
         (service dhcp-client-service-type)
         (service avahi-service-type)
         (elogind-service)
         (dbus-service)
         (service xorg-server-service-type
                  (xorg-configuration
                   (keyboard-layout keyboard-layout)))
         %base-services)))
