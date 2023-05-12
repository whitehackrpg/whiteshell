# whiteshell
A repository for a shell with [Whitehack RPG](https://whitehackrpg.wordpress.com/) tools.

Clone the repository and softlink it in your quicklisp/local-projects directory. Then:

```
(ql:quickload :whiteshell)
(in-package :whiteshell)
```

Now you can use the functions in the REPL:

https://github.com/whitehackrpg/whiteshell/assets/130791778/6c9208e2-7df9-430f-a4e2-369d53103685


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
In this case it will give you something like:

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
