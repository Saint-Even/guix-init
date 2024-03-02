(use-modules (gnu)
	     (gnu home)
	     (gnu home services)
	     (gnu home services shells)
	     (gnu services)
	     (guix gexp))

(home-environment
 (services (list
	    (service
	     home-bash-service-type
	     (home-bash-configuration
	      (guix-defaults? #t)
	      (environment-variables
	       ;; set bash history file location
	       '(("HISTFILE" . "~/.bash_history")))
	      ;; append extra-profiles to the guix generated ~/.bash-profile
	      (bash-profile (list (local-file "extra-profiles")))))
	    (simple-service
	     'home-config
	     home-files-service-type
	     (list
	      `(".config/emacs/init.el"
		,(local-file "emacs-init"))
	      ;; :recursive? #t for a file preserves file permissions, in this case
	      ;; the local file sx-config is executable
	      `(".config/sx/sxrc"
		,(local-file "sx-config" #:recursive? #t)))))))
