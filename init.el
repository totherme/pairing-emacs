;; Save any interactively-made changes to a file that's in the
;; .gitignore
(setq custom-file "~/.emacs.d/emacs-custom.el")

;; Make windows-like shortcuts do what most folks expect
(cua-mode 1)

;; Get packages from melpa-stable
(require 'package)
(add-to-list 'package-archives
	     '("melpa-stable" . "http://stable.melpa.org/packages/") t)
(package-initialize)

;; Start git or a shell with a single keypress
(package-install 'magit)
(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-x M-m") 'shell)

;; Make magit (the git UI) work properly with git-duet
(defcustom git-duet-enabled "best-guess"
  "Whether or not to use git duet-commit instead of git commit."
  :group 'git-duet
  :type '(choice (const "best-guess") (const "enabled") (const "disabled")))

(advice-add 'magit-run-git-with-editor :around
            'magit-run-git-with-editor--git-duet)

(defun magit-run-git-with-editor--git-duet (fn &rest args)
  "Wrap magit-run-git-with-editor to use 'duet-commit' instead of 'commit'.

You should pass magit-run-git-with-editor as FN, and any
remaining args as ARGS."
    (if (and (git-duet-should-we-use-it?)
	     (equal (car args) "commit"))
	(apply fn "duet-commit" (cdr args))
      (apply fn args)))

(defun git-duet-should-we-use-it? ()
  "Decide whether or not to use git-duet.

First check the customizable variable git-duet-enabled. If set to
\"enabled\" then yes. If set to \"disabled\" then no. If set to
\"best-guess\", try to guess the best option using
git-duet-available"
  (or   (equal git-duet-enabled "enabled")
	(and     (equal git-duet-enabled "best-guess")
		  (git-duet-available))))

(defun git-duet-available ()
  "Guess whether git-duet is available on this machine by
checking for a duet section in ~/.gitconfig"
  (with-temp-buffer
    (insert-file "~/.gitconfig")
    (search-forward "[duet \"env\"]" (point-max) t)))

;; Display line numbers
(unless window-system
  (setq linum-format "%3d \u2502 "))
(global-linum-mode)

;; If shellcheck is in the $PATH, we should use it when we're editing
;; shell scripts
(package-install 'flycheck)
(add-hook 'sh-mode-hook 'flycheck-mode)

;; Enable autocompletion
(package-install 'company-go)
(add-hook 'after-init-hook 'global-company-mode)
(setq company-tooltip-limit 20)		; bigger popup window
(setq company-idle-delay .2) ; decrease delay before autocompletion popup shows
(global-set-key (kbd "C-c C-n") 'company-complete)
(global-set-key (kbd "C-c M-n") 'company-complete)

;; Disable company mode when writing plain text, unless you ask for it
;; with C-c C-n or C-c M-n
(add-hook 'text-mode-hook (lambda () 
			    (set (make-local-variable 'company-idle-delay) nil)))

;; Enable on-the-fly syntax and type checking for go files
(package-install 'go-mode)
(add-to-list 'load-path "~/.emacs.d/goflymake")
(require 'go-flymake)
(add-hook 'go-mode-hook 'flymake-mode)
(package-install 'go-eldoc)
(add-hook 'go-mode-hook 'go-eldoc-setup)

;; Enable golang snippits
(package-install 'yasnippet)
(require 'yasnippet)
(add-to-list 'yas-snippet-dirs  "~/.emacs.d/yasnippet-go")
(yas-global-mode)

;; Enable autocompletion for golang
(defun my-company-go-backend ()
                         (set (make-local-variable 'company-backends) '(company-go))
                          (company-mode))
(add-hook 'go-mode-hook 'my-company-go-backend)

;; Use goimports instead of gofmt. It's just better.
(setq gofmt-command "goimports")
;; ...and gofmt when we save
(add-hook 'before-save-hook 'gofmt-before-save)

;; Set some keybindings for use in golang files
(defun my-go-keybindings ()
  ;; Use M-. (which means Alt-. on practically all keyboards these
  ;; days) for "go to definition" in go files.
  (local-set-key (kbd "M-.") 'godef-jump)
  ;; Use C-c m to trigger a go format
  (local-set-key (kbd "C-c m") 'gofmt)
  ;; Use C-c C-e to ask what compile error is under point
  (local-set-key (kbd "C-c C-e") 'flymake-popup-current-error-menu))
(add-hook 'go-mode-hook 'my-go-keybindings)

;; Move the cursor basically anywhere by mashing the j key
;; (potentially along with some other key)
(package-install 'key-chord)
(package-install 'ace-jump-mode)
(package-install 'ace-window)
(key-chord-mode t)
(key-chord-define-global "jj" 'ace-jump-word-mode)
(key-chord-define-global "jl" 'ace-jump-line-mode)
(key-chord-define-global "jw" 'ace-window)

;; Enable fancy multiple-cursor editing
(package-install 'multiple-cursors)
(require 'multiple-cursors)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

;; Use the powerful and intuitive undo-tree instead of powerful but
;; confusing default undo ring
(package-install 'undo-tree)
(global-undo-tree-mode)
;; Force undo-tree and linum mode to play nice -- stolen from
;; https://www.emacswiki.org/emacs/UndoTree
(defun undo-tree-visualizer-update-linum (&rest args)
    (linum-update undo-tree-visualizer-parent-buffer))
(advice-add 'undo-tree-visualize-undo :after #'undo-tree-visualizer-update-linum)
(advice-add 'undo-tree-visualize-redo :after #'undo-tree-visualizer-update-linum)
(advice-add 'undo-tree-visualize-undo-to-x :after #'undo-tree-visualizer-update-linum)
(advice-add 'undo-tree-visualize-redo-to-x :after #'undo-tree-visualizer-update-linum)
(advice-add 'undo-tree-visualizer-mouse-set :after #'undo-tree-visualizer-update-linum)
(advice-add 'undo-tree-visualizer-set :after #'undo-tree-visualizer-update-linum)

;; Make backup file behaviour more sensible
(setq
   backup-by-copying t      ; don't clobber symlinks
   backup-directory-alist
    '(("." . "~/.saves"))    ; don't litter my fs tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
   version-control t)       ; use versioned backups

;; Make dired (directory editing) behaviour more sensible
(require 'wdired)
(setq
 dired-dwim-target t
 wdired-allow-to-change-permissions t)

;; Make autocompletion friendlier.
(ido-mode)
(setq ido-auto-merge-work-directories-length -1)

;; If we're in a terminal, we should allow terminal-mouse stuff
(unless window-system
  (xterm-mouse-mode))

;; Make markdown and yaml editing nice
(package-install 'markdown-mode)
(package-install 'yaml-mode)

