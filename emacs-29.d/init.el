(setq inhibit-startup-message t)

(scroll-bar-mode -1) ;; Disable visible scrollbar
(tool-bar-mode -1) ;; Disable the toolbar 
(tooltip-mode -1) ;; Disable tool tips
(menu-bar-mode -1) ;; Disable menus

(set-fringe-mode 10)

(set-face-attribute 'default nil :font "Fira Code Retina" :height 130)

(load-theme 'tango-dark)

(setq user-full-name "Ethan Miller")
(setq xterm-extra-capabilities nil)
(setq delete-old-versions -1)
(setq inhibit-startup-screen t)
(setq ring-bell-function 'ignore)
(setq coding-system-for-read 'utf-8)
(setq coding-system-for-write 'utf-8)
(setq sentence-end-double-space nil)
(setq default-fill-column 80)
(setq initial-scratch-message "")
(setq-default mode-line-format nil)
(setq goto-address-mode t) ;; clickable links
(electric-pair-mode 1)

;; line numbers
(global-display-line-numbers-mode t)
(dolist (mode '(org-mode-hook
		  term-mode-hook
		  eshell-mode-hook
		  treemacs-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package autorevert
  :ensure nil
  :config
  (setq auto-revert-interval 2)
  (setq auto-revert-check-vc-info t)
  (setq global-auto-revert-non-file-buffers t)
  (setq auto-revert-verbose nil)
  (global-auto-revert-mode +1))

;; Minimal UI
(scroll-bar-mode -2)
(tool-bar-mode   -1)
(tooltip-mode    -1)

;; Line spacing
(setq line-spacing 0.1)

;; Ensure that emacs window is focused when switching desktops
;; See: https://emacs.stackexchange.com/questions/28121/osx-switching-to-virtual-desktop-doesnt-focus-emacs
(menu-bar-mode -1) 

;; Make links clickable in comments
(goto-address-mode 1)

;; Prevent scratch window from opening on startup
(add-hook 'emacs-startup-hook (lambda ()
                                (when (get-buffer-window "*scratch*")
                                    (delete-windows-on "*scratch*"))))

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

(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;;; Secrets Setup
(setq epg-pinentry-mode 'loopback) ;; this line I think allows prompt for passphrase in minibuffer
(require 'epa-file)
(setq auth-source-debug t)
(load-library "~/secrets.el.gpg")

(setenv "GITHUB_PKG_AUTH_TOKEN" secret/github-pkg-auth-token)

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

;; Font needs to be installed in the Mac Font Book or
;; Fira Code fonts installed with brew:
;;   https://github.com/tonsky/FiraCode/wiki/Installing.
(add-to-list 'default-frame-alist '(font . "Fira Code-16"))
(set-face-attribute 'default t :font "Fira Code-16")

(use-package ligature
  :config
  (ligature-set-ligatures 't '("www"))

  ;; Enable ligatures in programming modes                                                           
  (ligature-set-ligatures 'prog-mode '("www" "**" "***" "**/" "*>" "*/" "\\\\" "\\\\\\" "{-" "::"
                                      ":::" ":=" "!!" "!=" "!==" "-}" "----" "-->" "->" "->>"
                                      "-<" "-<<" "-~" "#{" "#[" "##" "###" "####" "#(" "#?" "#_"
                                      "#_(" ".-" ".=" ".." "..<" "..." "?=" "??" ";;" "/*" "/**"
                                      "/=" "/==" "/>" "//" "///" "&&" "||" "||=" "|=" "|>" "^=" "$>"
                                      "++" "+++" "+>" "=:=" "==" "===" "==>" "=>" "=>>" "<="
                                      "=<<" "=/=" ">-" ">=" ">=>" ">>" ">>-" ">>=" ">>>" "<*"
                                      "<*>" "<|" "<|>" "<$" "<$>" "<!--" "<-" "<--" "<->" "<+"
                                      "<+>" "<=" "<==" "<=>" "<=<" "<>" "<<" "<<-" "<<=" "<<<"
                                      "<~" "<~~" "</" "</>" "~@" "~-" "~>" "~~" "~~>" "%%"))

  ;; Enable the www ligature in every possible major mode
  (global-ligature-mode 't))

;; Doom-modeline for status bar
(use-package nerd-icons)
(use-package doom-modeline
  :after (nerd-icons)
  :init
  (doom-modeline-mode 1)
  :config
  (progn
    ;;(setq doom-modeline-height 15)
    (setq column-number-mode t
          line-number-mode t)))


;; disabling this because I'm experimenting with modus-vivendi
;; (use-package doom-themes)

;; modus-vivendi
;; customization options: https://protesilaos.com/emacs/modus-themes#h:bf1c82f2-46c7-4eb2-ad00-dd11fdd8b53f
(require-theme 'modus-themes)
(setq modus-themes-disable-other-themes t
      modus-themes-mode-line '(accented borderless)
      modus-themes-mixed-fonts t
      modus-themes-region '(accented bg-only)
      modus-themes-italic-constructs t
      modus-themes-bold-constructs t
      modus-themes-paren-match '(bold intense))
(load-theme 'modus-vivendi t)

;;; Initialize `general` for keybindings
(use-package general
  :config
  (general-create-definer spc-key-definer
    :states '(normal visual insert motion emacs)
    :prefix "SPC"
    :non-normal-prefix "C-SPC"
    :prefix-map 'dominant-prefix-map))

(with-eval-after-load 'evil
  (spc-key-definer
    "TAB" 'my/toggle-buffers
    "pp"  'projectile-switch-project
    "pf"  'consult-find ;'projectile-find-file
    "/"   'consult-git-grep ;'consult-ripgrep
    "bb"  'consult-buffer
    "rr"  'consult-recent-file
    "u"   'universal-argument))

(with-eval-after-load 'evil
  (general-define-key
   :states 'normal
   :keymaps 'process-menu-mode-map
   "d" 'process-menu-delete-process))

(use-package which-key
  :init
  (setq which-key-separator " ")
  (setq which-key-prefix-prefix "+")
  :config
  (which-key-mode))

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
  (evil-collection-init '(magit dired wgrep org)))

(use-package evil-nerd-commenter
  :config
  (general-define-key
  "M-;" 'evilnc-comment-or-uncomment-lines))

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
  (setq consult-find-args "find . -not ( -wholename */.* -prune -o -name node_modules -prune )"))

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

(use-package marginalia
  :ensure t
  :config
  (marginalia-mode))

(use-package embark
  :ensure t

  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-," . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings) ;; alternative for `describe-bindings'
   ("M-." . embark-occur)       ;; occur-edit-mode
   ;;("M-;" . embark-export)         ; export current view
   )

  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc.  You may adjust the Eldoc
  ;; strategy, if you want to see the documentation from multiple providers.
  (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none))))
 )

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :ensure t ; only need to install it, embark loads it after consult if found
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package wgrep
  :config
  (setq wgrep-auto-save-buffer t)
  (evil-make-overriding-map wgrep-mode-map 'normal)
  (evil-make-overriding-map wgrep-mode-map 'visual)
  (evil-make-overriding-map wgrep-mode-map 'motion))

(use-package ace-window
  :init
  (ace-window-display-mode 1)
  :config
  (general-define-key
  "M-o" 'ace-window))

(use-package golden-ratio
  :after ace-window
  :init
  (golden-ratio-mode 1)
  :config
  (add-to-list 'golden-ratio-extra-commands 'ace-window))

(use-package origami
  :config
  (add-hook 'js-to-mode 'origami-mode))

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

(use-package magit
  :config
  (spc-key-definer "gs" 'magit-status))

(use-package git-link)

(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

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

(use-package tree-sitter
  :config
  (customize-set-variable 'treesit-font-lock-level 5)
  (setq treesit-language-source-alist
    '((elisp "https://github.com/Wilfred/tree-sitter-elisp")
      (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
      (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
      (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
      (clojure "https://github.com/sogaiu/tree-sitter-clojure" "master" "src")
	  (yaml "https://github.com/ikatyang/tree-sitter-yaml" "master" "src")
      (json "https://github.com/tree-sitter/tree-sitter-json" "master" "src")))
  (setq major-mode-remap-alist
    '((js2-mode . js-ts-mode)
      (typescript-mode . typescript-ts-mode)
      (rjsx-mode . tsx-ts-mode)
      (json-mode . json-ts-mode)
      (css-mode . css-ts-mode))))

;; Optimizations for lsp, see https://emacs-lsp.github.io/lsp-mode/page/performance/
(setq read-process-output-max (* 1024 1024)) ;; 1mb
(setq gc-cons-threshold 100000000)

(use-package lsp-mode
  :defer t
  :hook ((lsp-mode . lsp-enable-which-key-integration))
  :commands lsp-deferred
  :config
  (setq lsp-auto-configure t
        lsp-auto-guess-root t
        ;; lsp-diagnostic-package :none
        lsp-log-io t ;; speed
        lsp-restart t ;; b/c server dies
        ;; lsp-ui-sideline-enable t
        ;; lsp-ui-sideline-show-hover t
        lsp-ui-sideline-show-code-actions t
        ;; lsp-ui-sideline-show-diagnostics t
        lsp-eslint-enable t
        ))

(use-package lsp-ui
  :commands lsp-ui-mode)

(defun my/setup-lsp-company ()
  (setq-local company-backends
              '(company-capf company-dabbrev company-dabbrev-code)))

(add-hook 'lsp-completion-mode-hook #'my/setup-lsp-company)

(use-package company
  :init
  (add-hook 'after-init-hook 'global-company-mode)
  :config
  (setq
   company-minimum-prefix-length 2
   company-idle-delay 0.35
   company-tooltip-align-annotations t
   company-require-match nil     ;; allow free typing
   company-dabbrev-ignore-case t ;; don't ignore case for completions
   company-dabbrev-downcase t    ;; don't downcase completions
   ))

(use-package flycheck
  :hook ((prog-mode . flycheck-mode))
  :config
  (setq flycheck-indication-mode 'left-margin)
  (setq flycheck-highlighting-mode 'lines)
  (setq flycheck-check-syntax-automatically '(save mode-enabled newline))
  (setq flycheck-display-errors-delay 0.1))

;; dependencies of copilot
(use-package dash)
(use-package s)
(use-package editorconfig)
(use-package f)
(use-package yasnippet)

(use-package copilot
  :straight (:host github :repo "copilot-emacs/copilot.el" :files ("*.el"))
  :requires (dash s editorconfig f yasnippet)
  :hook (prog-mode . copilot-mode)
  :config
  (general-define-key
   :states '(insert)
   :keymaps 'copilot-mode-map
   "M-y" #'copilot-accept-completion-by-line
   "M-Y" #'copilot-accept-completion
   "M-J" #'copilot-next-completion
   "M-K" #'copilot-previous-completion
   "M->" #'copilot-next-completion
   "M-<" #'copilot-previous-completion)
   ;; setup indentation - hopefully better way to do this soon
   (add-to-list 'copilot-indentation-alist '(prog-mode 2))
   (add-to-list 'copilot-indentation-alist '(org-mode 2))
   (add-to-list 'copilot-indentation-alist '(text-mode 2))
   (add-to-list 'copilot-indentation-alist '(closure-mode 2))
   (add-to-list 'copilot-indentation-alist '(emacs-lisp-mode 2))
   (add-to-list 'copilot-indentation-alist '(js2-mode 2))
   (add-to-list 'copilot-indentation-alist '(rjsx-mode 2)))

(setq js-indent-level 2)

(use-package add-node-modules-path
  :defer t
  :hook (((js2-mode rjsx-mode) . add-node-modules-path)))

;; rjsx-mode extends js2-mode, so it provides js2-mode plus functionality for jsx
(use-package rjsx-mode
  :defer t
  :mode ("\\.jsx?\\'" "\\.tsx?\\'" "\\.m?js\\'")
  :hook (((js2-mode
           rjsx-mode
	   js-ts-mode
	   typescript-ts-mode
	   tsx-ts-mode
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
  :hook (((js2-mode rjsx-mode js-ts-mode tsx-ts-mode typescript-ts-mode) . prettier-js-mode))
  )

(use-package jest-test-mode 
  :ensure t 
  :commands jest-test-mode
  :hook (typescript-mode js-mode typescript-tsx-mode))

(show-paren-mode 1)

(use-package clojure-mode
  :defer t)

(use-package clojure-ts-mode
  :defer t)

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

(use-package clay
  :straight (clay
             :type git
             :host github
             :repo "scicloj/clay.el"))

(use-package yaml-mode
    :mode (("\\.\\(yml\\|yaml\\)\\'" . yaml-mode)
          ("Procfile\\'" . yaml-mode))
    :config (add-hook 'yaml-mode-hook
                      #'(lambda ()
                        (define-key yaml-mode-map "\C-m" 'newline-and-indent))))

(use-package scss-mode
  :mode (("\\.scss\\'" . scss-mode)
         ("\\.css\\'" . scss-mode))
  :config
  ;; set the css-indent-offset to 2
  (setq css-indent-offset 2))

(use-package ruby-mode
  :mode "\\.rb\\'"
  :mode "Rakefile\\'"
  :mode "Gemfile\\'"
  :mode "Berksfile\\'"
  :mode "Vagrantfile\\'"
  :interpreter "ruby"

  :init
  (setq ruby-indent-level 2
        ruby-indent-tabs-mode nil)
  (add-hook 'ruby-mode 'superword-mode)
  )

(use-package rubocop
  :init
  (add-hook 'ruby-mode-hook 'rubocop-mode)
  :diminish rubocop-mode)

(setq org-directory "~/org")
(setq org-log-into-drawer t)
(setq org-export-backends
      '(md html odt latex))

;; Shortcut to org dir files
(defun my/my-org-finder ()
  (interactive)
  (ido-find-file-in-dir org-directory))

;; ignore journal files in recent files
;; (setq recentf-exclude '("/org/journal"))

;; Sets the column width to 80 columns and enables line breaking, ie. auto-fill.
(add-hook 'org-mode-hook '(lambda () (setq fill-column 80)))
(add-hook 'org-mode-hook 'auto-fill-mode)

(defun my/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (auto-fill-mode 0)
  (visual-line-mode 1)
  (setq evil-auto-indent nil)
  (setq org-list-indent-offset 2))

(use-package org
  :hook (org-mode . my/org-mode-setup)
  :config
  (dolist (face '((org-document-title . 1.4)
  		  (org-level-1 . 1.3)
  		  (org-level-2 . 1.2)
  		  (org-level-3 . 1.1)
  		  (org-level-4 . 1.1)
  		  (org-level-5 . 1.2)
  		  (org-level-6 . 1.2)
  		  (org-level-7 . 1.2)
  		  (org-level-8 . 1.2)))
    (set-face-attribute (car face) nil
			 :font "Roboto Slab"
			 :weight 'normal
			 :height (cdr face)
			 ))

  ;; replace ellipsis for closed entries
  (set-display-table-slot standard-display-table
  			'selective-display (string-to-vector "..."))

  (setq org-ellipsis " ▾"
  	org-hide-emphasis-markers t ;; hides the special markup symbols arond text
  	org-startup-indented t
  	org-startup-folded 'overview ;; will fold most items
  	org-src-fontify-natively t
          org-edit-src-content-indentation 2
  	org-fontify-quote-and-verse-blocks t
  	org-fontify-whole-heading-line t))

;; helps with org-mode tables that get messed up sometimes
(use-package mixed-pitch
  :hook
  ;; If you want it in all text modes:
  (text-mode . mixed-pitch-mode))

;; this is a nice replacement of org-bullets
(use-package org-superstar
  :after (org)
  :init
  (add-hook 'org-mode-hook (lambda () (org-superstar-mode 1)))
  :config
  (setq org-superstar-remove-leading-stars t
        org-superstar-headline-bullets-list '("◉" "○" "●" "○" "●" "○" "●")
	;; org-superstar-headline-bullets-list '(" ")
	))

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

(require 'org-tempo)
(with-eval-after-load 'org-tempo
  (add-to-list 'org-structure-template-alist '("sh" . "src sh"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp")))

(use-package org-journal
  :config
  (setq org-journal-dir "~/org/techwork/journals/")
  (setq org-journal-file-type 'daily)
  (setq org-journal-file-format "%Y-%m-%d.org")
  (setq org-journal-time-prefix "* ")
  (setq org-journal-date-format "%B %d %Y")
  (setq org-journal-carryover-items "TODO=\"TODO\"|TODO=\"STARTED\"|TODO=\"REVIEW\"|TODO=\"BLOCKED\"")
  (setq org-journal-find-file #'find-file-other-window)
  (defun org-journal-date-format-func (time)
    "Custom function to insert journal date header,
    and some custom text on a newly created journal file."
    (when (= (buffer-size) 0)
      (insert
       (pcase org-journal-file-type
	 (`daily (concat (format-time-string "#+TITLE: %Y-%m-%d") "\n\n"))
	 (`weekly (concat"#+TITLE: Weekly Journal " (format-time-string "(Wk #%V)" time) "\n\n"))
	 (`monthly "#+TITLE: Monthly Journal\n\n")
	 (`yearly "#+TITLE: Yearly Journal\n\n"))))
    (concat org-journal-date-prefix (format-time-string "%x" time)))
  (setq org-journal-date-format 'org-journal-date-format-func)
  (setq org-agenda-file-regexp "\\`\\([^.].*\\.org\\|[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\.org\\(\\.gpg\\)?\\)\\'")

  ;; keybindings
  (general-define-key
   :prefix "C-c"
   "C-j" nil ;; override default C-j binding for org-journal
   "C-j o" 'org-journal-open-current-journal-file
   "C-j n" 'org-journal-new-entry
   "C-j d" 'org-journal-new-date-entry))

(use-package emacsql)
(use-package emacsql-sqlite)

(use-package org-roam
  :init
  (setq org-roam-directory "~/org/techwork/")
  (setq org-roam-dailies-directory "journals/")
  :config
  (setq org-roam-file-exclude-regexp "\\.git/.*\\|logseq/.*$"
	org-roam-capture-templates
	'(("d" "default" plain
	  "%?"
	  ;; Accomodates for the fact that Logseq uses the "pages" directory
	  :target (file+head "pages/${slug}.org" "#+title: ${title}\n")
	  :unnarrowed t))
	org-roam-dailies-capture-templates
	'(("d" "default" entry
	  "* %?"
	  :target (file+head "%<%Y-%m-%d>.org" ;; format matches Logseq
			      "#+title: %<%Y-%m-%d>\n"))))
  )

(use-package logseq-org-roam
 :straight (:host github
            :repo "sbougerel/logseq-org-roam"
            :files ("*.el")))

(use-package consult-org-roam
  :after org-roam
  :init
  (require 'consult-org-roam)
  (consult-org-roam-mode 1) ;; activate minor mode
  :custom
  (consult-org-roam-grep-func #'consult-ripgrep)
  :config
  (consult-customize
   consult-org-roam-forward-links
   :preview-key (kbd "M-.")
   )
  :bind
  ("C-c n e" . consult-org-roam-file-find)
  ("C-c n b" . consult-org-roam-backlinks)
  ("C-c n B" . consult-org-roam-backlinks-recursive)
  ("C-c n l" . consult-org-roam-forward-links)
  ("C-c n r" . consult-org-roam-search))

(use-package org-contrib
  :config
  (require 'ox-extra)
  (ox-extras-activate '(ignore-headlines)))

(use-package gptel
  :config
  (setq gptel-api-key secret/openai-api-key))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values
   '((eval let
	   ((current-dir
	     (expand-file-name
	      (locate-dominating-file default-directory ".dir-locals.el"))))
	   (message "Setting new org roam directory: %s" current-dir)
	   (setq org-roam-directory current-dir)
	   (message "Setting new db location: %s"
		    (concat current-dir "org-roam.db"))
	   (setq org-roam-db-location
		 (concat current-dir "org-roam.db"))
	   (message "Setting new org-journal directory: %s"
		    (concat current-dir "journals/"))
	   (setq org-journal-dir
		 (concat current-dir "journals/"))
	   (setq org-journal-file-type 'daily)))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
