(defun random-item (input &optional pretty)
  "Pick a random item either from a file with a list or an actual List list."
  (let* ((thelist (if (listp input) input (uiop:read-file-lines input)))
	 (pick (nth (random (length thelist)) thelist)))
    (if pretty (format t "~a" pick) pick)))
    
