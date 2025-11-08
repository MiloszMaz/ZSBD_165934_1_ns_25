CREATE TABLE employees AS SELECT * FROM hr.employees;
CREATE TABLE departments AS SELECT * FROM hr.departments;
CREATE TABLE jobs AS SELECT * FROM hr.jobs;
CREATE TABLE locations AS SELECT * FROM hr.locations;
CREATE TABLE countries AS SELECT * FROM hr.countries;
CREATE TABLE regions AS SELECT * FROM hr.regions;
CREATE TABLE job_history AS SELECT * FROM hr.job_history;

ALTER TABLE employees ADD CONSTRAINT pk_employees PRIMARY KEY (employee_id);
ALTER TABLE departments ADD CONSTRAINT pk_departments PRIMARY KEY (department_id);
ALTER TABLE jobs ADD CONSTRAINT pk_jobs PRIMARY KEY (job_id);
ALTER TABLE locations ADD CONSTRAINT pk_locations PRIMARY KEY (location_id);
ALTER TABLE countries ADD CONSTRAINT pk_countries PRIMARY KEY (country_id);
ALTER TABLE regions ADD CONSTRAINT pk_regions PRIMARY KEY (region_id);

ALTER TABLE employees ADD CONSTRAINT fk_dept FOREIGN KEY (department_id) REFERENCES departments(department_id);
ALTER TABLE employees ADD CONSTRAINT fk_job FOREIGN KEY (job_id) REFERENCES jobs(job_id);
ALTER TABLE employees ADD CONSTRAINT fk_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id);
ALTER TABLE departments ADD CONSTRAINT fk_loc FOREIGN KEY (location_id) REFERENCES locations(location_id);
ALTER TABLE locations ADD CONSTRAINT fk_country FOREIGN KEY (country_id) REFERENCES countries(country_id);
ALTER TABLE countries ADD CONSTRAINT fk_region FOREIGN KEY (region_id) REFERENCES regions(region_id);
ALTER TABLE job_history ADD CONSTRAINT fk_emp FOREIGN KEY (employee_id) REFERENCES employees(employee_id);

COMMIT;