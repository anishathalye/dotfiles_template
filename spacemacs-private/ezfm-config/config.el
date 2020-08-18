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

;; Org-mode customizations
(setq org-todo-keywords
      '((sequence "TODO" "STARTED" "|" "DONE")))

;; Org-journal customization
(setq org-journal-dir "~/Documents/org/journal/")
(setq org-journal-file-type 'weekly)
(setq org-journal-file-format "%Y-%m-%d")
(setq org-journal-time-format "TODO ")
(setq org-journal-enable-agenda-integration t)
(setq org-journal-date-format "%A, %B %d %Y")

(defun org-journal-date-format-func (time)
  "Custom function to insert journal date header,
and some custom text on a newly created journal file."
  (when (= (buffer-size) 0)
    (insert
     (pcase org-journal-file-type
       (`daily "#+TITLE: Daily Journal\n")
       (`weekly (concat"#+TITLE: Weekly Journal " (format-time-string "(Wk #%V)" time) "\n"))
       (`monthly "#+TITLE: Monthly Journal\n")
       (`yearly "#+TITLE: Yearly Journal"))))
  (concat org-journal-date-prefix (format-time-string "%A, %x" time)))
(setq org-journal-date-format 'org-journal-date-format-func)
