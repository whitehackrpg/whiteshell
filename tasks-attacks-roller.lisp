;;;; Whiteshell tasks and attacks roller

(in-package #:whiteshell)

(defun attack (score defense &rest mods)
  "Roll a d20 against SCORE and DEFENSE with any number of MODS, returning quality and result category."
  (let* ((d20 (1+ (random 20)))
	 (surplus (if (> score 20) (- score 20) 0))
	 (target (reduce #'+ (cons score mods))))
    (cond ((<= (+ d20 surplus) defense)
	   (values (+ d20 surplus) 'plink))
	   ((= d20 20)
	   (values 20.0 (if (zerop surplus) 'fumble 'failure)))
	  ((and (= d20 19) (not (zerop surplus)))
	   (values (+ d20 surplus) 'crit))
	  ((< d20 target)
	   (values (+ d20 surplus) 'success))
	  ((> d20 target)
	   (values d20 'failure))
	  (t (values d20 'crit)))))

(defun quantified (result)
  "Take a RESULT category and return a quantification."
  (case result
    (fumble 0)
    (failure 1)
    (plink 2)
    (success 3)
    (crit 4)))

(defun compare-rolls (kind q1 r1 q2 r2)
  "Compare two pairs of quality and result category, returning the pair that 'wins,' based on the KIND of comparison (positive or negative)."
  (let ((comparison (- (quantified r1) 
		       (quantified r2))))
    (cond ((minusp comparison)
	   (if (eq kind 'positive)
	       (values q2 r2)
	       (values q1 r1)))
	  ((zerop comparison)
	   (if (eq kind 'positive)
	       (if (> q1 q2)
		   (values q1 r1)
		   (values q2 r2))
	       (if (< q1 q2)
		   (values q1 r1)
		   (values q2 r2))))
	  (t (if (eq kind 'positive) 
		 (values q1 r1)
		 (values q2 r2))))))
	   
(defun double-attack (kind score defense &rest mods)
  "Make a double roll attack using SCORE, DEFENSE and any number of MODS. Although it isn't in the rules, you can use this to make a negative double attack as well."
  (multiple-value-bind (q1 r1) 
      (apply #'attack score defense mods)
    (multiple-value-bind (q2 r2) 
	(apply #'attack score defense mods)
      (compare-rolls kind q1 r1 q2 r2))))

(defun at (score defense &rest mods)
  "Shortcut for an attack."
  (apply #'attack score defense mods))

(defun dat (score defense &rest mods)
  "Shortcut for a double attack."
  (apply #'double-attack 'positive score defense mods))

(defun tr (score &rest mods)
  "Shortcut for a regular taskroll."
  (apply #'attack score 0 mods))

(defun +dtr (score &rest mods)
  "Shortcut for a positive double taskroll."
  (apply #'double-attack 'positive score 0 mods))

(defun -dtr (score &rest mods)
  "Shortcut for a negative double taskroll."
  (apply #'double-attack 'negative score 0 mods))


