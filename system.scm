     ;; complete XXX fields with data obtained from basic.scm (appended below)

     (use-modules 
       (gnu)
       (guix packages)
       (nongnu packages linux)
       (nongnu system linux-initrd))

     (use-package-modules 
       glib certs xdisorg xorg);bootloaders ccache certs cups databases emacs emacs-xyz fonts geo ghostscript gnome gnupg guile guile-xyz linux nano ntp python python-xyz ratpoison scanner screen ssh suckless tex version-control vim wm xorg gnuzilla

     (use-service-modules
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
       (timezone "XXX")
       (locale "XXX")
       (keyboard-layout
        (keyboard-layout "us"))

       ;; forgive me stallmann for I have sinned
       (kernel linux)
       (firmware (list linux-firmware))
       (initrd microcode-initrd)

       (bootloader XXX)

       (mapped-devices XXX)

       (file-systems XXX)

       (swap-devices XXX)

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
				  "docker"
				  "tty"
				  "lp" ;bluetooth devices
				  "input"
				  "audio"  
				  "video")))
         %base-user-accounts))

       (packages
        (cons* dbus
	       nss-certs ;for https access
	       git 
	       nano emacs-guix guile-wisp ;because that should always be at hand
	       vim 
	       openssh ;so that gnome ssh access works
	       cups foomatic-filters hplip sane-backends ijs ghostscript ;print and scan
	       ntp openntpd python-dbus fuse
	       emacs
	       ntfs-3g
	       exfat-utils
	       fuse-exfat
	       xterm
	       tree-sitter
	       screen
	       sbcl
	       python
	       nyxt
	       stumpwm
	       bluez
	       bluez-alsa
	       pulseaudio
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
         (service dhcp-client-service-type)
         (service avahi-service-type)
         (elogind-service)
         (dbus-service)
	 (service tlp-service type
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
	 ; allow substitutes from non-guix channel
	 (modify-services %desktop-services  
             (guix-service-type config => (guix-configuration
               (inherit config)
               (substitute-urls
                (append (list "https://substitutes.nonguix.org")
                  %default-substitute-urls))
               (authorized-keys
                (append (list (plain-file
				"non-guix.pub"
				"(public-key (ecc (curve Ed25519)
  (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
                  %default-authorized-guix-keys)))))
	 (modify-services %desktop-services
                           (gdm-service-type config =>
                                             (gdm-configuration (auto-suspend? #f)
                                                                (debug? #f))))
         %base-services))

       ;; Allow resolution of '.local' host names with mDNS
       (name-service-switch %mdns-host-lookup-nss))
