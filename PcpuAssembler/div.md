A and B and the result are divided in half:

A = |AAAA|FFFF| = |dividend|0xFF (all 1's)|
B = |BB00|0080| = |divisor, aligned left|1 << log2(B)|
Res = |00RR|FFqq| = |reminder|NOT(quotient)|

for B, the single 1 is always N/2 zeroes left of the divisor itself
