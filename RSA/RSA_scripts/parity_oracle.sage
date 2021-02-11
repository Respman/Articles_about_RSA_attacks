#! /usr/bin/env sage

from sage import *

def parity_oracle(m, N):
	d = 1337
	return ((ZZ(m)**d)%N)%2 == 1

def main():
	N = 1099532599387
	e = 461358722321
	m = 31337
	Z = Zmod(N)
	c = Integer(Z(m)**e)
	enctwo = Integer(Z(2)**e) # шифрование двойки
# функция, отвечающая за "бинарный поиск"
	def partial(y,n):
		# вычисляем количество итераций для бинарного поиска
		k = ceil(log(n,2)) 
		l=0
		r=n
		for _ in range(k):	
			y=(y*enctwo) % n # умножаем y на зашифрованную двойку
			h = (l+r)/2
			if parity_oracle(y,n):
				l = h	# перенос произошел, значит меняем левую границу
			else:
				r = h	# перенос не произошел, меняем правую границу
		return int(r)	
	m1 = partial(c,N)
	print(f"M: {m1}")

if __name__ == '__main__':
	main()