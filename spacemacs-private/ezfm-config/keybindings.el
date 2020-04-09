;; Keybindings for scicloj/notespace
(add-hook 'clojure-mode-hook
          (lambda ()
            (local-set-key "\C-cy" 'notespace/compute-note-at-this-line)
            (local-set-key "\C-cu" 'notespace/compute-this-notespace)))

;; Trying this out - might work better w/ minivan keyboard
(define-key evil-insert-state-map (kbd "C-;") 'evil-normal-state)
