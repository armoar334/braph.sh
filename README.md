# braph.sh
A shell script to draw graphs in terminal using unicode braille characters

# Usage
Set ``braph_equation()`` to your liking, incrementing using the $tick variable, then run.  
``export -f braph_equation``  
``./braph.sh``  
you can also optionally specify a number from 0 to 7 for the color of your line.  
example ``braph_equation`` (run if none detected in env):
```
braph_equation() {
	x=$tick
	y=$tick
}
```

# Why
funny (and becasue i wanted to see if i could)  

# It runs really slowly
Yea i mean its bash so
