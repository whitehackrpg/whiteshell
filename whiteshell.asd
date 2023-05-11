;;;; whiteshell.asd

(asdf:defsystem #:whiteshell
  :description "A collection of helper tools for the tabletop role-playing game Whitehack."
  :author "Christian Mehrstam <whitehackrpg@gmail.com>"
  :license  "MIT for the actual code. Standard copyright all rights reserved for any Whitehack content."
  :serial t
  :depends-on (#:cl-blt)
  :components ((:file "package")
	       (:file "tasks-attacks-roller")
	       (:file "simple-maps")
	       (:file "whiteshell")
	       (:file "hp-roller")
	       (:file "read-org-tables")
	       (:file "damage-roller")))

