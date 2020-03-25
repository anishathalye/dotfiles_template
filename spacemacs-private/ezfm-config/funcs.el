(defun notespace/compute-note-at-this-line ()
  (interactive)
  (save-buffer)
  (cider-interactive-eval
   (concat "(notespace.v2.note/compute-note-at-line! "
           (number-to-string (count-lines 1 (point)))
           ")")
   (cider-interactive-eval-handler nil (point))
   nil
   nil))

(defun notespace/compute-this-notespace ()
  (interactive)
  (save-buffer)
  (cider-interactive-eval
   "(notespace.v2.note/compute-this-notespace!)"
   (cider-interactive-eval-handler nil (point))
   nil
   nil))
