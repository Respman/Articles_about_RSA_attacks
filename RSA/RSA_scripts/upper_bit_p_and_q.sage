#! /usr/bin/env sage

from sage import *

def main():
	
	# функция, которая делает из строки многочлен
	def rows2poly(mat,row, monom):
		return sum(mat[row][i]*monom[i]/monom[i].subs(x=X,y=Y) for i in range(mat.dimensions()[1]))

	length_N = 1024
	q = next_prime(randint(2**(round(length_N/2)), (2**(round(length_N/2)+1)-1)))
	p = next_prime(randint(2**(round(length_N/2)), (2**(round(length_N/2)+1)-1)))
	#и для определённости
	if p < q:
		p, q = q, p
	N = p*q
	hidden = 157
	#hidden = floor(length_N/7)-1	
	p0 = p & ((2^length_N-1)-(2^hidden-1))
	q0 = q & ((2^length_N-1)-(2^hidden-1))
	print("N: ",N)
	print("\np:  ",bin(p))
	print("p0: ",bin(p0))
	print("\nq:  ",bin(q))
	print("q0: ",bin(q0))
	P.<x,y> = PolynomialRing(QQ)
	f = (p0+x)*(q0+y)
	X = 2^hidden
	Y = 2^hidden
	S = [(0,0,0), (1,0,0), (0,1,0), (0,0,1)]
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
	x0 = p & (2^hidden-1)
	y0 = q & (2^hidden-1)
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
	root=H1.roots()
	for r in root:
		if (r[0] < 2**hidden) and (r[0] > 0):
			my_y = r[0]
	print("ожидаем y0:  ",y0)
	print("получили y0: ",my_y)
	print("\nожидаем x0:  ",x0)
	print("получили x0: ", (N/(my_y+q0)-p0))

if __name__ == "__main__":
	main()
