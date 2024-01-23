# Tetris
Wrote function modules for the Tetris game in assembly given the c code in Tetris.c . 

Blocks are of different shapes, user can rotate, accelerate and horizontally translate blocks. The user must hit enter to enter the subsequent frame of the game. 

You can move a piece left (a) and right (d), drop it down (one step with s or all the way with S), and rotate it (r and R).

Any horizontal lines in the field that become completely filled will be cleared, and points will be awarded to the player's score based on how many lines are cleared at the same time.

example of the layout to expect when executing the assembly code using mipsy.


Welcome to 1521 tetris!

/= Field =\    SCORE: 0
|   IIII  |
|         |     NEXT: J
|         |
|         |
  -- CUT --
|         |
|         |
\=========/
  > S
A new piece has appeared: J

/= Field =\    SCORE: 0
|   J     |
|   JJJ   |     NEXT: L
|         |
|         |
  -- CUT --
|         |
|   IIII  |
\=========/
  > q
Quitting...

Goodbye!

