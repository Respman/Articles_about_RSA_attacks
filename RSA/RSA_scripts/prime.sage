#! /usr/bin/env sage

from sage import *

def main():
	p = next_prime(2**100)
	print("p: "+str(p))
	print(p.is_prime())
	print((p+1).is_prime())

if __name__ == "__main__":
	main()

