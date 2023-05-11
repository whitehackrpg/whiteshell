;;;; Whiteshell damage and crit roller

(in-package #:whiteshell)

(defparameter *crittable* (asdf:system-relative-pathname "whiteshell" "tables/crits.org"))

(defparameter *fumbletable* (asdf:system-relative-pathname "whiteshell" "tables/fumble.org"))

(defun consequences (value type)
  (let* ((d6 (nd6 1))
	 (d10 (1+ (random 10)))
	 (d3 (ceiling (nd6 1) 2)))
    (flet ((results (value type &optional (factor 1))
	     (format nil "~a ~a d6: ~a d10: ~a d3: ~a"
		     value type (* d6 factor) (* d10 factor) 
		     (* d3 factor))))
      (case type
	(success (results value type))
	(crit (format nil "~a~%~a" (results value type 2) (crit d6 d10)))
	(fumble (format nil "~a ~a~%~a" value type 
			(crit-fumble-effects d6 *fumbletable*)))))))

(defun crit-fumble-effects (n table)
  (format nil "~{~a~^ ~}" (locate-entry (write-to-string n)
					(read-org-table table))))

(defun crit (d6 d10)
  (let ((caused6 (when (<= d6 2) 
		   (format nil "Table roll due to: d6(~a) ~%" d6)))
	(caused10 (when (<= d10 2) 
		    (format nil "Table roll due to: d10(~a) ~%" d10))))
  (when (or caused6 caused10)
    (format nil "~a~a~a" (or caused6 "") (or caused10 "")
	    (crit-fumble-effects (1+ (random 20))  *crittable*)))))

