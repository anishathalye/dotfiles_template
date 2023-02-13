;;; Initial notes

  ;; Some resources
  ;; - https://jamiecollinson.com/blog/my-emacs-config/

  ;; Note on navigation
  ;;   - Use `C-c @ C-t` to hide all
  ;;   - Use `C-c @ C-a` to show all
  ;;   - Other options for org-outline-minor-mode: `C-c @`


;;; Package tools setup

;; Bootstrap  the 'straight' package manager
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Now use-package that can work with straight
(straight-use-package 'use-package)

(eval-after-load 'use-package
  (setq
   ;; use-package should use straight unless otherwise specified
   straight-use-package-by-default t
   ;; ensure everything is installed, use `:ensure nil` to override
   use-package-always-ensure t))

;;; Initial setup

;; Setup outline-minor-mode for emacs-lisp, useful for this file
;; See: https://emacs.stackexchange.com/questions/3143/can-i-use-org-mode-to-structure-my-emacs-or-other-el-configuration-file
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (make-local-variable 'outline-regexp)
            (setq outline-regexp "^;;; ")
            (make-local-variable 'outline-heading-end-regexp)
            ;; (setq outline-heading-end-regexp ":\n")
            (outline-minor-mode 1)))

(setq user-full-name "Ethan Miller")
(setq delete-old-versions -1)
(setq inhibit-startup-screen t)
(setq ring-bell-function 'ignore)
(setq coding-system-for-read 'utf-8)
(setq coding-system-for-write 'utf-8)
(setq sentence-end-double-space nil)
(setq default-fill-column 80)
(setq initial-scratch-message "")
(setq-default mode-line-format nil)
(electric-pair-mode 1)

(use-package autorevert
  :ensure nil
  :config
  (setq auto-revert-interval 2)
  (setq auto-revert-check-vc-info t)
  (setq global-auto-revert-non-file-buffers t)
  (setq auto-revert-verbose nil)
  (global-auto-revert-mode +1))


;; Enables ligatures in the emacs macport
(if (fboundp 'mac-auto-operator-composition-mode)
    (mac-auto-operator-composition-mode))

;; Minimal UI
(scroll-bar-mode -2)
(tool-bar-mode   -1)
(tooltip-mode    -1)
(menu-bar-mode   -1)

;; Ensure that emacs window is focused when switching desktops
;; See: https://emacs.stackexchange.com/questions/28121/osx-switching-to-virtual-desktop-doesnt-focus-emacs
(menu-bar-mode t) 

;; Make links clickable in comments
(goto-address-mode 1)

;; Prevent scratch window from opening on startup
(add-hook 'emacs-startup-hook (lambda ()
                                (when (get-buffer-window "*scratch*")
                                    (delete-windows-on "*scratch*"))))


;;; Font

;; Font needs to be installed in the Mac Font Book
(add-to-list 'default-frame-alist '(font . "Fira Code-16"))
(set-face-attribute 'default t :font "Fira Code-16")

;;; Global Functions
(defun my/toggle-buffers ()
  (interactive)
  (switch-to-buffer nil))

(defun my/evil-shift-right ()
  (interactive)
  (evil-shift-right evil-visual-beginning evil-visual-end)
  (evil-normal-state)
  (evil-visual-restore))

(defun my/evil-shift-left ()
  (interactive)
  (evil-shift-left evil-visual-beginning evil-visual-end)
  (evil-normal-state)
  (evil-visual-restore))

(defun my/cider-test-run-focused-test ()
  "Run test around point."
  (interactive)
  (cider-load-buffer)
  (cider-test-run-test))

(defun my/org-screenshot ()
  "Take a screenshot into a time stamped unique-named file in the
same directory as the org-buffer and insert a link to this file."
  (interactive)
  (org-display-inline-images)
  (setq filename
        (concat
         (make-temp-name
          (concat (file-name-nondirectory (buffer-file-name))
                  "_imgs/"
                  (format-time-string "%Y%m%d_%H%M%S_")) ) ".png"))
  (unless (file-exists-p (file-name-directory filename))
    (make-directory (file-name-directory filename)))
                                        ; take screenshot
  (if (eq system-type 'darwin)
      (call-process "screencapture" nil nil nil "-i" filename))
  (if (eq system-type 'gnu/linux)
      (call-process "import" nil nil nil filename))
                                        ; insert into file if correctly taken
  (if (file-exists-p filename)
      (insert (concat "[[file:" filename "]]"))))

;;; Theme using `doom-themes`
(use-package doom-themes
  :config
  (load-theme 'doom-molokai t)
  ;; (load-theme 'doom-snazzy t)
  )

;;; Golden Ratio
(use-package golden-ratio
  :after ace-window
  :init
  (golden-ratio-mode 1)
  :config
  (add-to-list 'golden-ratio-extra-commands 'ace-window))

;;; Initialize `general` for keybindings
(use-package general
  :config
  (general-create-definer spc-key-definer
    :states '(normal visual insert motion emacs)
    :prefix "SPC"
    :non-normal-prefix "C-SPC"
    :prefix-map 'dominant-prefix-map))

;;; Keybindings
(with-eval-after-load 'evil
  (spc-key-definer
    "TAB" 'my/toggle-buffers
    "pp"  'projectile-switch-project
    "pf"  'consult-find ;'projectile-find-file
    "/"   'consult-ripgrep
    "bb"  'consult-buffer
    "rr"  'consult-recent-file
    "u"   'universal-argument))

(with-eval-after-load 'evil
  (general-define-key
   :states 'normal
   :keymaps 'process-menu-mode-map
   "d" 'process-menu-delete-process))

;;; Initialize Evil

;; Allow C-u/d for page up/down
(setq evil-want-C-u-scroll t)
(setq evil-want-C-d-scroll t)

;; Set this to match clojure indent style
;; May need to be set per mode at some point?
(setq evil-shift-width 2)

(use-package evil
  :init
  ;; These needs to be set when using evil-collection
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1)
  (setq-default evil-escape-delay 0.2)
  (general-define-key
  :states 'visual
  ">" 'my/evil-shift-right
  "<" 'my/evil-shift-left)
  )

(use-package evil-collection
  :after evil
  :config
  (setq evil-collection-mode-list nil) ;; disable all evil bindings as default
  (evil-collection-init '(magit dired)))

(use-package evil-nerd-commenter
  :config
  (general-define-key
  "M-;" 'evilnc-comment-or-uncomment-lines))

;;; Initialize `which-key` for dynamic key binding menus
(use-package which-key
  :init
  (setq which-key-separator " ")
  (setq which-key-prefix-prefix "+")
  :config
  (which-key-mode))

;;; Path management
(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;;; Restart-emacs package
(use-package restart-emacs
  :config
  (general-def "C-c R" 'restart-emacs))

;;; Treemacs
(use-package treemacs
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay      0.5
          treemacs-directory-name-transformer    #'identity
          treemacs-display-in-side-window        t
          treemacs-eldoc-display                 t
          treemacs-file-event-delay              5000
          treemacs-file-extension-regex          treemacs-last-period-regex-value
          treemacs-file-follow-delay             0.2
          treemacs-file-name-transformer         #'identity
          treemacs-follow-after-init             t
          treemacs-git-command-pipe              ""
          treemacs-goto-tag-strategy             'refetch-index
          treemacs-indentation                   2
          treemacs-indentation-string            " "
          treemacs-is-never-other-window         nil
          treemacs-max-git-entries               5000
          treemacs-missing-project-action        'ask
          treemacs-move-forward-on-expand        nil
          treemacs-no-png-images                 nil
          treemacs-no-delete-other-windows       t
          treemacs-project-follow-cleanup        nil
          treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                      'left
          treemacs-read-string-input             'from-child-frame
          treemacs-recenter-distance             0.1
          treemacs-recenter-after-file-follow    nil
          treemacs-recenter-after-tag-follow     nil
          treemacs-recenter-after-project-jump   'always
          treemacs-recenter-after-project-expand 'on-distance
          treemacs-show-cursor                   nil
          treemacs-show-hidden-files             t
          treemacs-silent-filewatch              nil
          treemacs-silent-refresh                nil
          treemacs-sorting                       'alphabetic-asc
          treemacs-space-between-root-nodes      t
          treemacs-tag-follow-cleanup            t
          treemacs-tag-follow-delay              1.5
          treemacs-user-mode-line-format         nil
          treemacs-user-header-line-format       nil
          treemacs-width                         35
          treemacs-workspace-switch-cleanup      nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after (treemacs evil))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package treemacs-icons-dired
  :after (treemacs dired)
  :config (treemacs-icons-dired-mode))

;; (use-package treemacs-magit
;;   :after (treemacs magit))

;; (use-package treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
;;   :after (treemacs persp-mode) ;;or perspective vs. persp-mode
;;   :config (treemacs-set-scope-type 'Perspectives))

;;; Projectile project management
(use-package projectile
  :diminish projectile-mode
  :config
  (progn
    (general-def "C-c p" 'projectile-command-map)
    (projectile-mode +1)
    (setq projectile-completion-system 'auto)
    (setq projectile-enable-caching t)
    (setq projectile-indexing-method 'alien)
    (add-to-list 'projectile-globally-ignored-files "node-modules")
    (autoload 'projectile-project-root "projectile")
    (setq consult-project-root-function #'projectile-project-root)))

;;; Dashboard on boot
(use-package dashboard
  :config
  (dashboard-setup-startup-hook))

;;; Window management with `ace-window`
(use-package ace-window
  :init
  (ace-window-display-mode 1)
  :config
  (general-define-key
  "M-o" 'ace-window))

;;; Doom-modeline for status bar
(use-package all-the-icons)
(use-package doom-modeline
  :requires all-the-icons
  :init
  (doom-modeline-mode 1)
  :config
  (progn
    (setq doom-modeline-height 15)
    (setq column-number-mode t
          line-number-mode t)))

;;; Vertico, etc.

(use-package vertico
  :init
  (vertico-mode))

;;Persists history between restarts, vertico sorts by history position. 
(use-package savehist
  :init
  (savehist-mode))

(use-package vertico-prescient
  :after vertico
  :init (vertico-prescient-mode +1))


(use-package consult
  :after projectile
  :config
  ;; This is to prevent consult-find from picking up node_modules.  For more, see:
  ;; https://github.com/minad/consult/wiki#skipping-directories-when-using-consult-find
  (setq consult-find-args "find . -not ( -wholename */.* -prune -o -name node_modules -prune )")
  )

;; Richer annotations using the Marginalia package
(use-package marginalia
  ;; Either bind `marginalia-cycle` globally or only in the minibuffer
  :bind (("M-A" . marginalia-cycle)
        :map minibuffer-local-map
        ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode)
  ;; Prefer richer, more heavy, annotations over the lighter default variant.
  ;; E.g. M-x will show the documentation string additional to the keybinding.
  ;; By default only the keybinding is shown as annotation.
  ;; Note that there is the command `marginalia-cycle' to
  ;; switch between the annotators.
  ;; (setq marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
)

;;; Version management
(use-package magit
  :config
  (spc-key-definer "gs" 'magit-status))

(use-package git-link)

;; Enable color escape codes in magit-process buffer, see source
;; https://github.com/magit/magit/issues/1878#issuecomment-418763526
;; (defun color-buffer (proc &rest args)
;;   (interactive)
;;   (with-current-buffer (process-buffer proc)
;;     (read-only-mode -1)
;;     (ansi-color-apply-on-region (point-min) (point-max))
;;     (read-only-mode 1)))
;; (advice-add 'magit-process-filter :after #'color-buffer)

;;; Code editing tools

;; like lets you surround texts with symbols easily
(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

;; Structural editing with smartparens
;; Structural editing - For keybinding reference: https://github.com/syl20bnr/evil-lisp-state
(use-package smartparens
  :config
  ;; Taken from: https://github.com/syl20bnr/evil-lisp-state/blob/master/evil-lisp-state.el#L313-L335
  (defun my-lisp/insert-sexp-after ()
    "Insert sexp after the current one." (interactive)
    (let ((sp-navigate-consider-symbols nil))
      (if (char-equal (char-after) ?\() (forward-char))
      (sp-up-sexp)
      (evil-insert-state)
      (sp-newline)
      (sp-insert-pair "(")))

  (defun my-lisp/insert-sexp-before ()
    "Insert sexp before the current one."
    (interactive)
    (let ((sp-navigate-consider-symbols nil))
      (if (char-equal (char-after) ?\() (forward-char))
      (sp-backward-sexp)
      (evil-insert-state)
      (sp-newline)
      (evil-previous-visual-line)
      (evil-end-of-line)
      (insert " ")
      (sp-insert-pair "(")
      (indent-for-tab-command)))
  ;; structural editing keybindings
  (general-define-key
  :states 'normal
  :prefix "SPC k"
  "y"  'sp-copy-sexp
  "dx" 'sp-kill-sexp
  "s" 'sp-forward-slurp-sexp
  "b" 'sp-forward-barf-sexp
  ")" 'my-lisp/insert-sexp-after
  "(" 'my-lisp/insert-sexp-before))

;;; Code completion
(use-package lsp-mode
  :defer t
  :hook ((lsp-mode . lsp-enable-which-key-integration))
  :commands lsp-deferred
  :config
  (setq lsp-auto-configure t
        lsp-auto-guess-root t
        ;; lsp-diagnostic-package :none
        lsp-log-io nil ;; speed
        lsp-restart t ;; b/c server dies
        lsp-ui-sideline-enable t
        lsp-ui-sideline-show-hover t
        lsp-ui-sideline-show-code-actions t
        lsp-ui-sideline-show-diagnostics t
        ))

(use-package lsp-ui
  :commands lsp-ui-mode)

(use-package company
  :init
  (add-hook 'after-init-hook 'global-company-mode)
  :config
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.0))

(use-package flycheck
  :hook ((prog-mode . flycheck-mode))
  :config
  (setq flycheck-indication-mode 'left-margin)
  (setq flycheck-highlighting-mode 'lines)
  (setq flycheck-check-syntax-automatically '(save mode-enabled newline))
  (setq flycheck-display-errors-delay 0.1))

;;; Javascript
(setq js-indent-level 2)

;; (use-package js2-mode
;;   :defer t
;;   :mode (("\\.m?js\\'"  . js2-mode)))
(use-package add-node-modules-path
  :defer t
  :hook (((js2-mode rjsx-mode) . add-node-modules-path)))

;; rjsx-mode extends js2-mode, so it provides js2-mode plus functionality for jsx
(use-package rjsx-mode
  :defer t
  :mode ("\\.jsx?\\'" "\\.tsx?\\'" "\\.m?js\\'")
  :hook (((js2-mode
           rjsx-mode
           ) . lsp-deferred)) ;; enable lsp-mode
  :config
  (setq lsp-auto-guess-root t)
  ;; (setq lsp-diagnostic-package :none)
  (setq lsp-idle-delay 0.5)
  (setq js2-mode-show-parse-errors nil
          js2-mode-show-strict-warnings nil)
  (define-key rjsx-mode-map "<" nil)
  (define-key rjsx-mode-map (kbd "C-d") nil)
  (define-key rjsx-mode-map ">" nil)
  )

(use-package prettier-js
  :defer t
  :diminish prettier-js-mode
  :hook (((js2-mode rjsx-mode) . prettier-js-mode)))

;;; Clojure Configuration
(show-paren-mode 1)
(use-package clojure-mode :defer t)
(use-package cider
  :defer t
  :config
  (setq cider-repl-pop-to-buffer-on-connect nil))
(use-package rainbow-delimiters
  :defer t
  :init
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))
(use-package company
  :config
  (progn
    (add-hook 'cider-repl-mode-hook #'company-mode)
    (add-hook 'cider-mode-hook #'company-mode)))

;;; R Congiguration
(use-package ess
  :init
  (setq ess-indent-with-fancy-comments nil))

;;; Org-mode configuation
(setq org-directory "~/org")
(setq org-log-into-drawer t)
(setq org-export-backends
      '(md html))

;; Shortcut to org dir files
(defun my/my-org-finder ()
  (interactive)
  (ido-find-file-in-dir org-directory))

;; ignore journal files in recent files
;; (setq recentf-exclude '("/org/journal"))

;; Sets the column width to 80 columns and enables line breaking, ie. auto-fill.
(add-hook 'org-mode-hook '(lambda () (setq fill-column 80)))
(add-hook 'org-mode-hook 'auto-fill-mode)

;; Indent contents along with tree/bullet depth
(add-hook 'org-mode-hook 'org-indent-mode)

;; Set some keybindings for org-agenda
(general-define-key
 :keymaps 'org-agenda-keymap
 "j" 'org-agenda-next-item
 "k" 'org-agenda-previous-item)

;; Some keybindings for org-mode itself
(general-define-key
 :keymaps 'org-mode-map
 "<tab>" 'org-cycle)

;; Setup status tags
(setq org-todo-keywords
      '((sequence "NEXT(n)" "TODO(t)" "STARTED(s)" "REVIEW(r)" "|" "BLOCKED(b!)" "DONE(d!)" "CANCELED(c!)")))

(setq org-todo-keyword-faces
      '(("TODO" . (:foreground "#ff39a3" :weight bold))
	("STARTED" . "#E35DBF")
	("REVIEW" . "lightblue")
	("BLOCKED" . "pink")
	("CANCELED" . (:foreground "white" :background "#4d4d4d" :weight bold))
	("DONE" . "#008080")))

(use-package org-superstar
  :init
  (add-hook 'org-mode-hook (lambda () (org-superstar-mode 1))))

(use-package org-journal
  :config
  (setq org-journal-dir "~/org/journal/")
  (setq org-journal-file-type 'weekly)
  (setq org-journal-file-format "%Y-%m-%d.org")
  (setq org-journal-time-prefix "** ")
  (setq org-journal-date-format "%A, %B %d %Y")
  (setq org-journal-carryover-items "TODO=\"TODO\"|TODO=\"STARTED\"|TODO=\"REVIEW\"|TODO=\"BLOCKED\"")
  (setq org-journal-find-file #'find-file-other-window)
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
  (setq org-journal-date-format 'org-journal-date-format-func)
  (setq org-agenda-file-regexp "\\`\\([^.].*\\.org\\|[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\.org\\(\\.gpg\\)?\\)\\'")

  ;; keybindings
  (general-define-key
   :prefix "C-c"
   "C-j" nil ;; override default C-j binding for org-journal
   "C-j o" 'org-journal-open-current-journal-file
   "C-j n" 'org-journal-new-entry
   "C-j d" 'org-journal-new-date-entry))

(use-package org-super-agenda
  :config
  (org-super-agenda-mode)
  (setq org-super-agenda-groups
    '(;; Each group has an implicit Boolean OR operator between its selectors.
      (:name "Life" :tag "life")
      (:name "PrimaryKids" :tag "primarykids")
      (:name "SciCloj" :tag "scicloj")
      (:name "✨ Finished ✨" :todo "DONE")))
  (org-agenda nil "a"))

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

    ;; (spacemacs/declare-prefix "ar" "org-roam")
    (spc-key-definer
      "arf" 'org-roam-node-find))
  :config
  (org-roam-setup))

(use-package org-ref
  :config
  (setq org-latex-pdf-process (list "latexmk -shell-escape -bibtex -f -pdf %f"))
  (setq org-ref-default-bibliography (list "~/org/sources/zotero-library.bib")
	org-ref-bibliography-notes "~/org/sources/bibliography-notes.org"))

(use-package pandoc-mode
  :init
  (add-hook 'pandoc-mode-hook 'pandoc-load-default-settings))

(use-package org-jira
  :defer t
  :config
  (setq jiralib-url "https://primary.atlassian.net")
  (setq org-jira-custom-jqls
        '((:jql "project IN (EPD) AND sprint in openSprints() AND assignee = currentUser()"
           :filename "current-sprint")
          (:jql "project IN (PW) AND filter = \"11478\""
           :filename "helpdesk"))))

;;; YAML support
(use-package yaml-mode
    :mode (("\\.\\(yml\\|yaml\\)\\'" . yaml-mode)
          ("Procfile\\'" . yaml-mode))
    :config (add-hook 'yaml-mode-hook
                      #'(lambda ()
                        (define-key yaml-mode-map "\C-m" 'newline-and-indent))))

;;; Terraform support
(use-package terraform-mode
  :mode ("\\.tf\\'"))

;;; Notespace
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


;;; Clerk
(defun clerk/show-buffer ()
  (interactive)
  (save-buffer)
  (let
      ((filename (buffer-file-name)))
    (when filename
      (cider-interactive-eval
       (concat "(nextjournal.clerk/show! \"" filename "\")")))))

(general-define-key
 :keymaps 'clojure-mode-map
 "C-c r" 'clerk/show-buffer)


;;; Clay
                                        ;
;; This is for allowing cider to send values to clay... 
;; inspired by https://github.com/clojure-emacs/cider/issues/3094
(defun cider-tap (&rest r) 
  (cons (concat "(let [__value "
                (caar r)
                "] (tap> {:clay-tap? true :form (quote " (caar r) ") :value __value}) __value)")
        (cdar r)))

(advice-add 'cider-nrepl-request:eval :filter-args #'cider-tap)

;; Here are some helper functions for showing the whole clay document.

(defun scittle-show ()
  (interactive)
  (save-buffer)
  (let
      ((filename
        (buffer-file-name)))
    (when filename
      (cider-interactive-eval
       (concat "(scicloj.clay.v2.api/show-doc! \"" filename "\" {})")))))

(defun scittle-show-and-write ()
  (interactive)
  (save-buffeci)
  (let
      ((filename
        (buffer-file-name)))
    (when filename
      (cider-interactive-eval
       (concat "(scicloj.clay.v2.api/show-doc-and-write-html! \"" filename "\" {:toc? true})")))))


;;; Custom-set-variables - do not edit (autogenerated)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(css-indent-offset 24)
 '(custom-safe-themes
   '("4f1d2476c290eaa5d9ab9d13b60f2c0f1c8fa7703596fa91b235db7f99a9441b" default))
 '(evil-undo-system 'undo-redo)
 '(indent-tabs-mode nil)
 '(org-agenda-files '("~/org/journal"))
 '(package-selected-packages
   '(vertico-prescient vertico 0blayout magithub ess multiple-cursors jq-format jq-mode mustache mustache-mode prettier ob-ipython flycheck golden-ratio evil-surround org-jira perfect-margin git-link org-super-agenda transpose-frame org-ref treemacs-persp treemacs-magit treemacs-icons-dired treemacs-projectile treemacs-evil treemacs outshine company-go add-node-modules-path web-mode typescript-mode org-superstar org-bullets ace-window dashboard writeroom-mode which-key use-package selectrum-prescient restart-emacs projectile magit general exec-path-from-shell evil-nerd-commenter evil-lisp-state evil-collection doom-themes consult cider))
 '(safe-local-variable-values
   '((cider-clojure-cli-aliases . "dev")
     (eval add-to-list 'cider-jack-in-nrepl-middlewares "scicloj.clay.v1.nrepl/middleware")
     (cider-clojure-cli-global-options . "-A:demo")
     (eval
      (lambda nil
        (defun cider-jack-in-wrapper-function
            (orig-fun &rest args)
          (if
              (and
               (boundp 'use-bb-dev)
               use-bb-dev)
              (message "Use `bb dev` to start the development server, then `cider-connect` to the port it specifies.")
            (apply orig-fun args)))
        (advice-add 'cider-jack-in :around #'cider-jack-in-wrapper-function)
        (when
            (not
             (featurep 'clerk))
          (let
              ((init-file-path
                (expand-file-name "clerk.el" default-directory)))
            (when
                (file-exists-p init-file-path)
              (load init-file-path)
              (require 'clerk))))))
     (use-bb-dev . t)))
 '(send-mail-function 'smtpmail-send-it)
 '(smtpmail-smtp-server "smtp.gmail.com")
 '(smtpmail-smtp-service 587))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'downcase-region 'disabled nil)
