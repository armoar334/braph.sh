# braph.sh
A shell script to draw graphs in terminal using unicode braille characters

# Usage
Set ``declare_y()`` to your liking, then run.  
``export -f declare_y``  
``./braph.sh``  
you can also optionally specify a number from 0 to 7 for the color of your line.  
as it does not clear the screen itself it can be used to draw multiple functions overlaid.

# Why
funny (and becasue i wanted to see if i could)  

# It runs really slowly
yeah, i can be bothered to write a way for it do calculations in hex properly, so it just string manipulates a binary number ATM. its not good but its functional enough as a POC  
