(defun cider-interactive-notify-and-eval (code)
  (interactive)
  (message code)
  (cider-interactive-eval
   code
   (cider-interactive-eval-handler nil (point))
   nil
   nil))

(defun notespace/eval-and-realize-note-at-this-line ()
  (interactive)
  (save-buffer)
  (cider-interactive-notify-and-eval
   (concat "(notespace.api/eval-and-realize-note-at-line "
           (number-to-string (line-number-at-pos))
           ")")))

(defun notespace/eval-and-realize-notes-from-this-line ()
  (interactive)
  (save-buffer)
  (cider-interactive-notify-and-eval
   (concat "(notespace.api/eval-and-realize-notes-from-line "
           (number-to-string (line-number-at-pos))
           ")")))

(defun notespace/eval-and-realize-notes-from-change ()
  (interactive)
  (save-buffer)
  (cider-interactive-notify-and-eval
   (concat "(notespace.api/eval-and-realize-notes-from-change)")))

(defun notespace/init-with-browser ()
  (interactive)
  (save-buffer)
  (cider-interactive-notify-and-eval
   (concat "(notespace.api/init-with-browser)")))

(defun notespace/init ()
  (interactive)
  (save-buffer)
  (cider-interactive-notify-and-eval
   (concat "(notespace.api/init)")))

(defun notespace/eval-this-notespace ()
  (interactive)
  (save-buffer)
  (cider-interactive-notify-and-eval
   "(notespace.api/eval-this-notespace)"))

(defun notespace/eval-and-realize-this-notespace ()
  (interactive)
  (save-buffer)
  (cider-interactive-notify-and-eval
   "(notespace.api/eval-and-realize-this-notespace)"))

(defun notespace/render-static-html ()
  (interactive)
  (cider-interactive-notify-and-eval
   "(notespace.api/render-static-html)"))
