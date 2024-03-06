     ;; complete XXX fields with data obtained from basic.scm (appended below)

     (use-modules 
       (gnu) ;good
       (guix packages) ;good
       (nongnu packages linux) ;bad
       (nongnu system linux-initrd)) ;bad

     (use-package-modules 
       glib 
       wm ;for stumpwm
       version-control ;for git
       text-editors ;for nano
       emacs-xyz ;for emacs-guix
       emacs ;for emacs
       web-browsers ;for nyxt
       ssh ;for openssh
       vim ;for vim
       cups ;for cups
       scanner ;for sane-backends
       ghostscript ;for ijs
       ntp ;for nts
       python ;for python
       python-xyz ;for python-dbus
       tree-sitter ;for tree-sitter
       linux ;for fuse
       gnome ;for gvfs
       screen ;for screen
       lisp ;for sbcl
       file-systems ;for exfat-utils
       audio ;for bluez-alsa
       pulseaudio ;for pulseaudio
       sync ; for rclone
       terminals ; for tilix
       certs
       xdisorg 
       xorg);bootloaders ccache cups databases emacs fonts geo gnome gnupg guile guile-xyz nano ntp ssh suckless tex gnuzilla

     (use-service-modules
       pm ;for thermald-service-type
       avahi
       base
       mcron
       cups
       sysctl
       sound
       dbus
       desktop
       networking
       ssh
       docker
       xorg)

     (operating-system
       (host-name "lambda")
       (timezone "XXX")
       (locale "XXX")
       (keyboard-layout
        (keyboard-layout "us"))

       ;; forgive me stallmann for I have sinned
       (kernel linux)
       (firmware (list linux-firmware))
       (initrd microcode-initrd)

       (bootloader (XXX))
       (mapped-devices (XXX))
       (file-systems (XXX))
       (swap-devices (XXX))

       (users (cons*
         (user-account
          (name "user")
          (comment "generic-user")
          (group "users")
	  (home-directory "/home/user")
          (supplementary-groups '("wheel" ;;sudo
				  "netdev" ;;network devices
				  "kvm"
				  "tty"
				  "lp" ;bluetooth devices
				  "input"
				  "audio"  
				  "video")))
         %base-user-accounts))

       (packages
        (cons* dbus
	       nss-certs ;for https access
	       openssh ;so that gnome ssh access works
	       git 
	       nano 
	       emacs-guix ;guix package management from emacs
	       vim 
	       cups foomatic-filters hplip sane-backends ;print and scan
	       ijs ;inkjet
	       ghostscript ;print and scan
	       ntp ;RT clock sync
	       openntpd 
	       python-dbus ;python bindings for desktop-bus protocol
	       fuse ; user space file systems
	       emacs
	       ntfs-3g
	       exfat-utils ;flash memory file systems
	       fuse-exfat
	       xterm
	       tree-sitter
	       screen
	       sbcl
	       stumpwm 
	       rclone
	       tilix
	       nyxt
	       python
	       bluez ;bluetooth protocol
	       bluez-alsa ;bluetooth audio
	       pulseaudio ;audio server
	       tlp ;wireless?
	       xf86-input-libinput
	       gvfs ; for user mounts
	       sx
	       xhost
	       %base-packages))

       (services
        (cons*
	 (service lxqt-desktop-service-type)
	 (service gnome-desktop-service-type)
	 (service openssh-service-type)
	 (service docker-service-type)
	 (service thermald-service-type)
	 (service tlp-service-type ;power management service
	 	  (tlp-configuration
	 	    (cpu-boost-on-ac? #t)
	 	    (wifi-pwr-on-bat? #t)))
	 (service cups-service-type
	 	  (cups-configuration
	 	    (web-interface? #t)
	 	    (extensions
	 	      (list cups-filters))))
         (service xorg-server-service-type
                  (xorg-configuration
                   (keyboard-layout keyboard-layout)))

	 ;todo, fix ice-9 bug
	 ;(modify-services %desktop-services ;allow substitutes from non-guix channel
      	 ;	(guix-service-type config =>
         ;               (guix-configuration
         ;                 (inherit config)
         ;                 (substitute-urls
         ;                   (append (list "https://substitutes.nonguix.org")
         ;                           %default-substitute-urls))
         ;                 (authorized-keys
         ;                   (append (list (plain-file "non-guix.pub" "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
         ;                           %default-authorized-guix-keys)))))

	 ;(modify-services %desktop-services ;prevents suspend for ssh use
         ;                  (gdm-service-type config =>
         ;                                    (gdm-configuration (auto-suspend? #f)
         ;                                                       (debug? #f))))
         %desktop-services))

       ;; Allow resolution of '.local' host names with mDNS
       (name-service-switch %mdns-host-lookup-nss))
