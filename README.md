# whiteshell
A repository for a shell with Whitehack tools.

Use the tools directly in a REPL, or make a simple script to use via bash. For example:

1. Install sbcl somewhere (default /usr/local).
2. Put the tool file where you want it (like in your $HOME).
3. Make a bash-script like below:

```
#!/usr/local/bin/sbcl --script

(setf *random-state* (make-random-state t))
(load "/home/your-user/simple-maps.lisp")
(print-map)
```

Then make the script executable and run it:

```
chmod +x yourscript.lisp
./yourscript.lisp
```
