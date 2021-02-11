#! /usr/bin/env sage

from sage import *

def main():
	# функция, которая делает из строки многочлен
	def rows2poly(mat,row, monom):
		return sum(mat[row][i]*monom[i]/monom[i].subs(x=X,y=Y) for i in range(mat.dimensions()[1]))

	length_N = 4096
	q = next_prime(randint(2**(round(length_N/2)), (2**(round(length_N/2)+1)-1)))
	p = next_prime(randint(2**(round(length_N/2)), (2**(round(length_N/2)+1)-1)))
	N = p*q
	e = 7
	# зашифруем фразу "login: 252bkbk password: 1keklol"
	# "login: 252bkbk password: 1keklol"
	M = 0x6c6f67696e3a20323532626b626b2070617373776f72643a20316b656b6c6f6c
	# "login: ....... password: ......."
	A = 0x6c6f67696e3a20000000000000002070617373776f72643a2000000000000000
	B = 0x0000000000000000000000000001000000000000000000000000000000000000
	x0 = 0x323532626b626b # "252bkbk"
	y0 = 0x316b656b6c6f6c # "1keklol"
	C = M^e%N
	print("N: ",N)
	print("e: ",e)
	P.<x,y> = PolynomialRing(QQ)
	f = (A + B*x + y)^e-C
	hidden = 56
	X = 2^hidden
	Y = 2^hidden
	S = [(0,0,1)]
	for i in range(8):
		for j in range(3):
			if ((i+j) <= 7) and ((i,j,0) not in S):
				S.append((i,j,0))
	for i in range(4):
		for j in range(8):
			if ((i+j) <= 7) and ((i,j,0) not in S):
				S.append((i,j,0))
	print("S: ",len(S))
	g = []
	mon = []
	for (i,j,k) in S:
		gi = (x*X)^i*(y*Y)^j*(f(x*X,y*Y)/N)^k
		g.append(gi)
		for m in gi.monomials():
			if m not in mon:
				mon.append(m)
	coef = [[0 for j in range(len(mon))] for i in range(len(g))]
	for i in range(len(g)):
		g_coef = [(j,k) for (j,k) in zip(g[i].monomials(),g[i].coefficients())]
		for (m,c) in g_coef:
			coef[i][mon.index(m)] = c
	L = matrix(QQ,coef)
	print("начало работы LLL-алгоритма")
	Lred = L.LLL()	
	print("конец работы LLL-алгоритма")
	# создадим список многочленов из строк редуцированной матрицы
	h=[]
	for i in range(len(g)):
		h.append(rows2poly(Lred,i, mon))
	# рассчитаем корни, которые, по идее, должна найти наша программа (обычно мы их не знаем)
	print ('подставим в множество редуцированных многочленов корни (x0,y0):')
	for i in range(len(g)):	
		print ('для многочлена с номером', i+1 , ':',  h[i](x0,y0))
	# мы ищем среди новых многочленов два алгебраически независимых
	print ("Поиск независимых векторов в базисе решетки")
	found_polynomials = False
	for pol1_idx in range(len(h)):
		for pol2_idx in range(pol1_idx + 1, len(h)):
			H = h[pol1_idx].resultant(h[pol2_idx])
			# эти полиномы нам подходят?
			if H.is_zero() or H.monomials() == [1]:
				continue
			else:
				print ("находим их, используя векторы ", pol1_idx, " и ", pol2_idx)
				found_polynomials = True
				break
		if found_polynomials:
			break
	print ('\nСтепень получившегося многочлена', H.degree())
	K.<y>=QQ[]
	H1=K(H)
	my_y=H1.roots()[0][0]
	H = h[pol1_idx](x,my_y)
	K.<x>=QQ[]
	H1=K(H)
	my_x=H1.roots()[0][0]
	print("ожидаем y0:  ",hex(y0))
	print("получили y0: ",hex(my_y))
	print("\nожидаем x0:  ",hex(x0))
	print("получили x0: ", hex(my_x))

if __name__ == "__main__":
	main()
