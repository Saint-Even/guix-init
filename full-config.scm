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
       (host-name "guix")
       (timezone "America/Winnipeg")
       (locale "en_CA.utf8")
       (keyboard-layout
        (keyboard-layout "us"))

       ;; forgive me stallmann for I have sinned
       (kernel linux)
       (firmware (list linux-firmware))
       (initrd microcode-initrd)

  ;; Use the UEFI variant of GRUB with the EFI System
  ;; Partition mounted on /boot/efi.
  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets '("/boot/efi"))
                (keyboard-layout keyboard-layout)))

  ;; Specify a mapped device for the encrypted root partition.
  ;; The UUID is that returned by 'cryptsetup luksUUID'.
  (mapped-devices
   (list (mapped-device
          (source (uuid "be506786-63b6-4955-961d-a9c444550036"))
          (target "root-partition")
          (type luks-device-mapping))
	 (mapped-device
          (source (uuid "48dec2a1-ae4c-4965-93ca-e369a0302af2"))
          (target "home-partition")
          (type luks-device-mapping))))

  (file-systems (append
                 (list (file-system
                         (device (file-system-label "root-partition"))
                         (mount-point "/")
                         (type "ext4")
                         (dependencies mapped-devices))
		       (file-system
                         (device (file-system-label "home-partition"))
                         (mount-point "/home")
                         (type "ext4")
                         (dependencies mapped-devices))
                       (file-system
                         (device (uuid "D2B4-0D5D" 'fat))
                         (mount-point "/boot/efi")
                         (type "vfat")))
                 %base-file-systems))

  ;; Specify a swap partition for the system
  (swap-devices (list (swap-space
                       (target (uuid "43b8a075-1434-4aa9-9bef-9a85f86f1b1e")))))

       (groups (cons (user-group
		       (system? #t) 
		       (name "additional-group"))
		     %base-groups))

       (users (cons*
         (user-account
          (name "user")
          (comment "generic user")
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
	       ;'(,stupmwm "lib") ;for stumpwm ;!! source of error??
	       python
	       nyxt
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
	 (service openssh-service-type)
	 (service docker-service-type)
	 (service thermald-service-type)
         ; extra(service dhcp-client-service-type)
         ; extra(service avahi-service-type)
         ; extra(dbus-service)
         ;extra??(elogind-service)
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
