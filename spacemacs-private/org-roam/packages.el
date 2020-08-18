;; Layer wrapping and configuring the org-roam packages

(defconst org-roam-packages
  '(org-roam))

(defun org-roam/init-org-roam ()
  (use-package org-roam
    :hook
    (after-init . org-roam-mode)
    :custom
    (org-roam-directory "~/Documents/org/notes")
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
                                                "rg" 'org-roam-graph))
    :config
    (setq org-roam-capture-templates
          '(("d" "default" plain (function org-roam--capture-get-point)
             "%?"
             :file-name "${slug}_%<%Y%m%d%H%M%S>"
             :head "#+TITLE: ${title}\n#+ROAM_TAGS:  "
             :unnarrowed t)))))
