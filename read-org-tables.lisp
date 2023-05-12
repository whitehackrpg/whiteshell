;;;; read-org-tables 

(in-package #:whiteshell)

(defun strip-from-string (string &rest things)
  (do* ((thing (pop things) (pop things))
       (result (remove thing string :test #'equal) 
	       (remove thing result :test #'equal)))
      ((null things) result)
    ()))

(defun locate-entry (entry list)
  (find-if #'(lambda (n) (equalp entry (car n))) list))

(defun read-org-table (file)
  (mapcar #'(lambda (line) (remove-if #'(lambda (n) 
					  (equal n "")) 
				      (uiop:split-string 
				       (strip-from-string line #\|))))
	  (uiop:read-file-lines file)))

(defparameter *monstertable* (cddr (read-org-table (asdf:system-relative-pathname "whiteshell" "tables/monsters.org"))))



(defun monster (entry &optional (list *monstertable*))
  (let* ((themob (locate-entry (write-to-string entry) list))
	 (name (car themob)) (hd (handle-hd (cadr themob))) (df (caddr themob))
	 (mv (cadddr themob)) (lt (nth 4 themob)) 
	 (spec (format nil "~{~a~^ ~}" (nthcdr 5 themob))))
    (format nil "~A HD: ~A HP: ~A DF: ~A MV: ~A LT: ~A Special: ~A"  
	    name
	    hd
	    (hd-to-hp hd)
	    df
	    mv
	    lt
	    spec)))

(defun handle-hd (string)
  (if (and (>= (length string) 4) (string= (subseq string 1 2) "-"))
      (let ((firstnum (read-from-string (subseq string 0 1)))
	    (secnum (read-from-string (subseq string 3))))
	(format nil "~a" (+ firstnum (random (1+ (- secnum firstnum))))))
      string))

(defun hd-to-hp (string)
  (cond ((string= string "1*") "1")
	((<= (length string) 2) (nd6 (read-from-string string)))
	((string= (subseq string 1 2) "+")
	 (format nil "~a" (+ (nd6 (read-from-string (subseq string 0 1)))
			     (read-from-string (subseq string 2)))))))

		
