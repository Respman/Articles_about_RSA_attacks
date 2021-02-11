#! /usr/bin/env sage

from sage import *

def mod_n(c, n): #рассчет времени операции приведения по модулю
	# сдвиг на k бит влево, выполнение вычитания, проверка знака получившейся суммы
	k = len(bin(c)) - len(bin(n))
	timer = k+2 
	if ((c-(n<<k)) >= 0):
		timer += 1
	ost = c % n
	ost_bin = bin(ost)[2:]
	for i in range(k):
		#сдвиг влево на один бит, сложение, анализ знака, 
		#сдвиг на единицу целую часть и добавление к ней нолика или единицы
		timer += 4
	for i in ost_bin:
		if i == "1":
			timer += 1
	return ost, timer

def mul_n(a, b, n): #рассчет времени операции умножения по модулю
	a_bin = [i for i in bin(a)[2:]]
	a_bin.reverse()
	tmp = b
	c = 0
	timer = 1 + len(a_bin)
	for i in a_bin:
		timer += 1
		if (i == "1"):
			timer += 1
			c += tmp
			c, delta = mod_n(c, n)
			timer += delta
		tmp = tmp << 1
		timer += 1
	return c, timer

def smart_card_time(m, d, N):
	d_mas = [int(i) for i in bin(d)[2:]]
	d_mas.reverse()
	timer = 0
	z = m
	c = 1
	for i in d_mas:
		if (i==1):
			c, delta = mul_n(c, z, N)
			timer += delta
		z, delta = mul_n(z, z, N)
		timer += delta
	return timer


def main():
	d = 0b1101011
	N = 168345432
	amount = 10000
	#допустим, мы знаем количество знаков в закрытой экспоненте
	#- эту величину мы можем предполагать, если она не известна по условию задачи 
	len_d = len(bin(d))-2 
	print("настоящее d = ", bin(d))
	#создаем значения, которые мы будем использовать как открытые тексты для смарт-карты:
	m_i = [(137+i*floor((N-137)/amount)) for i in range(amount)]	
	T_i = []
	for i in range(amount):
		m = m_i[i]
		T_i.append(smart_card_time(m,d,N))
	
	my_d = 1 #изначально d_0=1
	print("сгенерируем t_1 для d = ", bin(my_d))
	t_i = []
	for i in range(amount):
		m = m_i[i]
		t_i.append(smart_card_time(m,my_d,N))
	
	var_t_last = variance([T_i[i]-t_i[i] for i in range(amount)])//(len_d-1)
	print("дисперсия t_1 равна: ", floor(var_t_last))
	for j in range(2, len_d):
		my_d += (1<<(j-1)) #как и в статье, начнем предполагать, 
						   #начиная со d_1=1 при d_0=1
		print(f"сгенерируем t_{j} для d = ", bin(my_d))
		t_i = []
		for i in range(amount):
			m = m_i[i]
			t_i.append(smart_card_time(m,my_d,N))
	
		var_t = variance([T_i[i]-t_i[i] for i in range(amount)])//(len_d-j)
		print(f"дисперсия t_{j} равна: ", floor(var_t))
		if var_t > var_t_last:
			my_d = my_d - (1<<(j-1))
			print("дисперсия увеличилась, производим перерасчет дисперсии")
			print(f"сгенерируем t_{j} для d = ", bin(my_d))
			t_i = []
			for i in range(amount):
				m = m_i[i]
				t_i.append(smart_card_time(m,my_d,N))
			var_t = variance([T_i[i]-t_i[i] for i in range(amount)])//(len_d-j)
			print(f"дисперсия t_{j} равна: ", floor(var_t))
		var_t_last = var_t
	#вычисление самого верхнего бита экспоненты
	if smart_card_time(m_i[-1],(my_d+(1<<(len_d-1))),N) == smart_card_time(m_i[-1],d,N): 
		print ("конечный результат вычисленного d: ", bin(my_d+(1<<(len_d-1))))
	else:
		print ("конечный результат вычисленного d: ", bin(my_d))

if __name__ == '__main__':
	main()
