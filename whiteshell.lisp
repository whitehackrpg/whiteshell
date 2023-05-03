;;;; whiteshell.lisp

(in-package #:whiteshell)

#+win32
(progn (cffi:define-foreign-library blt:bearlibterminal
	 (t "./BearLibTerminal.dll"))
       (cffi:use-foreign-library blt:bearlibterminal))

(defun random-item (input &optional pretty)
  "Return or print a random item either from a file with a list or an actual Lisp list."
  (let* ((thelist (if (listp input) input (uiop:read-file-lines input)))
	 (pick (nth (random (length thelist)) thelist)))
    (if pretty (format t "~a" pick) pick)))

(defmacro average (expr &optional (times 1000))
  `(values (round (loop for n from 1 to ,times
			sum ,expr)
		  ,times)))    


(defun weak-repl ()
  (let* ((commands '(average-hp hp-roller print-map quit 
			 draw-map at dat tr +dtr -dtr))
	 (inp (read-from-string (format nil "(~a)" (read-line))))
	 (input (cons (car inp) (mapcar #'(lambda (a) `',a) (cdr inp)))))
    (cond ((member (car input) commands)
	   (unless (and (eq (car input) 'quit) (print 'bye!))
	     (format t "~{~a ~}~%" (multiple-value-list (eval input)))
	     (weak-repl)))
	  (t (format t "Allowed commands:~{ ~a~}.~%" commands) 
	     (weak-repl)))))
