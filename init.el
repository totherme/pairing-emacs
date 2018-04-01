;; Save any interactively-made changes to a file that's in the
;; .gitignore
(setq custom-file "~/.emacs.d/emacs-custom.el")

(org-babel-load-file "~/.emacs.d/configs/basics.org")

(org-babel-load-file "~/.emacs.d/configs/magit.org")

(org-babel-load-file "~/.emacs.d/configs/programming.org")

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
