;;;; draw-map (press 'i' for instructions)

(in-package #:whiteshell)

(defparameter *dimx* 76)
(defparameter *dimy* 24)
(defparameter *pen-list* 
  '((#\# #\. #\+ #\/ #\< #\> #\^ #\* #\~ #\! #\$ #\% #\& #\?)
    (#\U+2550 #\U+2551 #\U+2554 #\U+2557 #\U+255A #\U+255D)
    (#\U+2560 #\U+2563 #\U+2566 #\U+2569 #\U+256C #\U+256A #\U+256B)
    (#\U+2552 #\U+2553 #\U+2555 #\U+2556 #\U+2558 #\U+2559
     #\U+255B #\U+255C #\U+255E #\U+255F #\U+2561 #\U+2562
     #\U+2564 #\U+2565 #\U+2567 #\U+2568)
    (#\a #\b #\c #\d #\e #\f #\g #\h #\i #\j #\k #\l #\m #\n #\o #\p #\q #\r 
     #\s #\t #\u #\v #\w #\x #\y #\z)
    (#\A #\B #\C #\D #\E #\F #\G #\H #\I #\J #\K #\L #\M #\N #\O #\P #\Q #\R
     #\S #\T #\U #\V #\W #\X #\Y #\Z)))

(defparameter *instructions* (format nil "~&~AINSTRUCTIONS~&------------~&Navigation: H/J/K/L/Y/U/B/N~&Draw: space or left-click~&Delete: d or right-click~&Undo: z~&Redo: r~&Switch pen: scroll-wheel or a (left) and f (right)~&Switch pen-set: g or middle-click~&Print to REPL: s~&Print instructions: i~&Quit: escape (also prints to the REPL)~&~ACall draw-map with the keyword argument ':savedmap' to start with a saved map (text format), and/or ':pen-list' to add a custom pen-set (formatted as a list of characters).~&~A" #\linefeed #\linefeed #\linefeed))
(defparameter *font* (asdf:system-relative-pathname "whiteshell" "fonts/RobotoMono-Regular.ttf"))
(defparameter *font-size* 13)
(defparameter *default-color* (blt:rgba 110 160 110))
(defparameter *highlight-color* (blt:rgba 210 250 210))

(defparameter *undo* ())
(defparameter *redo* ())

(defun list-dims (list-o-strings)
  "Return the x and y dimensions of a list of strings, and the list."
  (let ((count 0))
    (dolist (line list-o-strings 
		  (values count (length list-o-strings) list-o-strings))
      (let ((stringcount (length line)))
	(when (> stringcount count) (setf count stringcount))))))
  
(defmacro cell (n) 
  `(blt:cell-char (realpart ,n) (imagpart ,n)))

(defun mouse-wheel ()
  (blt/ll:terminal-state blt/ll:+tk-mouse-wheel+))

(defun map-action (xy char)
  (push (list (cons xy char) 
	      (cons xy (blt:cell-char (realpart xy) (imagpart xy))))
	*undo*)
  (setf (cell xy) char
	*redo* ()))
  
(defun undo ()
  (let ((action (pop *undo*)))
    (unless (null action)
      (push action *redo*)
      (setf (cell (caadr action)) (cdadr action)))))

(defun redo ()
  (let ((action (pop *redo*)))
    (unless (null action)
      (push action *undo*)
      (setf (cell (caar action)) (cdar action)))))
  

(defun tick (xy pen-set pen extra-pens)
  (let* ((pen-list (if extra-pens (cons extra-pens *pen-list*) *pen-list*))
	 (pens (1- (length (nth pen-set pen-list)))))
    (labels ((pen-right () (if (< pen pens) (incf pen) (setf pen 0)))
	     (pen-left () (if (zerop pen) 
			      (setf pen (1- (length (nth pen-set pen-list))))
			      (decf pen))))
      (display-stuff xy pen-set pen-list pen)
      (blt:key-case 
       (blt:read) 
       (:escape (setf xy 'quit))
       (:f (pen-right))
       (:mouse-scroll (cond ((plusp (mouse-wheel)) (pen-right))
			    ((minusp (mouse-wheel)) (pen-left))))
       (:a (pen-left))
       ((or :g :mouse-middle) 
	(if (= pen-set (1- (length pen-list)))
	    (setf pen-set 0) 
	    (incf pen-set))
	(when (> pen (1- (length (nth pen-set pen-list))))
	  (setf pen 0)))
       (:s (print-it))
       (:space (map-action xy (nth pen (nth pen-set pen-list))))
       (:mouse-left (map-action (complex (blt:mouse-x) (blt:mouse-y))
				(nth pen (nth pen-set pen-list))))
       (:mouse-right (map-action (complex (blt:mouse-x) (blt:mouse-y))
			   #\SPACE))
       (:d (setf (cell xy) #\SPACE))
       (:k (incf xy #C( 0 -1))) (:j (incf xy #C(0  1)))
       (:h (incf xy #C(-1  0))) (:l (incf xy #C(1  0)))
       (:y (incf xy #C(-1 -1))) (:u (incf xy #C(1 -1)))
       (:i (format t "~&~A" *instructions*))
       (:z (undo))
       (:r (redo))
       (:b (incf xy #C(-1  1))) (:n (incf xy #C(1  1))))
      (cond ((eq xy 'quit) (print-it))
	    (t (setf (blt:layer) 1)
	       (setf (blt:color) *highlight-color*
		     (cell xy) (nth pen (nth pen-set pen-list))
		     (cell (complex (blt:mouse-x) (blt:mouse-y)))
		     (nth pen (nth pen-set pen-list))
		     (blt:color) *default-color*
		     (blt:layer) 0)
	       (tick xy pen-set pen extra-pens))))))

(defun display-stuff (xy pen-set pen-list pen)
    (blt:print 0 0 (format nil "~a" (nth pen-set pen-list)))
    (blt:print (1+ (* pen 2)) 1 "-")
    (blt:refresh)
    (blt:print 0 0 "                                                                          ")
    (blt:print (1+ (* pen 2)) 1 " ")
    (setf (blt:layer) 1
	  (cell xy) #\SPACE
	  (cell (complex (blt:mouse-x) (blt:mouse-y))) #\SPACE
	  (blt:layer) 0))

(defun print-it ()
  (dotimes (y *dimy*)
    (dotimes (x *dimx* (terpri))
      (format t "~A" (or (blt:cell-char x y) #\SPACE)))))

(defun draw-map (&key savedmap extra-pens)
  (blt:with-terminal
    (blt:set "window.title = Whiteshell DRAW-MAP")
    (blt:set "input.filter = keyboard, mouse")
    (blt:set "input.mouse-cursor = false")
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
    (tick (complex 1 2) 0 0 extra-pens)))
