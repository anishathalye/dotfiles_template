;; This script exports events located in my org journal files to an
;; ICS file and then uploads to an S3 bucket. It relies on AWS-CLI
;; and org-journal. 

;; This prevents yes-or-no prompts, came from here:
;; https://stackoverflow.com/a/59509250/1190586
(defmacro without-yes-or-no (&rest body)
  "Override `yes-or-no-p' & `y-or-n-p',
not to prompt for input and return t."
  (declare (indent 1))
  `(cl-letf (((symbol-function 'yes-or-no-p) (lambda (&rest _) t))
             ((symbol-function 'y-or-n-p) (lambda (&rest _) t)))
    ,@body))


;; I installed org-journal as a subodule
(add-to-list 'load-path "~/.dotfiles/org-journal/")

(require 'org-journal)

(with-eval-after-load 'org-journal
  (setq org-journal-dir "~/org/journal/") ;; not sure this is needed
  (setq org-agenda-files '("~/org/journal")) ;; this is needed!
  (setq org-journal-file-type 'weekly)
  (setq org-journal-file-format "%Y-%m-%d.org")
  (setq org-icalendar-store-UID t
        org-icalendar-combined-name "Org Events"
        org-icalendar-timezone "America/Los_Angeles"
        org-icalendar-date-time-format ";TZID=%Z:%Y%m%dT%H%M%S"
        org-icalendar-include-todo "all"
        org-icalendar-use-deadline '(todo-due)
        org-icalendar-use-scheduled '(todo-start)
        org-icalendar-combined-agenda-file "./org-events.ics")
  (setq org-agenda-file-regexp "\\`\\([^.].*\\.org\\|[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\.org\\(\\.gpg\\)?\\)\\'"))

(message "Starting export...")
(without-yes-or-no
 (org-icalendar-combine-agenda-files))  ; export the ICS file
(message "Finished exporting events to ICS file.")
(save-buffers-kill-emacs t)           ; save all modified files and exit

