-- zadanie 1
CREATE OR REPLACE VIEW v1_wynagrodzenie AS
SELECT last_name AS nazwisko,
       salary AS wynagrodzenie
FROM employees
WHERE department_id IN (20, 50)
  AND salary BETWEEN 2000 AND 7000
ORDER BY last_name;

-- zadanie 2
SELECT hire_date,
       last_name,
       salary
FROM employees e
WHERE manager_id IS NOT NULL
  AND EXTRACT(YEAR FROM hire_date) = 2005
ORDER BY salary;

-- zadanie 3
SELECT first_name || ' ' || last_name AS imie_nazwisko,
       salary,
       phone_number
FROM employees
WHERE SUBSTR(last_name, 3, 1) = 'e'
  AND LOWER(first_name) LIKE '%&czesc_imienia%'
ORDER BY 1 DESC, 2 ASC;

-- zadanie 4
SELECT first_name,
       last_name,
       ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) AS liczba_miesiecy,
       CASE
           WHEN MONTHS_BETWEEN(SYSDATE, hire_date) < 150 THEN salary * 0.10
           WHEN MONTHS_BETWEEN(SYSDATE, hire_date) BETWEEN 150 AND 200 THEN salary * 0.20
           ELSE salary * 0.30
           END AS wysokosc_dodatku
FROM employees
ORDER BY liczba_miesiecy;

-- zadanie 5
SELECT department_id,
       SUM(salary) AS suma_zarobkow,
       ROUND(AVG(salary)) AS srednia_zarobkow
FROM employees
GROUP BY department_id
HAVING MIN(salary) > 5000;

-- zadanie 6
SELECT e.last_name,
       e.department_id,
       d.department_name,
       e.job_id
FROM employees e
         JOIN departments d ON e.department_id = d.department_id
         JOIN locations l ON d.location_id = l.location_id
WHERE l.city = 'Toronto';

-- zadanie 7
SELECT j.first_name || ' ' || j.last_name AS jennifer,
       e.first_name || ' ' || e.last_name AS wspolpracownik
FROM employees e
         JOIN employees j ON e.department_id = j.department_id
WHERE j.first_name = 'Jennifer'
  AND e.employee_id <> j.employee_id;

-- zadanie 8
SELECT department_name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1 FROM employees e WHERE e.department_id = d.department_id
);

-- zadanie 9
-- zadanie 9 (wersja bez job_grades)
SELECT e.first_name,
       e.last_name,
       e.job_id,
       d.department_name,
       e.salary,
       CASE
           WHEN e.salary < 3000 THEN 'A'
           WHEN e.salary BETWEEN 3000 AND 7000 THEN 'B'
           WHEN e.salary BETWEEN 7001 AND 10000 THEN 'C'
           WHEN e.salary BETWEEN 10001 AND 15000 THEN 'D'
           ELSE 'E'
           END AS grade_level
FROM employees e
         JOIN departments d ON e.department_id = d.department_id;


-- zadanie 10
SELECT first_name,
       last_name,
       salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

-- zadanie 11
SELECT DISTINCT e.employee_id,
                e.first_name,
                e.last_name
FROM employees e
WHERE e.department_id IN (
    SELECT DISTINCT department_id
    FROM employees
    WHERE last_name LIKE '%u%'
);

-- zadanie 12
SELECT first_name,
       last_name,
       hire_date
FROM employees
WHERE MONTHS_BETWEEN(SYSDATE, hire_date) >
      (SELECT AVG(MONTHS_BETWEEN(SYSDATE, hire_date)) FROM employees);

-- zadanie 13
SELECT d.department_name,
       COUNT(e.employee_id) AS liczba_pracownikow,
       ROUND(AVG(e.salary), 2) AS srednia_pensja
FROM departments d
         LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY liczba_pracownikow DESC;

-- zadanie 14
SELECT first_name,
       last_name,
       salary
FROM employees
WHERE salary < ALL (
    SELECT salary
    FROM employees e
             JOIN departments d ON e.department_id = d.department_id
    WHERE d.department_name = 'IT'
);

-- zadanie 15
SELECT DISTINCT d.department_name
FROM departments d
         JOIN employees e ON d.department_id = e.department_id
WHERE e.salary > (SELECT AVG(salary) FROM employees);

-- zadanie 16
SELECT *
FROM (
         SELECT job_id,
                ROUND(AVG(salary), 2) AS srednie_zarobki
         FROM employees
         GROUP BY job_id
         ORDER BY srednie_zarobki DESC
     )
WHERE ROWNUM <= 5;

-- zadanie 17
SELECT r.region_name,
       COUNT(DISTINCT c.country_id) AS liczba_krajow,
       COUNT(e.employee_id) AS liczba_pracownikow
FROM regions r
         JOIN countries c ON r.region_id = c.region_id
         JOIN locations l ON c.country_id = l.country_id
         JOIN departments d ON l.location_id = d.location_id
         JOIN employees e ON d.department_id = e.department_id
GROUP BY r.region_name;

-- zadanie 18
SELECT e.first_name,
       e.last_name,
       e.salary,
       m.first_name || ' ' || m.last_name AS manager_name,
       m.salary AS manager_salary
FROM employees e
         JOIN employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;

-- zadanie 19
SELECT TO_CHAR(hire_date, 'Month') AS miesiac,
       COUNT(*) AS liczba_pracownikow
FROM employees
GROUP BY TO_CHAR(hire_date, 'Month')
ORDER BY COUNT(*) DESC;

-- zadanie 20
SELECT *
FROM (
         SELECT d.department_name,
                ROUND(AVG(e.salary), 2) AS srednia_pensja
         FROM departments d
                  JOIN employees e ON d.department_id = e.department_id
         GROUP BY d.department_name
         ORDER BY srednia_pensja DESC
     )
WHERE ROWNUM <= 3;

COMMIT;