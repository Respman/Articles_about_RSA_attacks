#! /usr/bin/env sage

from sage import *

def fault_signature(m):
	d = 1337
	p = 1048583
	q = 1048589
	s1 = (m**d)%p
	s2 = (m**d)%q-1
	s = CRT([s1,s2],[p,q])
	return s

def main():
	N = 1099532599387
	e = 461358722321
	m = 31337
	Z = Zmod(N)
	c = Z(fault_signature(m))
	p = ZZ(GCD((c**e-m),N))
	print(f"p: {p}")
	q = N//p
	print(f"q: {q}")

if __name__ == '__main__':
	main()