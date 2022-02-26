(setq user-full-name "Mislav Zanic"
      user-mail-address "mislavzanic3@gmail.com")

(map! :leader
      (:prefix ("b". "buffer")
       :desc "List bookmarks" "L" #'list-bookmarks
       :desc "Save current bookmarks to bookmark file" "w" #'bookmark-save))

(map! :leader
      (:prefix ("d" . "dired")
       :desc "Open dired" "d" #'dired
       :desc "Dired jump to current" "j" #'dired-jump)
      (:after dired
       (:map dired-mode-map
        :desc "Peep-dired image previews" "d p" #'peep-dired
        :desc "Dired view file" "d v" #'dired-view-file)))

(evil-define-key 'normal dired-mode-map
  (kbd "M-RET") 'dired-display-file
  (kbd "h") 'dired-up-directory
  (kbd "l") 'dired-find-file ; use dired-find-file instead of dired-open.
  (kbd "m") 'dired-mark
  (kbd "t") 'dired-toggle-marks
  (kbd "u") 'dired-unmark
  (kbd "C") 'dired-do-copy
  (kbd "D") 'dired-do-delete
  (kbd "J") 'dired-goto-file
  (kbd "M") 'dired-chmod
  (kbd "O") 'dired-chown
  (kbd "P") 'dired-do-print
  (kbd "R") 'dired-rename
  (kbd "T") 'dired-do-touch
  (kbd "Y") 'dired-copy-filenamecopy-filename-as-kill ; copies filename to kill ring.
  (kbd "+") 'dired-create-directory
  (kbd "-") 'dired-up-directory
  (kbd "% l") 'dired-downcase
  (kbd "% u") 'dired-upcase
  (kbd "; d") 'epa-dired-do-decrypt
  (kbd "; e") 'epa-dired-do-encrypt)

;; If peep-dired is enabled, you will get image previews as you go up/down with 'j' and 'k'
(evil-define-key 'normal peep-dired-mode-map
  (kbd "j") 'peep-dired-next-file
  (kbd "k") 'peep-dired-prev-file)
(add-hook 'peep-dired-hook 'evil-normalize-keymaps)
;; Get file icons in dired
;(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)

(setq fancy-splash-image "~/.config/doom/doom.png")
;;(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)
;;(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-footer)
;;(remove-hook '+doom-dashboard-functions #'+doom-dashboard-widget-banner)
(setq +doom-dashboard-banner-file (expand-file-name "doom.png" doom-private-dir)
      +doom-dashboard-banner-dir  "~/.emacs.d/modules/ui/doom-dashboard/")
(setq doom-theme 'kaolin-aurora)

(setq doom-font (font-spec :family "Mononoki Nerd Font" :size 13)
      doom-variable-pitch-font (font-spec :family "Mononoki Nerd Font" :size 13)
      doom-big-font (font-spec :family "Mononoki Nerd Font" :size 24))
(after! doom-themes
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))
(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-keyword-face :slant italic))

(setq org-directory "~/org/")

(setq display-line-numbers-type 'relative
      tab-always-indent 'complete)

;;(define-key evil-normal-state-map (kbd ";") 'evil-ex)

;; (use-package! password-store)

(after! doom-modeline
    (setq doom-modeline-major-mode-icon t
          doom-modeline-buffer-state-icon t
          doom-modeline-buffer-encoding nil)
    (remove-hook 'doom-modeline-mode-hook #'size-indication-mode))

(add-hook 'c++-mode-hook (lambda () (setq flycheck-gcc-language-standard "c++17")))
(add-hook 'c++-mode-hook (lambda () (setq flycheck-clang-language-standard "c++17")))
;(add-hook 'c++-mode-hook
;          '(lambda ()
;             (setq indent-tabs-mode nil)
;             (setq tab-width 4)
;             (setq indent-line-function (quote insert-tab))))

(setq lsp-clients-clangd-args '("-j=3"
                                "--background-index"
                                "--clang-tidy"
                                "--completion-style=detailed"
                                "--header-insertion=never"
                                "--header-insertion-decorators=0"))
(after! lsp-clangd (set-lsp-priority! 'clangd 2))

(use-package omnisharp
  :after company
  :config
  (add-hook 'csharp-mode-hook 'omnisharp-mode)
  (add-to-list 'company-backends 'company-omnisharp))

(defun disable-tabs () (setq indent-tabs-mode nil))
(defun enable-tabs  ()
  (local-set-key (kbd "TAB") 'tab-to-tab-stop)
  (setq indent-tabs-mode t)
  (setq tab-width custom-tab-width))
(setq-default electric-indent-inhibit t)
(setq backward-delete-char-untabify-method 'hungry)
;(smart-tabs-insinuate 'c++ 'c 'javascript 'python)

;;(define-key evil-normal-state-map (kbd "z z") 'sp-wrap-round)
