;;;; Whiteshell damage and crit roller

(in-package #:whiteshell)

(defun consequences (value type)
  (let* ((d6 (nd6 1))
	 (d10 (1+ (random 10)))
	 (d3 (ceiling (nd6 1) 2)))
    (flet ((results (value type &optional (factor 1) spec)
	     (format nil "~a ~a d6: ~a d10: ~a d3: ~a Effect: ~a"
		     value type (* d6 factor) (* d10 factor) 
		     (* d3 factor) spec)))
      (case type
	(success (results value type))
	(crit (results value type 2 (crit d6 d10)))
	(fumble (format nil "~a ~a ~a" value type (fumble d6)))))))

(defun crit (d6 d10)
  (let ((caused6 (when (<= d6 2) (format nil "d6(~a) " d6)))
	(caused10 (when (<= d10 2) (format nil "d10(~a) " d10))))
  (when (or caused6 caused10)
    (format nil "~a~a~a" (or caused6 "") (or caused10 "") (write-to-string (1+ (random 20)))))))

(defun fumble (a)
  a)
