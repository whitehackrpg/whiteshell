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

(defun whiteshell ()
  (format t "Welcome to the Whiteshell REPL. Type 'i' for commands.~%")
  (weak-repl))

(defun weak-repl ()
  (format t "> ")
  (flet ((illegalp (str) 
	   (intersection (coerce str 'list) '(#\( #\) #\' #\, #\`))))
    (let* ((commands (append '(average-hp hp-roller print-map quit 
			       a d r +dr -dr monster)
			     (loop for n to 30 collect n)))
	   (str (read-line))
	   (inp (if (illegalp str) 
		    '(bad) 
		    (read-from-string (format nil "(~a)" str))))
	   (input (cons (car inp) 
			(mapcar #'(lambda (a) `',a) (cdr inp)))))
      (cond ((member (car input) commands)
	     (unless (and (eq (car input) 'quit) (print 'bye!))
	       (format t "~{~a ~}~%" (multiple-value-list 
				      (eval (if (numberp (car input))
						(cons 'a input)
						input))))
	       (weak-repl)))
	    (t (format t "Allowed commands:~{ ~a~}.~%" commands) 
	       (weak-repl))))))
  
(defun bot ()
  (setf *random-state* (make-random-state t))
  (let ((args (uiop:command-line-arguments)))
    (if (and (member (car args)
		     '("whiteshell::average-hp" "whiteshell::hp-roller"
		       "whiteshell::print-map" "whiteshell::quit"
		       "whiteshell::a" "whiteshell::d" "whiteshell::r"
		       "whiteshell::+dr" "whiteshell::-dr" 
		       "whiteshell::monster") 
		     :test #'string=)
	     (null (intersection '(#\( #\) #\' #\, #\`) 
				 (coerce (format nil "~{~a~^ ~}"
						 args)
					 'list))))
	(let ((output (apply (read-from-string 
			      (car args))
			     (mapcar #'read-from-string 
				     (cdr args)))))
	  (when output (print output) (terpri)))
	(format t "Not allowed~%"))))
