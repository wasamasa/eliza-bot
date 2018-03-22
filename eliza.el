(require 'subr-x)

(defun eliza-eval (input)
  (when (not (get-buffer "*doctor*"))
    (call-interactively 'doctor))
  (with-current-buffer "*doctor*"
    (goto-char (point-max))
    (insert input)
    (goto-char (point-max))
    (let ((start (point)))
      (call-interactively 'doctor-ret-or-read)
      (call-interactively 'doctor-ret-or-read)
      (string-trim (buffer-substring-no-properties start (point-max))))))

(defun eliza-read ()
  (ignore-errors
    (read-from-minibuffer "")))

(defun eliza-repl ()
  (let ((input "")
        line)
    (while (setq line (eliza-read))
      (setq input (concat input line "\n"))
      (when (string-match-p "\n\n\\'" input)
        (setq input (string-trim input))
        (when (not (string-empty-p input))
          (let ((response (eliza-eval (string-trim input))))
            (princ (format "%s\n\n" response))))
        (setq input "")))
    (terpri)))

(eliza-repl)
