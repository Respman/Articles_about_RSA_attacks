#! /usr/bin/env sage

import copy
from sage import *

def PKCS_oracle(c,N):
	d = 13337	
	m = (ZZ(c)**d)%N
	hex_m = hex(m)[2:]
	return (hex_m[0] == "2")and(len(hex_m)==13)

def search_si(m0, e, si, N):
	print (f"[-] начинаем поиск значения s(i-1) (начиная с величины {si})")
	i2a = 1		  # счетчик итераций
	Z = Zmod(N)
	while True:
		tmp_si = Integer((Z(si)**e)%N)
		m1 = (tmp_si * m0) % N
		if PKCS_oracle(m1, N):   # вызываем оракул на паддинг
			break	# паддинг правильный, мы нашли подходящее si
		i2a += 1
		si += 1	  # пробуем следующее значение для si
	print (f"[*] поиск выполнен за {i2a} итераций")
	print (f"	si: {si}")
	return si

def narrowing_interval(si, a, b, N):
	B = 2**(48)
	print("сужение интервала: [",hex(a),", ",hex(b),"]")
	newM = []  # собираем новые интервалы в этот массив
	#перебираем все подходящие значения для r
	for r in range((ceil((a*si - 3*B + 1)/N)),
				   (floor((b*si - 2*B)/N) + 1)):
		#рассчитываем границы aa и bb для нового интервала m0, опираясь на текущее r
		aa = ceil((2*B + r*N)/si)
		bb = floor((3*B - 1 + r*N)/si)
		#пересекаем найденный интервал  с интервалом [a,b]
		newa = max(a,aa)		                       
		newb = min(b,bb)		                     
		if newa <= newb:		                        
			newM.append((newa, newb))
		print (f"значение r:   {r}")
		print("получаем интервал: [",hex(newa),", ",hex(newb),"]")
		return newM

def binary_search(m0, si, e, a, b, N):
	print("итерация 'бинарного' поиска")
	B = 2**(48)
	r = ceil(((b*si - 2*B)*2)/N) # начальное значение для r
	i2c,nr = 0,1	# для статистики
	found = False	
	Z = Zmod(N)
	while not found:
		for si in range(ceil((2*B + r * N)/b),(floor((3*B-1 + r * N)/a)+1)):
			tmp_si = Integer((Z(si)**e)%N)
			mi = (tmp_si * m0) % N
			i2c += 1
			if PKCS_oracle(mi, N):
				found = True
				break # мы нашли si
		if not found:
			r  += 1   # пытаемся попробовать следующее значение для r
			nr += 1
	print (f"[*] поиск заавершился за {i2c} итераций")
	print (f"	иследуеммое значение r:  {nr}")
	print (f"	s_i:		            {si}")
	aa = ceil((2*B + r*N)/si)
	bb = floor((3*B - 1 + r*N)/si)
	#пересекаем найденный интервал с интервалом [a,b]
	newa = max(a,aa)		                       
	newb = min(b,bb)		                     
	print("получаем интервал: [",hex(newa),", ",hex(newb),"]")
	if ((newb-newa)>0):
		result = binary_search(m0, si, e, newa, newb, N)
	else:
		result = newa
	return result

def main():
	#Оговорка - данная реализация является атакой Бляйхенбахера, но не на паддинг PKCS#1 v1.5,
	#а на кастомный паддинг, который очень на него похож:
	#разница будет заключаться в том, что паддинг не будет делать сообщение с длинной в битах,
	#равной длине модуля N. Здесь мы просто будем иметь первый байт '\x02', после чего мы 
	#добавим несколько случайных байт, потом нулевой байт '\x00',
	#после чего будет идти само сообщение.
	#При таком паддинге для составления границы B нам нужно будет знать длину изначального 
	#сообщения (так как теперь она не равна длине модуля), то, допустим, она нам известна.
	N = 1152921515344265237
	e = 497147156211643613
	m = 0x31337
	PKCS_padding = 0x0252d400000000 
	m = PKCS_padding + m
	print("PKCS-дополненое сообщение: ",hex(m))
	Z = Zmod(N)
	c = Integer(Z(m)**e)
	print("Зашифрованное сообщение: ", hex(c))
	#B = 2**(ceil(log(n,2))-16) 
	#так должна выглядеть граница B для паддинга PKCS#1 v1.5, 
	#но для нашего кастромного она будет следующей:
	#нам известна длина исходного сообщения вместе с паддингом - 13 байт, из которых 
	#один фиксирован; значит свободно изменяющихся байт у нас остается 2**(13*4-4)=2**(48)
	B = 2**(48)  
	s1 = ceil(N/(3*B)) # начальное значение s1
	si = search_si(c, e, s1, N)
	interval = copy.deepcopy(narrowing_interval(si, 2*B, 3*B-1, N))	

	while (len(interval) > 1):
		tmp_interval = []
		si = search_si(c, e, si+1, N)
		for interv in interval:
			(a, b) = interv
			for (d,e) in narrowing_interval(si, a, b, N):
				if (d,e) not in tmp_interval:
					tmp_interval.append((d,e))
		interval = copy.deepcopy(tmp_interval)
	
	(a,b) = interval[0]
	print("получаем  одиночный интервал: [", hex(a),", ", hex(b),"]")
	result = binary_search(c, si, e, a, b, N)
	print("Дешифрованное сообщение: ", hex(result)[2:])

if __name__ == '__main__':
	main()
