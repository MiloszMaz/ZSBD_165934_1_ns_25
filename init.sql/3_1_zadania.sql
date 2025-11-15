--- zadanie 1
CREATE OR REPLACE VIEW v_cw3_wysokie_pensje AS
SELECT * FROM employees
WHERE salary > 6000;

--- zadanie 2
CREATE OR REPLACE VIEW v_cw3_wysokie_pensje AS
SELECT * FROM employees
WHERE salary > 12000;

--- zadanie 3
DROP VIEW v_cw3_wysokie_pensje;

--- zadanie 4
CREATE OR REPLACE VIEW v_cw3_finance_pracownicy AS
SELECT e.employee_id,
       e.last_name,
       e.first_name
FROM employees e
         JOIN departments d ON e.department_id = d.department_id
WHERE d.department_name = 'Finance';

--- zadanie 5
CREATE OR REPLACE VIEW v_cw3_pracownicy_5000_12000 AS
SELECT * FROM employees
WHERE salary BETWEEN 5000 AND 12000;

--- zadanie 6
INSERT INTO v_cw3_pracownicy_5000_12000 (employee_id, last_name, first_name, salary, job_id, email, hire_date)
VALUES (999, 'Nowak', 'Adam', 8000, 'IT_PROG', 'adam.nowak@firma.pl', SYSDATE);

UPDATE v_cw3_pracownicy_5000_12000
SET salary = 9000
WHERE employee_id = 999;

DELETE FROM v_cw3_pracownicy_5000_12000
WHERE employee_id = 999;

--- zadanie 7
CREATE OR REPLACE VIEW v_cw3_statystyki_dzialow AS
SELECT d.department_id,
       d.department_name,
       COUNT(e.employee_id) AS liczba_pracownikow,
       ROUND(AVG(e.salary), 2) AS srednia_pensja,
       MAX(e.salary) AS najwyzsza_pensja
FROM departments d
         JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(e.employee_id) >= 4;

--- zadanie 8
CREATE OR REPLACE VIEW v_cw3_pracownicy_5000_12000_chk AS
SELECT employee_id,
       last_name,
       first_name,
       salary,
       job_id,
       email,
       hire_date
FROM employees
WHERE salary BETWEEN 5000 AND 12000
    WITH CHECK OPTION CONSTRAINT v_cw3_pracownicy_chk;

-- działa
INSERT INTO v_cw3_pracownicy_5000_12000_chk (employee_id, last_name, first_name, salary, job_id, email, hire_date)
VALUES (1002, 'Kowalski', 'Jan', 8000, 'IT_PROG', 'jan.kowalski@firma.pl', SYSDATE);

-- odrzucone przez CHECK OPTION
--- INSERT INTO v_cw3_pracownicy_5000_12000_chk (employee_id, last_name, first_name, salary, job_id, email, hire_date)
--- VALUES (1002, 'Nowak', 'Anna', 15000, 'IT_PROG', 'anna.nowak@firma.pl', SYSDATE);

--- zadanie 9
CREATE MATERIALIZED VIEW v_cw3_managerowie
BUILD IMMEDIATE
REFRESH ON DEMAND
AS
SELECT e.employee_id,
       e.first_name,
       e.last_name,
       e.job_id,
       d.department_name
FROM employees e
         JOIN departments d ON e.department_id = d.department_id
WHERE e.employee_id IN (SELECT DISTINCT manager_id FROM employees WHERE manager_id IS NOT NULL);

--- zadanie 10
CREATE OR REPLACE VIEW v_cw3_najlepiej_oplacani AS
SELECT employee_id,
       first_name,
       last_name,
       salary,
       job_id
FROM (
         SELECT employee_id,
                first_name,
                last_name,
                salary,
                job_id,
                RANK() OVER (ORDER BY salary DESC) AS ranking
         FROM employees
     )
WHERE ranking <= 10;