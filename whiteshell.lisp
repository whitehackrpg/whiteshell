;;;; whiteshell.lisp

(in-package #:whiteshell)

;;; If on Windows:
;;; (cffi:define-foreign-library blt:bearlibterminal
;;;   (t "./BearLibTerminal.dll"))
;;; (cffi:use-foreign-library blt:bearlibterminal)


(defun random-item (input &optional pretty)
  "Return or print a random item either from a file with a list or an actual Lisp list."
  (let* ((thelist (if (listp input) input (uiop:read-file-lines input)))
	 (pick (nth (random (length thelist)) thelist)))
    (if pretty (format t "~a" pick) pick)))
    
