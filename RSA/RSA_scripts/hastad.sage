#! /usr/bin/env sage

from sage import *

def main():
	e = 3 #значения даны для примера
	C = [23494, 30084, 704]
	N = [32771, 32779, 32783]
	Me = CRT(C,N)
	M = Me**(1/e)
	print("M: "+str(M))

if __name__ == "__main__":
	main()
