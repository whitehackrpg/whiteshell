(defparameter *surr* (list #C( 0 -1) #C(0  1) #C(-1  0) #C(1  0)
			   #C(-1 -1) #C(1 -1) #C(-1  1) #C(1  1))
  "Complex modifiers to get the coords around a coord.")

(defun within (a b c)
  "Is a within b and c?"
  (and (>= a b)
       (<= a c)))

(defun toward (x y)
  "Return next value going from x to y."
  (cond ((= x y) x)
	((< x y) (1+ x))
	(t (1- x))))

(defun mkmap (xdim ydim &aux (map (make-hash-table)))
  "Return a basic roguelike map in a hash-table."
  (dotimes (x xdim)
    (dotimes (y ydim)
      (setf (gethash (complex x y) map) #\#)))
  (genrooms xdim ydim map (complex (round xdim 2) (round ydim 2)) nil
	    (floor (* xdim ydim) 50)))

(defun leg (a end-a b map &optional v)
  "Make a leg in a corridor -- give a fifth arg for a vertical leg."
  (unless (= a end-a)
    (setf (gethash (complex (if v b a) (if v a b)) map) #\.)
    (leg (toward a end-a) end-a b map v)))

(defun make-corridor (nc lc map)
  "Make a corridor between two rooms."
  (destructuring-bind (nx lx ny ly) (list (realpart nc) (realpart lc)
					  (imagpart nc) (imagpart lc))
    (case (random 2)
      (0 (leg nx lx ny map) (leg ny ly lx map 'vert))
      (t (leg ny ly lx map 'vert) (leg nx lx ny map)))))

(defun o-o-bounds (xdim ydim cx cy width height)
  "Check if room is out of bounds."
  (dotimes (w width)
    (dotimes (h height)
      (unless (and (within (+ w cx) 1 (- xdim 2))
		   (within (+ h cy) 1 (- ydim 2)))
	(return-from o-o-bounds t)))))

(defun genrooms (xdim ydim map old-cent room-list count)
  "Generate the rooms of a level."
  (let* ((w (+ 3 (random 6))) ; width
	 (h (+ 3 (random 6))) ; height
	 (cx (random xdim))   ; corner-x
	 (cy (random ydim))   ; corner-y
	 (new-cent (complex (+ cx (round w 2)) (+ cy (round h 2)))))
    (cond ((zerop count) map)
	  ((and (not (o-o-bounds xdim ydim cx cy w h))
		(null (intersection (rcoords w h cx cy) room-list)))
	   (dotimes (x w)
	     (dotimes (y h)
	       (let ((tile-xy (complex (+ x cx) (+ y cy))))
		 (setf (gethash tile-xy map) #\.)
		 (push tile-xy room-list))))
	   (make-corridor new-cent old-cent map)
	   (genrooms xdim ydim map new-cent room-list (1- count)))
	  (t (genrooms xdim ydim map old-cent room-list (1- count))))))

(defun rcoords (width height corner-x corner-y &aux temp-room)
  "Generate a list of coordinates for a room."
  (dotimes (x width temp-room)
    (dotimes (y height)
      (let ((col (+ x corner-x))
	    (row (+ y corner-y)))
	(push (complex col row) temp-room)))))

(defun transform-char (x y map)
  "Only return the map character if it is near a floor tile."
  (let ((count 0))
    (loop for mod in *surr* do
      (when (eq (gethash (+ mod (complex x y)) map) #\.) (incf count)))
    (if (zerop count) #\SPACE (gethash (complex x y) map))))
    
    
(defun print-map (&optional (xdim 80) (ydim 20) (map (mkmap xdim ydim)))
  "Print a random map."
  (loop for y to (1- ydim) do
    (loop for x to (1- xdim) do
      (princ (transform-char x y map)))
    (terpri)))
