#! /usr/bin/env sage

from sage import *

def main():
	e = 1779399043
	N = 2796304957
	frac = continued_fraction(e/N)
	convergents = [(fr*fr.denominator(), fr.denominator()) for fr in frac.convergents()]

	for (k,d) in convergents:
		#подходит ли нам данная экспонента d?
		if ((k!=0) and ((e*d-1)%k == 0)):
			phi = (e*d-1)//k
			s = N - phi + 1
			# проверка, имеет ли уравнение x^2 - s*x + n = 0
			# целочисленные корни
			R.<x> = PolynomialRing(ZZ)
			root = R(x^2-s*x+N).roots()
			if (len(root)==2):
				if ((root[0][0]**root[0][1])*(root[1][0]**root[1][1])==N):
					print("d: "+str(d))
					return 0

if __name__ == "__main__":
   main() 