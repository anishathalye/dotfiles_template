;; This script exports events located in my org journal files to an
;; ICS file and then uploads to an S3 bucket. It relies on AWS-CLI
;; and org-journal. 

;; I installed org-journal as a subodule
(add-to-list 'load-path "../org-journal/")

(require 'org-journal)

(defvar s3-destination "s3://ezmiller/calendar/org-events.ics")

(with-eval-after-load 'org-journal
  (setq org-journal-dir "~/org/journal/")
  (setq org-agenda-files '("~/org/journal"))
  (setq org-journal-file-type 'weekly)
  (setq org-journal-file-format "%Y-%m-%d.org")
  (setq org-icalendar-store-UID t
        org-icalendar-combined-name "Org Events"
        org-icalendar-timezone "America/Los_Angeles"
        org-icalendar-date-time-format ";TZID=%Z:%Y%m%dT%H%M%S"
        org-icalendar-include-todo "all"
        org-icalendar-combined-agenda-file "./org-events.ics")
  (setq org-agenda-file-regexp "\\`\\([^.].*\\.org\\|[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\.org\\(\\.gpg\\)?\\)\\'"))

(message "Starting...")
(org-icalendar-combine-agenda-files)  ; export the ICS file
(message "Finished exporting events to ICS file.")
(message (format "Uploading ICS file to S3: %s" s3-destination) )
(shell-command-to-string (format "aws s3 cp ./org-events.ics %s --acl public-read" s3-destination))
(message "Cleaning up...")
(shell-command-to-string "rm ./org-events.ics")
(message "Done")
(save-buffers-kill-emacs t)           ; save all modified files and exit

