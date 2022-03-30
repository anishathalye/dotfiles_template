;; no init file is loaded, so provide everything here:
(add-to-list 'load-path "~/.emacs.d/elpa/org-journal-20210812.1749/")

(require 'org-journal)

(with-eval-after-load 'org-journal
  (setq org-journal-dir "~/org/journal/")
  (setq org-agenda-files '("~/org/journal"))
  (setq org-journal-file-type 'weekly)
  (setq org-journal-file-format "%Y-%m-%d.org")
  (setq org-icalendar-store-UID t
        org-icalendar-combined-name "OrgMode Tasks"
        org-icalendar-timezone "America/Los_Angeles"
        org-icalendar-date-time-format ";TZID=%Z:%Y%m%dT%H%M%S"
        org-icalendar-include-todo "all"
        org-icalendar-combined-agenda-file "~/mytasks.ics")
  (setq org-agenda-file-regexp "\\`\\([^.].*\\.org\\|[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\.org\\(\\.gpg\\)?\\)\\'"))

(org-icalendar-combine-agenda-files)  ; export the ICS file
(save-buffers-kill-emacs t)           ; save all modified files and exit

