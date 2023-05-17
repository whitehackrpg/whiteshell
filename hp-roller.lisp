;;;; hp-roller. The class-hp list and class case names are built from hard-coded
;;;; Whitehack content, pp. 32, 81, 83, 84.

(in-package #:whiteshell)

(defun d6 (&optional print)
  (let ((result (1+ (random 6))))
    (when print (print result))
    result))

(defun nd6 (n &optional (mod 0) print)
  (if (zerop n) 
      0
      (+ mod (d6 print) (nd6 (1- n) 0 print))))

(let ((class-hp '((1 2 (2 . 1) 3 (3 . 1) 4 (4 . 1) 5 (5 . 1) 6)
		  ((1 . 2) 2 3 4 5 6 7 8 9 10)
		  ((1 . 1) 2 (2 . 1) 3 4 (4 . 1) 5 6 (6 . 1) 7)
		  (#C(1 2) #C(2 2) #C(3 2) 4 5 6 7 8 9 10))))
  
  (defun hp-roller (class level &optional print)
    (let ((hp-list (cond ((equalp (write-to-string class) "strong") 1)
			 ((equalp (write-to-string class) "wise") 2)
			 ((equalp (write-to-string class) "brave") 3)
			 (t 0))))
      (if (zerop level)
	  0
	  (let ((thisroll (nth (1- level) (nth hp-list class-hp))))
	    (max (cond ((consp thisroll)
			(nd6 (car thisroll) (cdr thisroll) print))
		       ((complexp thisroll)
			(max (nd6 (realpart thisroll) 0 print)
			     (nd6 (realpart thisroll) 0 print)))
		       (t (nd6 thisroll 0 print)))
		 (hp-roller class (1- level) print)))))))
  
(defun average-hp (class level &optional (times 1000))
  (average (hp-roller class level) times))

