-- ZADANIE 1
DECLARE
numer_max departments.department_id%TYPE;
    nowy_numer departments.department_id%TYPE;
    nowa_nazwa departments.department_name%TYPE := 'EDUCATION';
BEGIN
SELECT MAX(department_id)
INTO numer_max
FROM departments;

DBMS_OUTPUT.PUT_LINE('Maksymalny numer departamentu: ' || numer_max);

    nowy_numer := numer_max + 10;

INSERT INTO departments(department_id, department_name)
VALUES (nowy_numer, nowa_nazwa);

DBMS_OUTPUT.PUT_LINE('Dodano departament nr ' || nowy_numer);
END;
/

-- ZADANIE 2
DECLARE
numer_max departments.department_id%TYPE;
    nowy_numer departments.department_id%TYPE;
    nowa_nazwa departments.department_name%TYPE := 'EDUCATION';
BEGIN
SELECT MAX(department_id)
INTO numer_max
FROM departments;

nowy_numer := numer_max + 10;

INSERT INTO departments(department_id, department_name, location_id)
VALUES (nowy_numer, nowa_nazwa, NULL);

UPDATE departments
SET location_id = 3000
WHERE department_id = nowy_numer;

DBMS_OUTPUT.PUT_LINE('Dodano departament ' || nowy_numer || ', ustawiono location_id = 3000');
END;
/

-- ZADANIE 3
BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE nowa (liczba VARCHAR2(10))';
EXCEPTION
    WHEN OTHERS THEN NULL; -- tabela może już istnieć
END;
/

BEGIN
FOR i IN 1..10 LOOP
        IF i NOT IN (4, 6) THEN
            INSERT INTO nowa VALUES (TO_CHAR(i));
END IF;
END LOOP;
END;
/

-- ZADANIE 4
DECLARE
kraj countries%ROWTYPE;
BEGIN
SELECT *
INTO kraj
FROM countries
WHERE country_id = 'CA';

DBMS_OUTPUT.PUT_LINE('Nazwa kraju: ' || kraj.country_name);
    DBMS_OUTPUT.PUT_LINE('Region_id: ' || kraj.region_id);
END;
/

-- ZADANIE 5
DECLARE
CURSOR c IS
SELECT last_name, salary
FROM employees
WHERE department_id = 50;

r c%ROWTYPE;
BEGIN
OPEN c;
LOOP
FETCH c INTO r;
        EXIT WHEN c%NOTFOUND;

        IF r.salary > 3100 THEN
            DBMS_OUTPUT.PUT_LINE(r.last_name || ' – nie dawać podwyżki');
ELSE
            DBMS_OUTPUT.PUT_LINE(r.last_name || ' – dać podwyżkę');
END IF;
END LOOP;
CLOSE c;
END;
/

-- ZADANIE 6
DECLARE
CURSOR c(z_min NUMBER, z_max NUMBER, imie_fragment VARCHAR2) IS
SELECT first_name, last_name, salary
FROM employees
WHERE salary BETWEEN z_min AND z_max
  AND LOWER(first_name) LIKE '%' || LOWER(imie_fragment) || '%';

r c%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- a) zakres 1000–5000, imie zawiera "a" ---');
OPEN c(1000, 5000, 'a');
LOOP
FETCH c INTO r;
        EXIT WHEN c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(r.first_name || ' ' || r.last_name || ', ' || r.salary);
END LOOP;
CLOSE c;

DBMS_OUTPUT.PUT_LINE('--- b) zakres 5000–20000, imie zawiera "u" ---');
OPEN c(5000, 20000, 'u');
LOOP
FETCH c INTO r;
        EXIT WHEN c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(r.first_name || ' ' || r.last_name || ', ' || r.salary);
END LOOP;
CLOSE c;
END;
/

-- ZADANIE 9a – procedura dodająca JOB
CREATE OR REPLACE PROCEDURE add_job(
    p_job_id    IN jobs.job_id%TYPE,
    p_job_title IN jobs.job_title%TYPE
) AS
BEGIN
INSERT INTO jobs(job_id, job_title)
VALUES (p_job_id, p_job_title);

DBMS_OUTPUT.PUT_LINE('Dodano job: ' || p_job_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd podczas dodawania: ' || SQLERRM);
END;
/

-- ZADANIE 9b – procedura modyfikująca JOB_TITLE z wyjątkiem
CREATE OR REPLACE PROCEDURE update_job_title(
    p_job_id    IN jobs.job_id%TYPE,
    p_new_title IN jobs.job_title%TYPE
) AS
BEGIN
UPDATE jobs
SET job_title = p_new_title
WHERE job_id = p_job_id;

IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'No Jobs updated');
END IF;

    DBMS_OUTPUT.PUT_LINE('Zmieniono job: ' || p_job_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd aktualizacji: ' || SQLERRM);
END;
/

-- ZADANIE 9c – procedura usuwająca job
CREATE OR REPLACE PROCEDURE delete_job(
    p_job_id IN jobs.job_id%TYPE
) AS
BEGIN
DELETE FROM jobs
WHERE job_id = p_job_id;

IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'No Jobs deleted');
END IF;

    DBMS_OUTPUT.PUT_LINE('Usunięto job: ' || p_job_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd usuwania: ' || SQLERRM);
END;
/

-- ZADANIE 9d – procedura zwracająca salary i last_name
CREATE OR REPLACE PROCEDURE get_employee_info(
    p_employee_id IN employees.employee_id%TYPE,
    p_salary      OUT employees.salary%TYPE,
    p_last_name   OUT employees.last_name%TYPE
) AS
BEGIN
SELECT salary, last_name
INTO p_salary, p_last_name
FROM employees
WHERE employee_id = p_employee_id;
END;
/

-- ZADANIE 9e – procedura dodająca pracownika + walidacja salary
BEGIN
EXECUTE IMMEDIATE 'CREATE SEQUENCE emp_seq START WITH 3000';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

CREATE OR REPLACE PROCEDURE add_employee(
    p_first_name   IN employees.first_name%TYPE DEFAULT 'NEW',
    p_last_name    IN employees.last_name%TYPE,
    p_email        IN employees.email%TYPE,
    p_job_id       IN employees.job_id%TYPE,
    p_salary       IN employees.salary%TYPE,
    p_dept_id      IN employees.department_id%TYPE DEFAULT NULL
) AS
BEGIN
    IF p_salary > 20000 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Salary too high!');
END IF;

INSERT INTO employees(
    employee_id, first_name, last_name, email,
    hire_date, job_id, salary, department_id
) VALUES (
             emp_seq.NEXTVAL, p_first_name, p_last_name, p_email,
             SYSDATE, p_job_id, p_salary, p_dept_id
         );

DBMS_OUTPUT.PUT_LINE('Dodano pracownika.');
END;
/

COMMIT;
