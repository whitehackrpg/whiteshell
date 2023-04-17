;;;; draw-map
;;;; use vi-keys to navigate, space to draw, d to delete, a and f to switch
;;;; pen, g to switch pen-set, s to print to the REPL and escape to quit (also 
;;;; printing to the repl). You can call draw-map with a saved textfile to 
;;;; start on an old map, and/or with an extra set of pens.

(in-package #:whiteshell)

(defvar *dimx* 76)
(defvar *dimy* 20)
(defparameter *pen-list* '((#\. #\# #\+ #\SPACE #\/ #\~)
		     (#\U+2550 #\U+2551 #\U+2554 #\U+2557 #\U+255A #\U+255D
		      #\U+2560 #\U+2563 #\U+2566 #\U+2569 #\U+256C)
		     (#\U+2552 #\U+2553 #\U+2555 #\U+2556 #\U+2558 #\U+2559
		      #\U+255B #\U+255C #\U+255E #\U+255F #\U+2561 #\U+2562
		      #\U+2564 #\U+2565 #\U+2567 #\U+2568 #\U+256A #\U+256B)))

(defparameter *font* (asdf:system-relative-pathname "whiteshell" "fonts/RobotoMono-Regular.ttf"))
(defparameter *font-size* 12)
(defparameter *default-color* (blt:rgba 120 160 120))


(defun list-dims (list-o-strings)
  "Return the x and y dimensions of a list of strings, and the list."
  (let ((count 0))
    (dolist (line list-o-strings 
		  (values count (length list-o-strings) list-o-strings))
      (let ((stringcount (length line)))
	(when (> stringcount count) (setf count stringcount))))))
  
(defmacro cell (n) 
  `(blt:cell-char (realpart ,n) (imagpart ,n)))

(defun tick (xy pen-set pen extra-pens)
  (let* ((pen-list (if extra-pens (cons extra-pens *pen-list*) *pen-list*))
	 (pens (1- (length (nth pen-set pen-list)))))
    (display-stuff xy pen-set pen-list pen)
    (blt:key-case 
     (blt:read) (:escape (setf xy 'quit))
     (:f (if (< pen pens) (incf pen) (setf pen 0)))
     (:a (if (zerop pen) 
	     (setf pen (1- (length (nth pen-set pen-list))))
	     (decf pen)))
     (:g (if (= pen-set (1- (length pen-list)))
	     (setf pen-set 0) 
	     (incf pen-set))
	 (when (> pen (1- (length (nth pen-set pen-list))))
	     (setf pen 0)))
     (:s (print-it))
     (:space (setf (cell xy) (nth pen (nth pen-set pen-list))))
     (:d (setf (cell xy) #\SPACE))
     (:k (incf xy #C( 0 -1))) (:j (incf xy #C(0  1)))
     (:h (incf xy #C(-1  0))) (:l (incf xy #C(1  0)))
     (:y (incf xy #C(-1 -1))) (:u (incf xy #C(1 -1)))
     (:b (incf xy #C(-1  1))) (:n (incf xy #C(1  1))))
    (cond ((eq xy 'quit) (print-it))
	  (t (setf (blt:layer) 1)
	     (setf (cell xy) (nth pen (nth pen-set pen-list))
		   (blt:layer) 0)
	     (tick xy pen-set pen extra-pens)))))

(defun display-stuff (xy pen-set pen-list pen)
    (blt:print 0 0 (format nil "~a" (nth pen-set pen-list)))
    (blt:print (1+ (* pen 2)) 1 "-")
    (blt:refresh)
    (blt:print 0 0 "                                           ")
    (blt:print (1+ (* pen 2)) 1 " ")
    (setf (blt:layer) 1
	  (cell xy) #\SPACE
	  (blt:layer) 0))

(defun print-it ()
  (dotimes (y *dimy*)
    (dotimes (x *dimx* (terpri))
      (format t "~A" (or (blt:cell-char x y) #\SPACE)))))

(defun draw-map (&key savedmap extra-pens)
  (blt:with-terminal
    (blt:set "font: ~A, size=~A" *font* *font-size*) 
    (setf (blt:color) *default-color*)
    (if savedmap
	(multiple-value-bind (xdim ydim lines) 
	    (list-dims (uiop:read-file-lines savedmap))
	  (setf *dimx* xdim *dimy* ydim)
	  (blt:set "window.size = ~AX~A" *dimx* *dimy*)
	  (dotimes (line *dimy*) 
	    (dotimes (pos (length (nth line lines)))
	      (setf (cell (complex pos line))
		    (char (nth line lines) pos)))))
	(progn (blt:set "window.size = ~AX~A" *dimx* *dimy*)
	       (dotimes (x *dimx*)
		 (dotimes (y *dimy*)
		   (setf (cell (complex x y)) #\SPACE)))))
    (tick (complex (round *dimx* 2) (round *dimy* 2)) 0 0 extra-pens)))
