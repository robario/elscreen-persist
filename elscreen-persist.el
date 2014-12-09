;;; elscreen-persist.el --- persist the elscreen across sessions
;; Copyright (C) 2014  Hironori Yoshida

;; Author: Hironori Yoshida <webmaster@robario.com>
;; Keywords: elscreen frames
;; Version: 0.1.1
;; Package-Requires: ((elscreen "1.4.6") (revive "2.1.9"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This makes elscreen persistent.
;;
;; To use this, use customize to turn on `elscreen-persist-mode`
;; or add the following line somewhere in your init file:
;;
;;     (elscreen-persist-mode 1)
;;
;; Or manually, use `elscreen-persist-store` to store,
;; and use `elscreen-persist-restore` to restore.
;;
;; Please see README.md from the same repository for documentation.

;;; Code:

(require 'elscreen)
(require 'revive)

(defcustom elscreen-persist-file (locate-user-emacs-file "elscreen")
  "The file where the elscreen configuration is stored."
  :type 'file
  :group 'elscreen)

;;;###autoload
(defun elscreen-persist-store ()
  "Store the frame parameters, window configurations and elscreen."
  (interactive)
  (let ((frame-parameters (frame-parameters))
        (current-screen (elscreen-get-current-screen))
        screen-to-window-configuration-alist)
    ;; Delete some unserializable frame parameter.
    (dolist (key '(buffer-list buried-buffer-list minibuffer))
      (delq (assq key frame-parameters) frame-parameters))

    ;; Collect all the screen and window configurations.
    ;; - The first element is a last (max screen number) screen configuration.
    ;; - The last element is a current screen configuration.
    (dolist (screen (sort (elscreen-get-screen-list) '<))
      (elscreen-goto screen)
      (let ((screen-to-window-configuration (list (cons screen (current-window-configuration-printable)))))
	(setq screen-to-window-configuration-alist
	      (if (eq screen current-screen)
		  (append screen-to-window-configuration-alist screen-to-window-configuration)
		(append screen-to-window-configuration screen-to-window-configuration-alist)))))

    ;; Store the configurations.
    (with-temp-file elscreen-persist-file
      (insert (prin1-to-string (list (cons 'frame-parameters frame-parameters)
                                     (cons 'screen-to-window-configuration-alist screen-to-window-configuration-alist)))))))

;;;###autoload
(defun elscreen-persist-restore ()
  "Restore the frame parameters, window configurations and elscreen."
  (interactive)
  (when (file-exists-p elscreen-persist-file)
    (let* ((config (read (with-temp-buffer (insert-file-contents elscreen-persist-file) (buffer-string))))
           (frame-parameters (assoc-default 'frame-parameters config))
           (screen-to-window-configuration-alist (assoc-default 'screen-to-window-configuration-alist config)))
      ;; Restore the frame parameters.
      (modify-frame-parameters nil frame-parameters)

      ;; Restore all the screen and window configurations.
      (dolist (screen-to-window-configuration screen-to-window-configuration-alist)
        (while (not (elscreen-screen-live-p (car screen-to-window-configuration)))
          (elscreen-create))
        (elscreen-goto (car screen-to-window-configuration))
        (restore-window-configuration (cdr screen-to-window-configuration)))

      ;; Kill unnecessary screens.
      (dolist (screen (elscreen-get-screen-list))
        (unless (assq screen screen-to-window-configuration-alist)
          (elscreen-kill screen))))))

;;;###autoload
(define-minor-mode elscreen-persist-mode
  "Toggle persistent elscreen (ElScreen Persist mode).
With a prefix argument ARG, enable ElScreen Persist mode if ARG is
positive, and disable it otherwise.  If called from Lisp, enable
the mode if ARG is omitted or nil."
  :group 'elscreen
  :global t
  (if elscreen-persist-mode
      (progn
        (add-hook 'kill-emacs-hook 'elscreen-persist-store)
        (add-hook 'after-init-hook 'elscreen-persist-restore))
    (remove-hook 'kill-emacs-hook 'elscreen-persist-store)
    (remove-hook 'after-init-hook 'elscreen-persist-restore)))

(provide 'elscreen-persist)
;;; elscreen-persist.el ends here
