(defun random-item (input &optional pretty)
  (let* ((thelist (if (listp input) input (uiop:read-file-lines input)))
	 (pick (nth (random (length thelist)) thelist)))
    (if pretty (format t "~a" pick) pick)))
    
