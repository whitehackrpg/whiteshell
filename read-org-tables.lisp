;;;; read-org-tables 

(in-package #:whiteshell)


(defun read-org-table (file)
  (mapcar #'(lambda (line) (remove-if #'(lambda (n) 
					  (equal n "")) 
				      (uiop:split-string 
				       (strip-from-string line #\|))))
	  (uiop:read-file-lines file)))

(defun strip-from-string (string &rest things)
  (do* ((thing (pop things) (pop things))
       (result (remove thing string :test #'equal) 
	       (remove thing result :test #'equal)))
      ((null things) result)
    ()))

(defun locate-entry (entry list)
  (find-if #'(lambda (n) (equalp entry (car n))) list))

(defun monster (entry list &key average)
  (destructuring-bind (name hd df mv &optional lt spec)
      (locate-entry entry list)
    (format nil "~A HD: ~A HP: ~A DF: ~A MV: ~A LT: ~A Special: ~A"  
	    name
	    hd
	    (if average                                         
		(average (nd6 (parse-integer hd)))  ; average hp
		(nd6 (parse-integer hd)))           ; random hp
	    df
	    mv
	    lt
	    spec)))
