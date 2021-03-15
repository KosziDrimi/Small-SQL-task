/* 1. Jakie są średnie dochodów w grupach wiekowych (21-30, 31-40, 41-50, 51+)? */ 

SELECT SUM(i.income_value)/COUNT(DISTINCT c.id) AS income_avg,
CASE WHEN c.age >= 21 AND c.age <= 30 THEN '21-30'
WHEN c.age >= 31 AND c.age <= 40 THEN '31-40'
WHEN c.age >= 41 AND c.age <= 50 THEN '41-50'
ELSE '51+' END AS age_category
FROM CUSTOMER AS c
JOIN CUSTOMER_INCOME AS i
ON c.id = i.parent_id
GROUP BY 2;


/* 2. Jaka jest suma dochodów z dodatkowych źródeł dochodów (is_main=False) dla każdego z klientów? */ 

SELECT c.id, SUM(i.income_value)
FROM CUSTOMER AS c
JOIN CUSTOMER_INCOME AS i
ON c.id = i.parent_id
WHERE i.is_main = False
GROUP BY 1;


/* 3. Jakie są średnie dochody poszczególnych gospodarstw domowych przypadających na pojedynczego członka gospodarstwa? 
Za członka gospodarstwa domowego uznaje się każdego przypisanego klienta (tabela CUSTOMER) oraz dzieci. */

WITH t1 AS (
	SELECT h.id, SUM(i.income_value) AS total
	FROM HOUSEHOLD AS h
	JOIN CUSTOMER AS c
	ON h.id = c.parent_id
	JOIN CUSTOMER_INCOME AS i
	ON c.id = i.parent_id
	GROUP BY 1),
     t2 AS (
	SELECT h.id, COUNT(c.id) + h.number_of_children AS numbers
	FROM HOUSEHOLD AS h
	JOIN CUSTOMER AS c
	ON h.id = c.parent_id
	GROUP BY 1)
SELECT t1.id, t1.total/t2.numbers AS income_per_person
FROM t1
JOIN t2
ON t1.id = t2.id;


/* 4. Jaka jest różnica pomiędzy maksymalnymi oraz minimalnymi dochodami osiąganymi przez klientów w poszczególnych 
gospodarstwach domowych? */

WITH t1 AS (
	SELECT c.id, SUM(i.income_value) AS income_sum
	FROM CUSTOMER AS c
	JOIN CUSTOMER_INCOME AS i
	ON c.id = i.parent_id
	GROUP BY 1)
SELECT h.id, MAX(t1.income_sum) - MIN(t1.income_sum) AS income_diff
FROM t1
JOIN CUSTOMER AS c
ON c.id = t1.id
JOIN HOUSEHOLD AS h
ON h.id = c.parent_id
GROUP BY 1;
