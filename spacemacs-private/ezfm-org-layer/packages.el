(defconst ezfm-org-layer-packages
  '(org-roam
    org-roam-bibtex
    helm-bibtex
    deft
    org-ql
    org-ref))

(defun ezfm-org-layer/init-org-ql ()
  (quelpa
   '(quelpa-use-package
     :fetcher github
     :repo "alphapapa/org-ql")))

;; Installed initially as a way to search org-roam notes
(defun ezfm-org-layer/init-deft ()
  (use-package deft
    :commands (deft)
    :init
    (bind-key "C-c d" 'deft)
    :config (setq deft-directory "~/org/notes"
                  deft-extensions '("md" "org"))))

(defun ezfm-org-layer/init-helm-bibtex ()
  :init
  (progn
    (setq bibtex-completion-notes-path "~/org/notes/"
          bibtex-completion-bibliography "~/org/sources/zotero-library.bib"
          bibtex-completion-pdf-field "file"
          bibtex-completion-notes-template-multiple-files
          (concat
           "#+TITLE: ${title}\n"
           "#+ROAM_KEY: cite:${=key=}\n"
           "* TODO Notes\n"
           ":PROPERTIES:\n"
           ":Custom_ID: ${=key=}\n"
           ":NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")\n"
           ":AUTHOR: ${author-abbrev}\n"
           ":JOURNAL: ${journaltitle}\n"
           ":DATE: ${date}\n"
           ":YEAR: ${year}\n"
           ":DOI: ${doi}\n"
           ":URL: ${url}\n"
           ":END:\n\n")
          )))

(defun parse-last-name (citekey)
  (let* ((entry (bibtex-completion-get-entry citekey))
         (author-or-editor-abbrev (bibtex-completion-apa-get-value "author-or-editor-abbrev" entry)))
    (downcase (first (split-string author-or-editor-abbrev ",")))))

(defun ezfm-org-layer/init-org-roam-bibtex ()
  (use-package org-roam-bibtex
    :after org-roam
    :hook (org-roam-mode . org-roam-bibtex-mode)
    :config
    (setq orb-slug-source 'title)
    (setq orb-preformat-keywords
          '("=key=" "title" "url" "file" "author-or-editor" "keywords" ))
    (setq orb-templates
          '(("r" "ref" plain (function org-roam-capture--get-point)
             ""
             :file-name "%(parse-last-name \"${=key=}\")_${slug}_%<%Y%m%d%H%M%S>"
             :head "#+TITLE: ${author-or-editor}: ${title}\n#+ROAM_KEY: ${ref}

- tags ::
- keywords :: ${keywords}

\n* ${title}\n  :PROPERTIES:\n  :Custom_ID: ${=key=}\n  :URL: ${url}\n  :AUTHOR: ${author-or-editor}\n  :END:\n\n"
             :unnarrowed t)))))

(defun ezfm-org-layer/init-org-ref ()
  (use-package org-ref-acronym-color
    :config
    (setq org-ref-completion-library 'org-ref-ivy-cite
          org-ref-get-pdf-filename-function 'org-ref-get-pdf-filename-helm-bibtex
          org-ref-default-bibliography (list "~/org/sources/zotero-library.bib")
          org-ref-bibliography-notes "~/org/sources/bibliography-notes.org"
          org-ref-notes-directory "~/org/notes"
          org-rf-notes-function 'orb-edit-notes
          org-ref-note-title-format
          (concat
           "* TODO %y - %t\n"
           ":PROPERTIES:\n"
           ":Custom_ID: %k\n"
           ":NOTER_DOCUMENT: %F\n"
           ":ROAM_KEY: cite:%k\n"
           ":AUTHOR: %9a\n"
           ":JOURNAL: %j\n"
           ":YEAR: %y\n"
           ":VOLUME: %v\n"
           ":PAGES: %p\n"
           ":DOI: %D\n"
           ":URL: %U\n"
           ":END:\n\n"))))

(defun ezfm-org-layer/init-org-roam ()
  (use-package org-roam
    :hook
    (after-init . org-roam-mode)
    :custom
    (org-roam-directory "~/org/notes")
    :init
    (progn
      ;; Define fn to fetch list of org-roam files (using with org-ql)
      (defun org-roam-files ()
        (org-ql-search-directories-files :recurse "~/org/notes"))

      (spacemacs/declare-prefix "ar" "org-roam")
      (spacemacs/set-leader-keys
       "arl" 'org-roam
       "art" 'org-roam-dailies-today
       "arf" 'org-roam-find-file
       "arg" 'org-roam-graph)

      (spacemacs/declare-prefix-for-mode 'org-mode "mr" "org-roam")
      (spacemacs/set-leader-keys-for-major-mode 'org-mode
                                                "rl" 'org-roam
                                                "rt" 'org-roam-dailies-today
                                                "rb" 'org-roam-switch-to-buffer
                                                "rf" 'org-roam-find-file
                                                "ri" 'org-roam-insert
                                                "rg" 'org-roam-graph)

      ;; Global "emacs-style" bindings (I think). B/c it's annoying to have to exit
      ;; vim edit mode to get access to the leader key to do an insert when writing a note.
      (global-set-key (kbd "C-c r i") 'org-roam-insert))
    :config
    (setq org-roam-capture-templates
          '(("d" "default" plain (function org-roam--capture-get-point)
             "%?"
             :file-name "${slug}_%<%Y%m%d%H%M%S>"
             :head "#+TITLE: ${title}\n#+ROAM_TAGS:  "
             :unnarrowed t)))))
