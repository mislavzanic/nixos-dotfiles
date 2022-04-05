(server-start)

(setq user-full-name "Mislav Zanic"
      user-mail-address "mislavzanic3@gmail.com")

(map! :leader
      (:prefix ("b". "buffer")
       :desc "List bookmarks" "L" #'list-bookmarks
       :desc "Save current bookmarks to bookmark file" "w" #'bookmark-save))

(setq fancy-splash-image "~/.config/doom/logo.png")
(setq +doom-dashboard-banner-file (expand-file-name "doom.png" doom-private-dir)
      +doom-dashboard-banner-dir  "~/.emacs.d/modules/ui/doom-dashboard/")

(set-frame-parameter (selected-frame) 'alpha '(85 . 85))
(add-to-list 'default-frame-alist '(alpha . (85 . 85)))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(setq doom-theme 'modus-vivendi)

(after! doom-modeline
    (setq doom-modeline-major-mode-icon t
          doom-modeline-buffer-state-icon t
          doom-modeline-buffer-encoding nil)
    (remove-hook 'doom-modeline-mode-hook #'size-indication-mode))

(setq display-line-numbers-type 'relative
      tab-always-indent 'complete)

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

(when IS-LINUX
    (load! "+exwm"))

(setq doom-font (font-spec :family "JetBrains Mono Nerd Font" :size 12)
      doom-variable-pitch-font (font-spec :family "JetBrains Mono Nerd Font" :size 12)
      doom-big-font (font-spec :family "JetBrains Mono Nerd Font" :size 24))
(after! doom-themes
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))
(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-keyword-face :slant italic))

(setq ivy-posframe-display-functions-alist
      '((swiper                     . ivy-posframe-display-at-point)
        (complete-symbol            . ivy-posframe-display-at-point)
        (counsel-M-x                . ivy-display-function-fallback)
        (counsel-esh-history        . ivy-posframe-display-at-window-center)
        (counsel-describe-function  . ivy-display-function-fallback)
        (counsel-describe-variable  . ivy-display-function-fallback)
        (counsel-find-file          . ivy-display-function-fallback)
        (counsel-recentf            . ivy-display-function-fallback)
        (counsel-register           . ivy-posframe-display-at-frame-bottom-window-center)
        (dmenu                      . ivy-posframe-display-at-frame-top-center)
        (nil                        . ivy-posframe-display))
      ivy-posframe-height-alist
      '((swiper . 20)
        (dmenu . 20)
        (t . 10)))
;; (ivy-posframe-mode 1) ; 1 enables posframe-mode, 0 disables it.

(map! :leader
      (:prefix ("v" . "Ivy")
       :desc "Ivy push view" "v p" #'ivy-push-view
       :desc "Ivy switch view" "v s" #'ivy-switch-view))

(defun efs/org-babel-tangle-config ()
  (when (string-equal (buffer-file-name)
                      (expand-file-name "~/.config/.dotfiles/config/doom/config.org"))
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))
(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

(map! :leader
      :desc "Org babel tangle" "m B" #'org-babel-tangle)

(setq org-directory "~/.local/org/"
      org-agenda-files '("~/.local/org/agenda.org")
      org-default-notes-file (expand-file-name "notes.org" org-directory)
      org-agenda-start-with-log-mode t
      org-log-done 'time
      org-log-into-drawer t
      org-ellipsis " ▼ ")

(use-package! org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "●" "○" "◆" "●" "○" "◆")))

(font-lock-add-keywords 'org-mode
                        '(("^ *\\([-]\\) "
                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
(font-lock-add-keywords 'org-journal-mode
                        '(("^ *\\([-]\\) "
                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

(set-face-attribute 'variable-pitch nil :font "Cantarell")

(custom-set-faces
  '(org-level-1 ((t (:inherit outline-1 :height 1.4))))
  '(org-level-2 ((t (:inherit outline-2 :height 1.3))))
  '(org-level-3 ((t (:inherit outline-3 :height 1.2))))
  '(org-level-4 ((t (:inherit outline-4 :height 1.1))))
  '(org-level-5 ((t (:inherit outline-5 :height 1.0)))))

(setq org-journal-dir "~/.local/org/journal/"
      org-journal-date-prefix "* "
      org-journal-time-prefix "** "
      org-journal-date-format "%B %d, %Y (%A) "
      org-journal-file-format "%Y-%m-%d.org")

(use-package! lsp-pyright
  :hook (python-mode . (lambda ()
                         (require 'lsp-pyright)
                         (lsp))))
