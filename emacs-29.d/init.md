
# Table of Contents

1.  [Basic UI Configuration](#org41b5f5f)
2.  [Package Manager Setup](#orgc2c0b02)
3.  [Setup environment](#org349b5ba)
    1.  [Path managment](#org45bb511)
    2.  [Load secrets](#orga65b8a7)
    3.  [Set environment variables](#org6f0d2cd)
    4.  [Global Custom Functions](#org120a589)
        1.  [Toggle Buffers](#org861927e)
        2.  [Evil Functions](#org4bcbb28)
        3.  [Cider Test Focused Test](#org58d54f2)
        4.  [Screenshot](#org1839666)
4.  [Advanced UI Setup](#orgecc0c4d)
    1.  [Fonts Setup](#org7699257)
    2.  [Theming](#orgdc1b142)
    3.  [Keybindings](#org0261aea)
        1.  [Initialize \`general\` for managing key bindings](#org2290057)
        2.  [Setup bindings](#org60f780b)
    4.  [Which key](#org6a679cb)
    5.  [Evil Mode](#org4393b54)
    6.  [Completions, Search, etc](#org3d6903c)
    7.  [Window management](#org2311e90)
        1.  [Ace Window](#orgd0f475f)
        2.  [Golden Ratio](#org1a2c9d9)
    8.  [Origami Mode](#org54aba6f)
5.  [Project Management](#org4329642)
    1.  [Projectile](#org947e759)
    2.  [Treemacs](#org30bb7bc)
    3.  [Magit](#orge328e74)
6.  [IDE setup](#org3450344)
    1.  [General Code Editing Tools](#org2247fdc)
    2.  [Evil surround](#org1e874eb)
    3.  [Structural editing with Smartparens](#org7dc711e)
    4.  [Tree-Sitter](#org7101fe4)
        1.  [Tree-Sitter config](#org60710a8)
    5.  [Enable LSP Mode](#org0ce37f5)
    6.  [Completion in buffer](#org410caaa)
    7.  [Flycheck for errors](#org42e2293)
7.  [Language-specific config](#org78b2a57)
    1.  [Javascript](#org26bc426)
    2.  [Clojure](#orgd209061)
        1.  [Basic setup](#org75fa505)
        2.  [Clay (literate notebooks)](#org8489bb1)
    3.  [YAML](#org699955c)
8.  [Org Mode](#org0b05637)
    1.  [Basic setup](#org2827306)
    2.  [Bullets](#org30db085)
    3.  [Todo Setup](#org6765798)
    4.  [Block Templates](#org17c03f5)
    5.  [Org Journal](#orga1ea845)
    6.  [Org Roam](#orgb9b59e7)
    7.  [Org  Contrib Additions](#orgcb9db18)
9.  [Other stuff](#org795bdba)
    1.  [Gptel (Chat GPT)](#org2de315e)



<a id="org41b5f5f"></a>

# Basic UI Configuration

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


<a id="orgc2c0b02"></a>

# Package Manager Setup

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


<a id="org349b5ba"></a>

# Setup environment


<a id="org45bb511"></a>

## Path managment

    (use-package exec-path-from-shell
      :config
      (when (memq window-system '(mac ns x))
        (exec-path-from-shell-initialize)))


<a id="orga65b8a7"></a>

## Load secrets

    ;;; Secrets Setup
    (setq epg-pinentry-mode 'loopback) ;; this line I think allows prompt for passphrase in minibuffer
    (require 'epa-file)
    (setq auth-source-debug t)
    (load-library "~/secrets.el.gpg")


<a id="org6f0d2cd"></a>

## Set environment variables

    (setenv "GITHUB_PKG_AUTH_TOKEN" secret/github-pkg-auth-token)


<a id="org120a589"></a>

## Global Custom Functions


<a id="org861927e"></a>

### Toggle Buffers

    (defun my/toggle-buffers ()
      (interactive)
      (switch-to-buffer nil))


<a id="org4bcbb28"></a>

### Evil Functions

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


<a id="org58d54f2"></a>

### Cider Test Focused Test

    (defun my/cider-test-run-focused-test ()
      "Run test around point."
      (interactive)
      (cider-load-buffer)
      (cider-test-run-test))


<a id="org1839666"></a>

### Screenshot

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


<a id="orgecc0c4d"></a>

# Advanced UI Setup


<a id="org7699257"></a>

## Fonts Setup

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


<a id="orgdc1b142"></a>

## Theming

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


<a id="org0261aea"></a>

## Keybindings


<a id="org2290057"></a>

### Initialize \`general\` for managing key bindings

    ;;; Initialize `general` for keybindings
    (use-package general
      :config
      (general-create-definer spc-key-definer
        :states '(normal visual insert motion emacs)
        :prefix "SPC"
        :non-normal-prefix "C-SPC"
        :prefix-map 'dominant-prefix-map))


<a id="org60f780b"></a>

### Setup bindings

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


<a id="org6a679cb"></a>

## Which key

    (use-package which-key
      :init
      (setq which-key-separator " ")
      (setq which-key-prefix-prefix "+")
      :config
      (which-key-mode))


<a id="org4393b54"></a>

## Evil Mode

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


<a id="org3d6903c"></a>

## Completions, Search, etc

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
       ;; ("M-;" . embark-export)         ; export current view
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


<a id="org2311e90"></a>

## Window management


<a id="orgd0f475f"></a>

### Ace Window

Enables easy toggle and other things that I've not yet used.

    (use-package ace-window
      :init
      (ace-window-display-mode 1)
      :config
      (general-define-key
      "M-o" 'ace-window)) 


<a id="org1a2c9d9"></a>

### Golden Ratio

    (use-package golden-ratio
      :after ace-window
      :init
      (golden-ratio-mode 1)
      :config
      (add-to-list 'golden-ratio-extra-commands 'ace-window))


<a id="org54aba6f"></a>

## Origami Mode

    (use-package origami
      :config
      (add-hook 'js-to-mode 'origami-mode))


<a id="org4329642"></a>

# Project Management


<a id="org947e759"></a>

## Projectile

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


<a id="org30bb7bc"></a>

## Treemacs

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


<a id="orge328e74"></a>

## Magit

    (use-package magit
      :config
      (spc-key-definer "gs" 'magit-status))
    
    (use-package git-link)


<a id="org3450344"></a>

# IDE setup


<a id="org2247fdc"></a>

## General Code Editing Tools


<a id="org1e874eb"></a>

## Evil surround

Helps surrounding text with symbols, e.g. quotes.

    (use-package evil-surround
      :ensure t
      :config
      (global-evil-surround-mode 1))


<a id="org7dc711e"></a>

## Structural editing with Smartparens

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


<a id="org7101fe4"></a>

## Tree-Sitter


<a id="org60710a8"></a>

### Tree-Sitter config

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


<a id="org0ce37f5"></a>

## Enable LSP Mode

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


<a id="org410caaa"></a>

## Completion in buffer

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


<a id="org42e2293"></a>

## Flycheck for errors

    (use-package flycheck
      :hook ((prog-mode . flycheck-mode))
      :config
      (setq flycheck-indication-mode 'left-margin)
      (setq flycheck-highlighting-mode 'lines)
      (setq flycheck-check-syntax-automatically '(save mode-enabled newline))
      (setq flycheck-display-errors-delay 0.1))


<a id="org78b2a57"></a>

# Language-specific config


<a id="org26bc426"></a>

## Javascript

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


<a id="orgd209061"></a>

## Clojure


<a id="org75fa505"></a>

### Basic setup

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


<a id="org8489bb1"></a>

### Clay (literate notebooks)

    (use-package clay
      :straight (clay
                 :type git
                 :host github
                 :repo "scicloj/clay.el"))


<a id="org699955c"></a>

## YAML

    (use-package yaml-mode
        :mode (("\\.\\(yml\\|yaml\\)\\'" . yaml-mode)
              ("Procfile\\'" . yaml-mode))
        :config (add-hook 'yaml-mode-hook
                          #'(lambda ()
                            (define-key yaml-mode-map "\C-m" 'newline-and-indent))))


<a id="org0b05637"></a>

# Org Mode


<a id="org2827306"></a>

## Basic setup

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


<a id="org30db085"></a>

## Bullets

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


<a id="org6765798"></a>

## Todo Setup

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


<a id="org17c03f5"></a>

## Block Templates

    (require 'org-tempo)
    (with-eval-after-load 'org-tempo
      (add-to-list 'org-structure-template-alist '("sh" . "src sh"))
      (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp")))


<a id="orga1ea845"></a>

## Org Journal

    (use-package org-journal
      :config
      (setq org-journal-dir "~/org/journals/")
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


<a id="orgb9b59e7"></a>

## Org Roam

    (use-package emacsql)
    (use-package emacsql-sqlite)
    
    
    ;; This setup is designed to allow org-roam to work with logseq.
    ;; The org-roam directory is also the logseq directory. The
    ;; org-roam dailies directory is set to be the same one logseq
    ;; uses. Then for the capture templtes we put files in the `pages`
    ;; directory. I followed this post to do this:
    ;; https://coredumped.dev/2021/05/26/taking-org-roam-everywhere-with-logseq/
    (use-package org-roam
      :after (emacsql emacsql-sqlite)
      :custom
      (org-roam-directory "~/org/old-notes")
      (org-roam-dailies-directory "journals/")
      (org-roam-file-exclude-regexp "\\.st[^/]*\\|logseq/.*$")
      (org-roam-capture-templates
       '(("d" "default" plain
          "%?" :target
          (file+head "pages/${slug}.org" "#+title: ${title}\n")
          :unnarrowed t)))
      (org-roam-dailies-capture-templates '(("d" "default"
                                             entry
                                             "* %?"
                                             :target (file+head "%<%Y_%m_%d>.org" "#+title: %<%Y-%m-%d>\n"))))
      :config
      (org-roam-setup))
    
    
    ;; This is a repository version of a script/gist that helps covert
    ;; logseq files so that they will work with org-roam. It's also
    ;; part of the post above.
    (use-package org-roam-logseq
      :straight
      (:type git :host github :repo "sbougerel/org-roam-logseq.el")
      :init
      (setq bill/logseq-folder "~/org/tastes")
      :custom
      (bill/logseq-folder "~/org/tastes")
      (bill/logseq-pages "~/org/tastes/pages")
      (bill/logseq-journals "~/org/tastes/journals")
      )


<a id="orgcb9db18"></a>

## Org  Contrib Additions

    (use-package org-contrib
      :config
      (require 'ox-extra)
      (ox-extras-activate '(ignore-headlines)))


<a id="org795bdba"></a>

# Other stuff


<a id="org2de315e"></a>

## Gptel (Chat GPT)

    (use-package gptel
      :config
      (setq gptel-api-key secret/openai-api-key))

