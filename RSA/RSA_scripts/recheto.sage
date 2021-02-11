#! /usr/bin/env sage

from sage import *

def main():
	p = ecm.factor(next_prime(2^40) * next_prime(2^300)) #метод общего решета числового поля
	print(p)
	p = factor(next_prime(2^40) * next_prime(2^300)) #метод решета
	print(p)

if __name__ == "__main__":
	main()

