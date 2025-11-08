INSERT INTO jobs (job_title, min_salary, max_salary)
VALUES ('PHP Developer', 4000, 9000);

INSERT INTO jobs (job_title, min_salary, max_salary)
VALUES ('IT Project Manager', 3000, 8000);

INSERT INTO jobs (job_title, min_salary, max_salary)
VALUES ('QA Tester', 2500, 6000);

INSERT INTO jobs (job_title, min_salary, max_salary)
VALUES ('Talent Hunter', 5000, 10000);

-- Wstawienie danych do EMPLOYEES
INSERT INTO employees (first_name, last_name, job_id, manager_id, salary)
VALUES ('Jan', 'Kowalski', 4, NULL, 9500);

INSERT INTO employees (first_name, last_name, job_id, manager_id, salary)
VALUES ('Anna', 'Nowak', 1, NULL, 6000);

INSERT INTO employees (first_name, last_name, job_id, manager_id, salary)
VALUES ('Piotr', 'Wiśniewski', 2, NULL, 5000);

INSERT INTO employees (first_name, last_name, job_id, manager_id, salary)
VALUES ('Maria', 'Zielińska', 3, 1, 4000);

UPDATE employees
SET manager_id = 1
WHERE employee_id IN (2, 3);

UPDATE jobs
SET min_salary = min_salary + 500,
    max_salary = max_salary + 500
WHERE LOWER(job_title) LIKE '%b%'
   OR LOWER(job_title) LIKE '%s%';

COMMIT;