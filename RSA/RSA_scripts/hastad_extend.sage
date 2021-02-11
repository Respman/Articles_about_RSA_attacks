#! /usr/bin/env sage

from sage import *

#Допустим, все абоненты используюь линейный паддинг по схеме, описанной выше - 
#мы сдвигаем номер абонента на 11 бит влево, потому что число 1337 в двоичной записи имеет 11 бит 
#(можно было выбрать и другой паддинг, например, 16 бит). 

def main():
	e = [3, 3, 3, 3, 5]
	Ci = [114869701, 205171474, 200625208, 455642610, 898906124]
	Ni = [1074200609, 1074921787, 1075774397, 1076955293, 1078202887]
	N = 1 #общий модуль
	for n in Ni:
		N *= n
	
	R0.<x> = PolynomialRing(Zmod(N), implementation='NTL')
	tmp_g = R0(0)
	e_max = max(e)

	for i in range(5): 
		ostatki = [0,0,0,0,0]
		ostatki[i] = 1
		Ti = CRT(ostatki, Ni)
		#print(GCD(Ti, N))
		#составляем многочлен g_i(x)
		R1.<y> = PolynomialRing(Zmod(Ni[i]), implementation='NTL')
		tmp_gi = R1((y+((i+1)<<11))**e[i]-Ci[i])
		#составляем многочлен h_i(x)
		hi_coef = []
		for i in range(e_max-e[i]):
			hi_coef.append(randint(1,Ni[i]))
		hi_coef.append(1)
		hi = R1(hi_coef)
		tmp_gi *= hi
		#теперь нам нужно составить многочлен из таких же коэффициентов, но над полем R0
		tmp_gi = tmp_gi.list()
		gi = R0(0)
		for j in range(len(tmp_gi)): 
			gi += ((Integer)(tmp_gi[j]))*(x**j)
		#формируем из них многочлен g(x)
		tmp_g += Ti*(gi)
	
	g = R0(0)
	tmp_g = tmp_g.list()
	for i in range(len(tmp_g)):
		g += (tmp_g[i]%N)*(x**i)
	print("начинаем расчет маленьких корней")
	print("M: "+str(g.small_roots(epsilon=0.02)[0])) 

if __name__ == "__main__":
	main()