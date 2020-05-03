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
