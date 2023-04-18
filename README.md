# whiteshell
A repository for a shell with [Whitehack RPG] (https://whitehackrpg.wordpress.com/) tools.

* Clone the repository and softlink it in your quicklisp/local-projects directory. 
* Do the same with Steve Losh's CL-BLT (https://docs.stevelosh.com/cl-blt/). 
* Install BearLibTerminal on your computer (https://github.com/tommyettinger/BearLibTerminal). 

Then:

```
(ql:quickload :whiteshell)
(in-package :whiteshell)
```

Now you can use the functions in the REPL:



https://user-images.githubusercontent.com/130791778/232888799-ddee4e4a-3497-476b-865c-492487404f72.mp4



Alternatively, make a simple script to use via bash from the command line. For example:

1. Install sbcl somewhere (default /usr/local).
2. Put a tool file where you want it (like in your $HOME).
3. Make a bash-script like the below example:

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
Which will give you something like:

```
                                           ########                             
                                           #......#                  #######    
                                           #......##############     #.....#    
        ######      ########################...................#######.....#    
        #....#      #......................................................#    
        #....########.########################################.#########.###    
        #................................#         ###########.#####   #.#      
        #....########.##########.....#...#         #......##.......#   #.#      
        ###.##      #.......#  #.....#...#         #......##.......#####.####   
          #.#       #.......####.........######    #........................### 
######    #.#       #.........................#    #......##.......####.......# 
#....#    #.#    ####.......######.......####.#########.####.......####.......# 
#....######.######......#.....................................................# 
#............................#########..........#####...######.#.######.......# 
###.............................................#   #...######.#.#    ######### 
  ################......#############################............#              
                 #......................................###......#              
                 #......#############################............#              
                 #......#                           #######......#              
                 ########                                 ########   
```
