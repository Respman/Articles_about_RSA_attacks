#! /usr/bin/env sage

from sage import *

def main():
	# RSA генерация
	length_N = 512
	p = next_prime(randint(2**(round(length_N/2)), (2**(round(length_N/2)+1)-1)))
	q = next_prime(randint(2**(round(length_N/2)), (2**(round(length_N/2)+1)-1)))
	N = p*q
	hidden = 32
	qbar = q & ((2**length_N-1)-(2**hidden-1))
	print("двоичное представление числа q:         ",bin(q))
	print("двоичное представление известных бит q: ",bin(qbar))
	F.<x> = PolynomialRing(Zmod(N), implementation='NTL')
	pol = qbar + x
	# Применим к этому алгоритму метод Копперсмита:
	# Нужно выбрать epsilon <= beta/7
	# если алгоритм не находит решений, то можно попробовать уменьшить параметр epsilon 
	# (при этом увеличится время работы алгоритма)
	# Также хочется уточнить верхнюю границу с (N**((beta**2/(pol.degree())) - epsilon)) 
	# до (2^hidden-1) - это поможет ускорить рассчеты
	print("#Начало работы метода Копперсмита:")
	roots = pol.small_roots(X=2^hidden-1, beta=0.5, epsilon = 0.01)
	# выход алгоритма
	if (len(roots) > 0):
		print ("\n# Решение")
		print ("мы хотим увидеть:", q - qbar)
		print ("мы нашли:        ", roots[0])
	else:
		print("\n# Решений не найдено")

if __name__ == "__main__":
	main()

