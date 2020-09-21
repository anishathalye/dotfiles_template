(defconst ezfm-org-layer-packages
  '(org-roam
    deft
    org-ql))

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

(defun ezfm-org-layer/init-org-roam ()
  (use-package org-roam
    :hook
    (after-init . org-roam-mode)
    :custom
    (org-roam-directory "~/org/notes")
    :init
    (progn
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
