-- 1. Funkcja zwraca nazwę pracy (JOB_TITLE) dla podanego JOB_ID
CREATE OR REPLACE FUNCTION get_job_name(p_job_id IN jobs.job_id%TYPE)
RETURN VARCHAR2 AS
    v_title jobs.job_title%TYPE;
BEGIN
SELECT job_title INTO v_title
FROM jobs
WHERE job_id = p_job_id;

RETURN v_title;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20010, 'Taka praca nie istnieje!');
END;
/


-- 2. Funkcja zwraca roczne zarobki
-- salary*12 + salary*commission_pct
CREATE OR REPLACE FUNCTION get_year_salary(p_id IN employees.employee_id%TYPE)
RETURN NUMBER AS
    v_salary employees.salary%TYPE;
    v_comm employees.commission_pct%TYPE;
BEGIN
SELECT salary, NVL(commission_pct, 0)
INTO v_salary, v_comm
FROM employees
WHERE employee_id = p_id;

RETURN v_salary * 12 + v_salary * v_comm;
END;
/


-- 3. Funkcja wyciąga numer kierunkowy z telefonu (pierwsze cyfry w nawiasie)
-- np. "(22)123-456" → 22
CREATE OR REPLACE FUNCTION get_prefix(p_phone VARCHAR2)
RETURN VARCHAR2 AS
    v_prefix VARCHAR2(20);
BEGIN
    v_prefix := REGEXP_SUBSTR(p_phone, '\(([^)]*)\)', 1, 1, NULL, 1);
RETURN v_prefix;
END;
/


-- 4. Funkcja zmienia pierwszą i ostatnią literę na wielką, resztę na małe
CREATE OR REPLACE FUNCTION normalize_text(p_txt VARCHAR2)
RETURN VARCHAR2 AS
    v_txt VARCHAR2(4000);
BEGIN
    IF p_txt IS NULL THEN RETURN NULL; END IF;

    p_txt := LOWER(p_txt);
RETURN UPPER(SUBSTR(p_txt, 1, 1)) ||
       SUBSTR(p_txt, 2, LENGTH(p_txt) - 2) ||
       UPPER(SUBSTR(p_txt, -1, 1));
END;
/


-- 5. Funkcja przetwarza PESEL → data urodzenia YYYY-MM-DD
CREATE OR REPLACE FUNCTION pesel_to_date(p_pesel VARCHAR2)
RETURN DATE AS
    year_part NUMBER;
    month_part NUMBER;
    day_part NUMBER;
BEGIN
    year_part := SUBSTR(p_pesel, 1, 2);
    month_part := SUBSTR(p_pesel, 3, 2);
    day_part := SUBSTR(p_pesel, 5, 2);

    IF month_part > 80 THEN
        year_part := 1800 + year_part;
        month_part := month_part - 80;
    ELSIF month_part > 60 THEN
        year_part := 2200 + year_part;
        month_part := month_part - 60;
    ELSIF month_part > 40 THEN
        year_part := 2100 + year_part;
        month_part := month_part - 40;
    ELSIF month_part > 20 THEN
        year_part := 2000 + year_part;
        month_part := month_part - 20;
ELSE
        year_part := 1900 + year_part;
END IF;

RETURN TO_DATE(year_part || '-' || month_part || '-' || day_part, 'YYYY-MM-DD');
END;
/


-- 6. Funkcja zwracająca liczbę pracowników i departamentów w kraju
CREATE OR REPLACE FUNCTION country_stats(p_country VARCHAR2)
RETURN VARCHAR2 AS
    v_cnt NUMBER;
    v_depts NUMBER;
BEGIN
SELECT COUNT(*)
INTO v_cnt
FROM employees e
         JOIN departments d ON d.department_id = e.department_id
         JOIN locations l ON l.location_id = d.location_id
         JOIN countries c ON c.country_id = l.country_id
WHERE LOWER(c.country_name) = LOWER(p_country);

SELECT COUNT(DISTINCT d.department_id)
INTO v_depts
FROM departments d
         JOIN locations l ON l.location_id = d.location_id
         JOIN countries c ON c.country_id = l.country_id
WHERE LOWER(c.country_name) = LOWER(p_country);

RETURN 'Pracownicy: ' || v_cnt || ', Departamenty: ' || v_depts;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20011, 'Nie znaleziono kraju!');
END;
/

-- WYZWALACZE


-- 1. Tabela archiwum + wyzwalacz na DELETE z departments
BEGIN
EXECUTE IMMEDIATE '
CREATE TABLE archiwum_departamentow (
                                        id NUMBER,
                                        nazwa VARCHAR2(100),
                                        data_zamkniecia DATE,
                                        ostatni_manager VARCHAR2(100)
)';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE OR REPLACE TRIGGER trg_depart_delete
AFTER DELETE ON departments
FOR EACH ROW
DECLARE
v_manager VARCHAR2(100);
BEGIN
SELECT first_name || '' '' || last_name
INTO v_manager
FROM employees
WHERE employee_id = :OLD.manager_id;

INSERT INTO archiwum_departamentow
VALUES (:OLD.department_id, :OLD.department_name, SYSDATE, v_manager);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        INSERT INTO archiwum_departamentow
        VALUES (:OLD.department_id, :OLD.department_name, SYSDATE, 'BRAK MANAGERA');
END;
/


-- 2. Wyzwalacz na employees dla INSERT/UPDATE — sprawdzenie widełek
BEGIN
EXECUTE IMMEDIATE '
CREATE TABLE zlodziej (
                          id NUMBER GENERATED ALWAYS AS IDENTITY,
                          user_name VARCHAR2(100),
                          czas_zmiany DATE
)';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE OR REPLACE TRIGGER trg_salary_check
BEFORE INSERT OR UPDATE ON employees
                            FOR EACH ROW
BEGIN
    IF :NEW.salary NOT BETWEEN 2000 AND 26000 THEN
        INSERT INTO zlodziej(user_name, czas_zmiany)
        VALUES (USER, SYSDATE);

        RAISE_APPLICATION_ERROR(-20012, 'Wynagrodzenie poza widełkami!');
END IF;
END;
/


-- 3. Sekwencja + trigger auto_increment dla employees
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE emp_ai_seq START WITH 5000';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE OR REPLACE TRIGGER trg_emp_ai
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF :NEW.employee_id IS NULL THEN
        :NEW.employee_id := emp_ai_seq.NEXTVAL;
END IF;
END;
/


-- 4. Wyzwalacz blokujący operacje na job_grades
CREATE OR REPLACE TRIGGER trg_block_jg
BEFORE INSERT OR UPDATE OR DELETE ON job_grades
BEGIN
    RAISE_APPLICATION_ERROR(-20013,'Operacje na JOB_GRADES są zabronione!');
END;
/


-- 5. Wyzwalacz niepozwalający zmienić min_salary/max_salary w JOBS
CREATE OR REPLACE TRIGGER trg_jobs_protect
BEFORE UPDATE ON jobs
                  FOR EACH ROW
BEGIN
    :NEW.min_salary := :OLD.min_salary;
    :NEW.max_salary := :OLD.max_salary;
END;
/

-- PAKIETY


-- 1. Pakiet łączący wszystkie funkcje i procedury
CREATE OR REPLACE PACKAGE my_tools AS
    FUNCTION get_job_name(p_job_id jobs.job_id%TYPE) RETURN VARCHAR2;
    FUNCTION get_year_salary(p_id employees.employee_id%TYPE) RETURN NUMBER;
    FUNCTION get_prefix(p_phone VARCHAR2) RETURN VARCHAR2;
    FUNCTION normalize_text(p_txt VARCHAR2) RETURN VARCHAR2;
    FUNCTION pesel_to_date(p_pesel VARCHAR2) RETURN DATE;
    FUNCTION country_stats(p_country VARCHAR2) RETURN VARCHAR2;
END my_tools;
/

CREATE OR REPLACE PACKAGE BODY my_tools AS
    FUNCTION get_job_name(p_job_id jobs.job_id%TYPE) RETURN VARCHAR2 IS
    v_title VARCHAR2(100);
BEGIN
SELECT job_title INTO v_title FROM jobs WHERE job_id = p_job_id;
RETURN v_title;
EXCEPTION WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20010, 'Taka praca nie istnieje!');
END;

    FUNCTION get_year_salary(p_id employees.employee_id%TYPE) RETURN NUMBER IS
        v_salary NUMBER; v_comm NUMBER;
BEGIN
SELECT salary, NVL(commission_pct,0)
INTO v_salary, v_comm
FROM employees WHERE employee_id = p_id;
RETURN v_salary*12 + v_salary*v_comm;
END;

    FUNCTION get_prefix(p_phone VARCHAR2) RETURN VARCHAR2 IS
BEGIN
RETURN REGEXP_SUBSTR(p_phone,'\(([^)]*)\)',1,1,NULL,1);
END;

    FUNCTION normalize_text(p_txt VARCHAR2) RETURN VARCHAR2 IS
BEGIN
        IF p_txt IS NULL THEN RETURN NULL; END IF;
        p_txt := LOWER(p_txt);
RETURN UPPER(SUBSTR(p_txt,1,1)) ||
       SUBSTR(p_txt,2,LENGTH(p_txt)-2) ||
       UPPER(SUBSTR(p_txt,-1,1));
END;

    FUNCTION pesel_to_date(p_pesel VARCHAR2) RETURN DATE IS
        year_part NUMBER; month_part NUMBER; day_part NUMBER;
BEGIN
        year_part := SUBSTR(p_pesel,1,2);
        month_part := SUBSTR(p_pesel,3,2);
        day_part := SUBSTR(p_pesel,5,2);

        IF month_part > 80 THEN
            year_part := 1800 + year_part; month_part := month_part - 80;
        ELSIF month_part > 60 THEN
            year_part := 2200 + year_part; month_part := month_part - 60;
        ELSIF month_part > 40 THEN
            year_part := 2100 + year_part; month_part := month_part - 40;
        ELSIF month_part > 20 THEN
            year_part := 2000 + year_part; month_part := month_part - 20;
ELSE
            year_part := 1900 + year_part;
END IF;

RETURN TO_DATE(year_part||'-'||month_part||'-'||day_part,'YYYY-MM-DD');
END;

    FUNCTION country_stats(p_country VARCHAR2) RETURN VARCHAR2 IS
        v_cnt NUMBER; v_depts NUMBER;
BEGIN
SELECT COUNT(*) INTO v_cnt
FROM employees e
         JOIN departments d ON d.department_id = e.department_id
         JOIN locations l ON l.location_id = d.location_id
         JOIN countries c ON c.country_id = l.country_id
WHERE LOWER(c.country_name) = LOWER(p_country);

SELECT COUNT(DISTINCT d.department_id) INTO v_depts
FROM departments d
         JOIN locations l ON l.location_id = d.location_id
         JOIN countries c ON c.country_id = l.country_id
WHERE LOWER(c.country_name) = LOWER(p_country);

RETURN 'Pracownicy: '||v_cnt||', Departamenty: '||v_depts;
END;
END my_tools;
/

-- 2. Pakiet CRUD dla REGIONS
CREATE OR REPLACE PACKAGE regions_pkg AS
    PROCEDURE add_region(p_id NUMBER, p_name VARCHAR2);
    PROCEDURE update_region(p_id NUMBER, p_new_name VARCHAR2);
    PROCEDURE delete_region(p_id NUMBER);
    FUNCTION get_region(p_id NUMBER) RETURN VARCHAR2;
    FUNCTION find_by_name(p_name VARCHAR2) RETURN NUMBER;
END regions_pkg;
/

CREATE OR REPLACE PACKAGE BODY regions_pkg AS
    PROCEDURE add_region(p_id NUMBER, p_name VARCHAR2) AS
BEGIN
INSERT INTO regions(region_id, region_name)
VALUES (p_id, p_name);
END;

    PROCEDURE update_region(p_id NUMBER, p_new_name VARCHAR2) AS
BEGIN
UPDATE regions SET region_name = p_new_name
WHERE region_id = p_id;
END;

    PROCEDURE delete_region(p_id NUMBER) AS
BEGIN
DELETE FROM regions WHERE region_id = p_id;
END;

    FUNCTION get_region(p_id NUMBER) RETURN VARCHAR2 AS
        v_name VARCHAR2(50);
BEGIN
SELECT region_name INTO v_name
FROM regions WHERE region_id = p_id;
RETURN v_name;
END;

    FUNCTION find_by_name(p_name VARCHAR2) RETURN NUMBER AS
        v_id NUMBER;
BEGIN
SELECT region_id INTO v_id
FROM regions
WHERE LOWER(region_name) = LOWER(p_name);
RETURN v_id;
END;
END regions_pkg;
/
