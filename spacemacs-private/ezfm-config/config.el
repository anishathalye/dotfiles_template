;; For making ligatures for my font possible...as I recall.
(mac-auto-operator-composition-mode t)

;; What I expect when I open a new window.
(setq helm-split-window-default-side 'right)

(setq js-indent-level 2)
(setq css-indent-offset 2)

;; Disabling for now...
;; (add-hook 'js-mode-hook 'prettier-js-mode)
;; (add-hook 'web-mode-hook 'prettier-js-mode)

;; For faster file searching...
(setq projectile-enable-caching t)


(setq ruby-insert-encoding-magic-comment nil)

;; ?
(setq multi-term-program "/usr/local/bin/zsh")

;; Org-journal customization

;; custom fns
(defun org-journal-date-format-func (time)
  "Custom function to insert journal date header,
   and some custom text on a newly created journal file."
  (when (= (buffer-size) 0)
    (insert
     (pcase org-journal-file-type
       (`daily "#+TITLE: Daily Journal\n\n")
       (`weekly (concat"#+TITLE: Weekly Journal " (format-time-string "(Wk #%V)" time) "\n\n"))
       (`monthly "#+TITLE: Monthly Journal\n\n")
       (`yearly "#+TITLE: Yearly Journal\n\n"))))
  (concat org-journal-date-prefix (format-time-string "%A, %x" time)))

(setq org-agenda-file-regexp "\\`\\([^.].*\\.org\\|[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\(\\.gpg\\)?\\)\\'")
(setq org-journal-dir "~/org/journal/")
(setq org-journal-file-type 'weekly)
(setq org-journal-file-format "%Y-%m-%d")
;; (setq org-journal-time-format "")
(setq org-journal-time-prefix "** ")
(setq org-journal-date-format "%A, %B %d %Y")
;; (setq org-journal-enable-agenda-integration t)
(setq org-journal-date-format 'org-journal-date-format-func)



