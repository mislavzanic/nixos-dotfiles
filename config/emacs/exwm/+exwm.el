;;; +exwm.el --- Description -*- lexical-binding: t; -*-
;;; Commentary:
;;
;;  Description
;;
;;; Code:



(defun efs/exwm-update-class ()
  (exwm-workspace-rename-buffer exwm-class-name))

(defun efs/run-in-background (command)
  (let ((command-parts (split-string command "[ ]+")))
    (apply #'call-process `(,(car command-parts) nil 0 nil ,@(cdr command-parts)))))

(defun efs/set-wallpaper ()
  (interactive)
  (start-process-shell-command
   "feh" nil "feh --bg-fill ~/.local/share/bg"))

(defun efs/exwm-init-hook ()
  (exwm-workspace-switch-create 1)

  (setq display-time-day-and-date t)
  (display-time-mode 1)

  (efs/start-panel)
  (efs/run-in-background "nm-applet")
  (efs/run-in-background "blueman-applet")
  (efs/run-in-background "pasystray"))

(defun efs/screenshot ()
  (interactive)
  (start-process-shell-command "scrot" nil "scrot -s"))

(defun efs/exwm-update-title ()
  (pcase exwm-class-name
    ("Firefox" (exwm-workspace-rename-buffer (format "Firefox: %s" exwm-title)))
    ("zathura" (exwm-workspace-rename-buffer (format "Zathura: %s" exwm-title)))
    ("qutebrowser" (exwm-workspace-rename-buffer (format "qutebrowser: %s" exwm-title)))))

(defun efs/update-displays ()
  (efs/run-in-background "autorandr --change --force")
  (efs/set-wallpaper)
  (message "Display config: %s"
           (string-trim (shell-command-to-string "autorandr --current"))))

(defun efs/get-monitor-list (env-str)
  (let ((env-var (getenv env-str)))
    (if env-var
        (split-string env-var)
      nil)))

(defun efs/build-workspace-monitor-plist (list)
    (let (transformed-list first second (rev-list (reverse list)))
      (while rev-list
        (setq second (car rev-list))
        (setq first (string-to-number (car (cdr rev-list))))
        (setq transformed-list (cons first (cons second transformed-list)))
        (setq rev-list (cdr (cdr rev-list)))
        )
      transformed-list))

(defvar efs/polybar-hdmi nil
  "Holds the process of the running Polybar instance, if any")

(defvar efs/polybar-dp nil
  "Holds the process of the running Polybar instance, if any")

(defun efs/kill-panel ()
  (interactive)
  (when efs/polybar-hdmi
    (ignore-errors
      (kill-process efs/polybar-hdmi)))
  (setq efs/polybar-hdmi nil)
  (when efs/polybar-dp
    (ignore-errors
      (kill-process efs/polybar-dp)))
  (setq efs/polybar-dp nil))

(defun efs/start-panel ()
  (interactive)
  (efs/kill-panel)
  (setq efs/polybar-hdmi (start-process-shell-command "polybar" nil "polybar HDMI0"))
  (setq efs/polybar-dp (start-process-shell-command "polybar" nil "polybar DP0")))

(defun efs/send-polybar-hook (module-name hook-index)
  (start-process-shell-command "polybar-msg" nil (format "polybar-msg hook %s %s" module-name hook-index)))

(defun efs/send-polybar-exwm-workspace ()
  (efs/send-polybar-hook "exwm-workspace" 1))

(use-package! exwm
  :init
  (setq
   ;; Use the primary clipboard.
   select-enable-primary t
   ;; Follow the mouse.
   focus-follows-mouse t
   ;; Move the focus to the followed window.
   mouse-autoselect-window t
   exwm-workspace-number 5)

  :config

  (add-hook 'exwm-update-class-hook #'efs/exwm-update-class)
  (add-hook 'exwm-init-hook #'efs/exwm-init-hook)

  (start-process-shell-command "xmodmap" nil "xmodmap ~/.config/.dotfiles/config/emacs/exwm/Xmodmap")

  (start-process-shell-command "xsetroot" nil "xsetroot -cursor_name left_ptr")

  (require 'exwm-randr)
  (exwm-randr-enable)

  (setq efs/monitor-list (efs/get-monitor-list "MONITOR_LIST"))
  (setq exwm-randr-workspace-monitor-plist (efs/build-workspace-monitor-plist efs/monitor-list))

  (add-hook 'exwm-update-title-hook #'efs/exwm-update-title)

  (add-hook 'exwm-randr-screen-change-hook
    (lambda ()
      (start-process-shell-command
        "xrandr" nil (substitute-env-vars "xrandr --output ${PRIMARY_MONITOR} --mode ${PRIMARY_MONITOR_RES} --pos ${PRIMARY_MONITOR_POS} --rotate normal --output ${SECONDARY_MONITOR} --mode ${SECONDARY_MONITOR_RES} --pos ${SECONDARY_MONITOR_POS} --rotate normal"))))

  (add-hook 'exwm-randr-screen-change-hook #'efs/update-displays)
  (efs/update-displays)

  (setq exwm-workspace-warp-cursor t)

  (efs/set-wallpaper)

  (setq exwm-input-prefix-keys
    '(?\C-x
      ?\C-u
      ?\C-h
      ?\M-x
      ?\M-`
      ?\M-&
      ?\M-:
      ?\C-\M-j  ;; Buffer list
      ?\C-\ ))  ;; Ctrl+Space

  (define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

  (setq exwm-input-global-keys
        `(
          ;; Reset to line-mode (C-c C-k switches to char-mode via exwm-input-release-keyboard)
          ([?\s-r] . exwm-reset)

          ([?\s-b] . counsel-switch-buffer)
          ([?\s-q] . persp-kill-buffer)
          ([?\s-Q] . kill-this-buffer)

          ([?\s-i] . exwm-input-toggle-keyboard)
          ([?\s-f] . exwm-layout-toggle-fullscreen)

          ;; Move between windows
          ([?\s-h] . windmove-left)
          ([?\s-j] . windmove-down)
          ([?\s-k] . windmove-up)
          ([?\s-l] . windmove-right)
          ([?\s-H] . windower-swap-left)
          ([?\s-J] . windower-swap-below)
          ([?\s-K] . windower-swap-above)
          ([?\s-L] . windower-swap-right)

          (,(kbd "s-<tab>") . windower-toggle-single)
          (,(kbd "s-s") . windower-toggle-split)
          (,(kbd "s-v") . evil-window-vsplit)


          ;; Launch applications via shell command
          ([?\s-&] . (lambda (command)
                       (interactive (list (read-shell-command "$ ")))
                       (start-process-shell-command command nil command)))

          ;; Switch workspace
          ([?\s-w] . exwm-workspace-switch)
          ([?\s-`] . (lambda () (interactive) (exwm-workspace-switch-create 0)))

          ;; 's-N': Switch to certain workspace with Super (Win) plus a number key (0 - 9)
          ,@(mapcar (lambda (i)
                      `(,(kbd (format "s-%d" i)) .
                        (lambda ()
                          (interactive)
                          (exwm-workspace-switch-create ,i))))
                    (number-sequence 0 9))))
  (exwm-input-set-key (kbd "s-p") 'dmenu)

  (exwm-enable))

;; Update panel indicator when workspace changes
(add-hook 'exwm-workspace-switch-hook #'efs/send-polybar-exwm-workspace)

(use-package! helm-exwm
  :config
  (setq helm-exwm-emacs-buffers-source (helm-exwm-build-emacs-buffers-source))
  (setq helm-exwm-source (helm-exwm-build-source))
  (setq helm-mini-default-sources `(helm-exwm-emacs-buffers-source
                                    helm-exwm-source
                                    helm-source-recentf)))
(require 'helm-exwm)

(use-package! dmenu)
;;; +exwm.el ends here
