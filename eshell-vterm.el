;;; eshell-vterm.el --- Vterm for visual commands in eshell. -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'vterm)
(require 'em-term)
(require 'esh-ext)

(defun eshell-vterm-exec-visual (&rest args)
  "Run the specified PROGRAM in a terminal emulation buffer.
ARGS are passed to the program.  At the moment, no piping of input is
allowed."
  (let* (eshell-interpreter-alist
	 (interp (eshell-find-interpreter (car args) (cdr args)))
         (program (car interp))
	 (args (flatten-tree
		(eshell-stringify-list (append (cdr interp)
					       (cdr args)))))
         (args (mapconcat 'identity args " "))
	 (term-buf (generate-new-buffer
	            (concat "*" (file-name-nondirectory program) "*")))
	 (eshell-buf (current-buffer))
         (vterm-shell (concat program " " args)))
    (save-current-buffer
      (switch-to-buffer term-buf)
      (vterm-mode)
      (setq-local eshell-parent-buffer eshell-buf)
      (let ((proc (get-buffer-process term-buf)))
	(if (and proc (eq 'run (process-status proc)))
	    (set-process-sentinel proc #'eshell-vterm-sentinel)
	  (error "Failed to invoke visual command")))))
  nil)

(defun eshell-vterm-sentinel (proc msg)
  "Clean up the buffer visiting PROC.
If `eshell-destroy-buffer-when-process-dies' is non-nil, destroy
the buffer."
  (let ((vterm-kill-buffer-on-exit nil))
    (vterm--sentinel proc msg)) ;; First call the normal term sentinel.
  (when eshell-destroy-buffer-when-process-dies
    (let ((proc-buf (process-buffer proc)))
      (when (and proc-buf (buffer-live-p proc-buf)
                 (not (eq 'run (process-status proc)))
                 (= (process-exit-status proc) 0))
        (if (eq (current-buffer) proc-buf)
            (let ((buf (and (boundp 'eshell-parent-buffer)
                            eshell-parent-buffer
                            (buffer-live-p eshell-parent-buffer)
                            eshell-parent-buffer)))
              (if buf
                  (switch-to-buffer buf))))
        (kill-buffer proc-buf)))))

;;;###autoload
(define-minor-mode eshell-vterm-mode
  "Use Vterm for eshell visual commands."
  :global t
  :group 'eshell-vterm
  (if eshell-vterm-mode
      (advice-add #'eshell-exec-visual :override #'eshell-vterm-exec-visual)
    (advice-remove #'eshell-exec-visual #'eshell-vterm-exec-visual)))

(provide 'eshell-vterm)
;;; eshell-vterm.el ends here
