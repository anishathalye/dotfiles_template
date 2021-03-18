;; suggested emacs key binding (thanks @mchampine)
(add-hook 'clojure-mode-hook
  (lambda ()
    (define-key clojure-mode-map (kbd "C-c n e") 'notespace/eval-this-notespace)
    (define-key clojure-mode-map (kbd "C-c n r") 'notespace/eval-and-realize-this-notespace)
    (define-key clojure-mode-map (kbd "C-c n n") 'notespace/eval-and-realize-note-at-this-line)
    (define-key clojure-mode-map (kbd "C-c n f") 'notespace/eval-and-realize-notes-from-this-line)
    (define-key clojure-mode-map (kbd "C-c n i b") 'notespace/init-with-browser)
    (define-key clojure-mode-map (kbd "C-c n i i") 'notespace/init)
    (define-key clojure-mode-map (kbd "C-c n s") 'notespace/render-static-html)
    (define-key clojure-mode-map (kbd "C-c n c") 'notespace/eval-and-realize-notes-from-change)))

;; suggested spacemacs key bindings:
(spacemacs/set-leader-keys-for-major-mode 'clojure-mode
  "n e" 'notespace/eval-this-notespace
  "n r" 'notespace/eval-and-realize-this-notespace
  "n n" 'notespace/eval-and-realize-note-at-this-line
  "n f" 'notespace/eval-and-realize-notes-from-this-line
  "n i b" 'notespace/init-with-browser
  "n i i" 'notespace/init
  "n s" 'notespace/render-static-html
  "n c" 'notespace/eval-and-realize-notes-from-change)
