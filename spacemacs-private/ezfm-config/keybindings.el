;; Keybindings for scicloj/notespace
(add-hook 'clojure-mode-hook
          (lambda ()
            (local-set-key "\C-cy" 'notespace/compute-note-at-this-line)
            (local-set-key "\C-cu" 'notespace/compute-this-notespace)))
