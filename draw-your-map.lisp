;;;; This tool requires BearlibTerminal. Steve Losh has written an 
;;;; interface for Common Lisp: https://docs.stevelosh.com/cl-blt/
;;;; Clone it somewhere and then softlink it in your quicklisp directory.

;;; (ql:quickload :cl-blt)

;;; If on Windows:
;;; (cffi:define-foreign-library blt:bearlibterminal
;;;   (t "./BearLibTerminal.dll"))
;;; (cffi:use-foreign-library blt:bearlibterminal)


(defun draw-map (&key (dimx 76) (dimy 20) typeface savedmap
		   (pen-list '(#\. #\# #\+ #\SPACE))
		   (xy (complex (round dimx 2) (round dimy 2))))
  "Draw a roguelike map of DIMX and DIMY dimensions, using characters in PEN-LIST, starting at complex coord XY, using TYPEFACE and a SAVEDMAP. All arguments are optional and keyword-based with defaults (except TYPEFACE which doesn't need one---excelsior is built into BLT---and SAVEDMAP). Navigate with vim keys, press space to draw, f to erase and a or s to change character. When done, press Escape to get a print-out of the map."
  (let* ((pen 0)
	 (pens (1- (length pen-list))))
    (macrolet ((cell (n) `(blt:cell-char (realpart ,n) (imagpart ,n))))
      (labels ((tick () (blt:print 0 0 (format nil "~a" pen-list))
		 (blt:print (1+ (* pen 2)) 1 "_")
		 (blt:refresh)
		 (blt:print (1+ (* pen 2)) 1 " ")
		 (setf (blt:layer) 1
		       (cell xy) #\SPACE
		       (blt:layer) 0)
		 (blt:key-case 
		  (blt:read) (:escape (setf xy 'quit))
		  (:a (if (< pen pens) (incf pen) (setf pen 0)))
		  (:s (setf pen (if (zerop pen) pens (1- pen))))
		  (:space (setf (cell xy) (nth pen pen-list)))
		  (:f (setf (cell xy) #\SPACE))
		  (:k (incf xy #C( 0 -1))) (:j (incf xy #C(0  1)))
		  (:h (incf xy #C(-1  0))) (:l (incf xy #C(1  0)))
		  (:y (incf xy #C(-1 -1))) (:u (incf xy #C(1 -1)))
		  (:b (incf xy #C(-1  1))) (:n (incf xy #C(1  1))))
		 (cond ((eq xy 'quit)
			(loop for y to (1- dimy) do
			  (loop for x to (1- dimx) do
			    (format t "~A" (or (blt:cell-char x y)
					       #\SPACE)))
			  (terpri)))
		       (t (setf (blt:layer) 1)
			  (setf (cell xy) (nth pen pen-list)
				(blt:layer) 0)
			  (tick)))))
	(blt:with-terminal 
	  (when typeface (blt:set "font: ~A, size=10" typeface))
	  (blt:set "window.size = ~AX~A" dimx dimy)
	  (setf (blt:color) (blt:rgba 120 160 120))
	  (if savedmap
	      (let* ((lines (uiop:read-file-lines savedmap))
		     (numlines (length lines))
		     (maxlength 0))
		(dotimes (line numlines 
			       (progn (setf dimx maxlength
					    dimy numlines)
				      (tick)))
		  (loop for pos to (1- (length (nth line lines))) do
		    (setf (cell (complex pos line))
			  (char (nth line lines) pos))
		    finally (when (> pos maxlength) 
			      (setf maxlength pos)))))
	      (dotimes (x dimx (tick))
		(dotimes (y dimy)
		  (setf (cell (complex x y)) #\SPACE)))))))))
