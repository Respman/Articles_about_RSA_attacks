#! /usr/bin/env sage

from sage import *

debug = True

def boneh_durfee(pol, modulus, mm, tt, XX, YY):
	# мы применяем подстановку, которую предложили Хэрманн и Мэй (Herrman and May), 
	#чтобы сделать замену переменных u = xy + 1 и таким образом линеаризовать систему.
	PR.<u, x, y> = PolynomialRing(ZZ)
	Q = PR.quotient(x*y + 1 - u) # u = xy + 1
	polZ = Q(pol).lift()
	UU = XX*YY + 1

	# собираем x-сдвиги
	gg = []
	for kk in range(mm + 1):
		for ii in range(mm - kk + 1):
			xshift = x^ii * modulus^(mm - kk) * polZ(u, x, y)^kk
			gg.append(xshift)
	gg.sort()
	# превращяем список x-сдвигов в список мономов 
	monomials = []
	for polynomial in gg:
		for monomial in polynomial.monomials():
			if monomial not in monomials:
				monomials.append(monomial)
	monomials.sort()
	# собираем y-сдвиги
	for jj in range(1, tt + 1):
		for kk in range(floor(mm/tt) * jj, mm + 1):
			yshift = y^jj * polZ(u, x, y)^kk * modulus^(mm - kk)
			yshift = Q(yshift).lift()
			gg.append(yshift) # подстановка
	# список мономов для y-сдвигов 
	for jj in range(1, tt + 1):
		for kk in range(floor(mm/tt) * jj, mm + 1):
			monomials.append(u^kk * y^jj)

	# собираем матрицу B
	nn = len(monomials)
	BB = Matrix(ZZ, nn)
	for ii in range(nn):
		BB[ii, 0] = gg[ii](0, 0, 0)
		for jj in range(1, ii + 1):
			if monomials[jj] in gg[ii].monomials():
				BB[ii, jj] = gg[ii].monomial_coefficient(monomials[jj]) * monomials[jj](UU,XX,YY)
	# проверяем границы определителя матрицы B на корректность
	det = BB.det()
	bound = modulus^(mm*nn)
	if det >= bound:
		print ("Ваш определитель больше допустимой границы. Решение может быть не найдено.")
		print ("Попробуйте увеличить m и t.")
		if debug:
			diff = (log(det) - log(bound)) / log(2)
			print ("Размер det(L) - size e^(m*n) = ", floor(diff))
		if strict:
			return -1, -1
	else:
		print("det(L) < e^(m*n) (Отлично! Если решение <N^delta существует, то оно будет найдено)")

	# LLL-алгоритм
	if debug:
		print ("сокращаем базис с помощью LLL-алгоритма, это может занять какое-то время")
	BB = BB.LLL()
	if debug:
		print ("LLL-алгоритм завершил работу!")

	# превратим векторы i и j в полиномы 1 и 2
	if debug:
		print ("Поиск независимых векторов в базисе решетки")
	found_polynomials = False
	for pol1_idx in range(nn - 1):
		for pol2_idx in range(pol1_idx + 1, nn):
			# для i и j, создадим два многочлена
			PR.<w,z> = PolynomialRing(ZZ)
			pol1 = pol2 = 0
			for jj in range(nn):
				pol1 += monomials[jj](w*z+1,w,z) * BB[pol1_idx, jj] / monomials[jj](UU,XX,YY)
				pol2 += monomials[jj](w*z+1,w,z) * BB[pol2_idx, jj] / monomials[jj](UU,XX,YY)

			# результат
			PR.<q> = PolynomialRing(ZZ)
			rr = pol1.resultant(pol2)
			# эти полиномы нам подходят?
			if rr.is_zero() or rr.monomials() == [1]:
				continue
			else:
				print ("находим их, используя векторы ", pol1_idx, " и ", pol2_idx)
				found_polynomials = True
				break
		if found_polynomials:
			break
	if not found_polynomials:
		print ("Независимых векторов не найдено - это случается очень редко...")
		return 0, 0
	rr = rr(q, q)

	# корни
	soly = rr.roots()
	if len(soly) == 0:
		print ("Ваща граница (delta) слишком маленькая")
		return 0, 0
	soly = soly[0][0]
	ss = pol1(q, soly)
	solx = ss.roots()[0][0]
	return solx, soly

def main():
	N = int('c2fd2913bae61f845ac94e4ee1bb10d8531dda830d31bb221dac5f179a8f883f15046'+
		'd7aa179aff848db2734b8f88cc73d09f35c445c74ee35b01a96eb7b0a6ad9cb9ccd6c'+
		'02c3f8c55ecabb55501bb2c318a38cac2db69d510e152756054aaed064ac2a454e46d'+
		'9b3b755b67b46906fbff8dd9aeca6755909333f5f81bf74db', 16)
	e = int('19441f679c9609f2484eb9b2658d7138252b847b2ed8ad182be7976ed57a3e441af14'+
		'897ce041f3e07916445b88181c22f510150584eee4b0f776a5a487a4472a99f2ddc95efdd'+
		'2b380ab4480533808b8c92e63ace57fb42bac8315fa487d03bec86d854314bc2ec4f99b19'+
		'2bb98710be151599d60f224114f6b33f47e357517', 16)
	# гипотетический порядок экспоненты (теоретический максимум 0.292)
	delta = .18 # это означает, что d < N^delta
	m = 4 # размер базиса матрицы B (больше - значит лучше, но медленнее)
	t = int((1-2*delta) * m)  # оптимизация, которую ввели Herrmann и May
	X = 2*floor(N^delta)  
	Y = floor(N^(1/2))	
	# Собираем уравнениие
	P.<x,y> = PolynomialRing(ZZ)
	A = int((N+1)/2)
	pol = 1 + x * (A + y)
	# проверка границ
	if debug:
		print ("=== проверка величин ===")
		print ("* delta: ", delta)
		print ("* delta < 0.292 ", delta < 0.292)
		print ("* размер e (в битах): ", int(log(e)/log(2)))
		print ("* размер N (в битах): ", int(log(N)/log(2)))
		print ("* m: ", m, ", t: ", t)
	# boneh_durfee
	if debug:
		print ("=== запуск алгоритма ===")
	solx, soly = boneh_durfee(pol, e, m, t, X, Y)
	# Решение найдено?
	if solx > 0:
		print ("=== решение найдено ===")
		if False:
			print ("x: ", solx)
			print ("y: ", soly)
		d = int(pol(solx, soly) / e)
		print ("найдена закрытая экспонента d: ", d)
	else:
		print ("=== решение не было найдено ===")

if __name__ == "__main__":
	main()