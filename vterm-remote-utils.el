;;; vterm-remote-utils.el --- Vterm for visual commands in remote host

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides a way to run vterm over ssh

;;; Code:

(defun vterm-remote-make-command (cmd &optional user@host)
  "Make a command CMD with an ssh if USER+HOST is non nil"
  (if user@host (format "ssh %s -q -t \"%s\"" user@host cmd)
      (format "sh -c \"%s\"" cmd)))

(defun vterm-remote-exec-visual (cmd &optional user@host directory buffer-name)
  (let* ((default-directory "~")
	 (full-cmd (concat (if directory (format "cd %s;" directory)) cmd))
	 (vterm-shell (vterm-remote-make-command full-cmd user@host))
	 (buffer-name (or buffer-name (concat "*" (generate-new-buffer-name cmd) "*")))
	 buffer)
    (setq buffer (vterm buffer-name))
    (with-current-buffer buffer
      (multi-vterm-internal))
    (message "started vterm buffer #<%s>" (buffer-name buffer))
  ))

(defun vterm-remote-make-user@host (&optional directory)
  (let* ((directory (or directory default-directory))
	 (host (file-remote-p directory 'host))
	 (user (file-remote-p directory 'user))
	 (user@host (if host (if user (format  "%s@%s" user host) host)))
	 )
    user@host
    ))

(defun eshell/vterm-remote-run (&rest cmd-args)
  (if cmd-args
      (let ((user@host (vterm-remote-make-user@host))
	    (directory (file-local-name default-directory)))
	(vterm-remote-exec-visual (string-join cmd-args " ") user@host directory)
	)
    (message "missing args")
    ))

(provide 'vterm-remote-utils)
