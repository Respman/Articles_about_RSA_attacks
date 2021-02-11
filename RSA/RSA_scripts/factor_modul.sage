#! /usr/bin/env sage

from sage import *
import random

def main():
	n = 391
	d = 13
	e = 325
	r = (e * d - 1)
	s = 0
	while True:
		quotient, remainder = divmod(r, 2)
		if remainder != 0:
			break
		s += 1
		r = quotient

	found = False
	while not found:
		i = 1
		a = random.randint(1,n-1)
		while i <= s and not found:
			F = Zmod(n)
			c1 = sage.arith.power.generic_power(F(a), sage.arith.power.generic_power(F(2), i-1) * r)
			c2 = sage.arith.power.generic_power(F(a), sage.arith.power.generic_power(F(2), i) * r)
			found = (c1 != 1) and (c1 != (-1 % n)) and (c2 == 1)
			i += 1

	p = GCD(c1-1, n)
	p = int(p)
	q = n/p
	print(f"p: {p}")
	print(f"q: {q}")

if __name__ == "__main__":
	main()
