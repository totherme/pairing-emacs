;; Save any interactively-made changes to a file that's in the
;; .gitignore
(setq custom-file "~/.emacs.d/emacs-custom.el")

(org-babel-load-file "~/.emacs.d/configs/basics.org")

(org-babel-load-file "~/.emacs.d/configs/magit.org")

(org-babel-load-file "~/.emacs.d/configs/programming.org")

(org-babel-load-file "~/.emacs.d/configs/internetting.org")
