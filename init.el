;; Save any interactively-made changes to a file that's in the
;; .gitignore
(setq custom-file "~/.emacs.d/emacs-custom.el")

(org-babel-load-file "~/.emacs.d/basics.org")

(org-babel-load-file "~/.emacs.d/magit.org")

;; If shellcheck is in the $PATH, we should use it when we're editing
;; shell scripts
(use-package flycheck
  :ensure t
  :commands flycheck-mode
  :init
  (add-hook 'sh-mode-hook 'flycheck-mode))

;; If we want, we can use paredit in lisp buffers
(use-package paredit
  :ensure t
  :commands paredit-mode)

;; Enable autocompletion
(use-package company-go
  :ensure t
  :commands global-company-mode
  :init
  (add-hook 'after-init-hook 'global-company-mode)
  :config
  (setq company-tooltip-limit 20)		; bigger popup window
  (setq company-idle-delay .2) ; decrease delay before autocompletion popup shows
  (global-set-key (kbd "C-c C-n") 'company-complete)
  (global-set-key (kbd "C-c M-n") 'company-complete)

  ;; Disable company mode when writing plain text, unless you ask for it
  ;; with C-c C-n or C-c M-n
  (add-hook 'text-mode-hook (lambda () 
			      (set (make-local-variable 'company-idle-delay) nil))))

;; Setup all the golang magic
(use-package go-mode
  :ensure t
  :config
  (use-package go-flymake		; On-the-fly type checking
    :load-path "~/.emacs.d/goflymake")
  (add-hook 'go-mode-hook 'flymake-mode)
  (use-package go-eldoc			; On-the-fly docs
    :ensure t)
  (add-hook 'go-mode-hook 'go-eldoc-setup)

  ;; Enable autocompletion for golang
  (defun my-company-go-backend ()
    (set (make-local-variable 'company-backends) '(company-go))
    (company-mode))
  (add-hook 'go-mode-hook 'my-company-go-backend)

  ;; Use goimports instead of gofmt. It's just better.
  (setq gofmt-command "goimports")
  ;; ...and gofmt when we save
  (add-hook 'before-save-hook 'gofmt-before-save)

  (defun my-golang-introspect (event)
    "Move the point to the mouse, and try to do godef-jump.

For IDE-like code introspection on mouse events like Control-Click"
    (interactive "e")
    (mouse-set-point event)
    (godef-jump (point)))

  (defun my-do-nothing ()
    (interactive))

  ;; Set some keybindings for use in golang files
  (defun my-go-keybindings ()
    ;; Use M-. (which means Alt-. on practically all keyboards these
    ;; days) for "go to definition" in go files.
    (local-set-key (kbd "M-.") 'godef-jump)
    ;; Use C-c m to trigger a go format
    (local-set-key (kbd "C-c m") 'gofmt)
    ;; Use C-c C-e to ask what compile error is under point
    (local-set-key (kbd "C-c C-e") 'flymake-popup-current-error-menu)
    ;; Use Control-Click to "go to definition"
    (local-set-key (kbd "C-<mouse-1>") 'my-golang-introspect)
    (local-set-key (kbd "C-<down-mouse-1>") 'my-do-nothing))
  (add-hook 'go-mode-hook 'my-go-keybindings))

;; Enable golang snippits
(use-package yasnippet
  :ensure t
  :config
  (add-to-list 'yas-snippet-dirs  "~/.emacs.d/yasnippet-go")
  (yas-global-mode))


;; Make all this fancy golang stuff even when emacs has been started
;; from the OSX finder
(when (memq window-system '(mac ns))
  (use-package exec-path-from-shell
    :ensure t
    :config
    (exec-path-from-shell-initialize)
    (exec-path-from-shell-copy-env "GOPATH")
    (exec-path-from-shell-copy-env "PATH")))

;; Move the cursor basically anywhere by mashing the j key
;; (potentially along with some other key)
(use-package key-chord
  :ensure t
  :config
  (use-package avy
    :ensure t)
  (use-package ace-window
    :ensure t)
  (key-chord-mode t)
  (key-chord-define-global "jj" 'avy-goto-word-1)
  (key-chord-define-global "jl" 'avy-goto-line)
  (key-chord-define-global "jw" 'ace-window)
  (avy-setup-default))

;; Enable fancy multiple-cursor editing
(use-package multiple-cursors
  :ensure t
  :config
  (global-set-key (kbd "C->") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this))

;; Use the powerful and intuitive undo-tree instead of powerful but
;; confusing default undo ring
(use-package undo-tree
  :ensure t
  :config
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
  (advice-add 'undo-tree-visualizer-set :after #'undo-tree-visualizer-update-linum))

;; Make markdown and yaml editing nice
(use-package markdown-mode
  :ensure t)
(use-package yaml-mode
  :ensure t)

