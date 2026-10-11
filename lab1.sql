CREATE TABLE regions (
    region_id    NUMBER(4) CONSTRAINT regions_pk PRIMARY KEY,
    region_name  VARCHAR2(25)
);

CREATE TABLE countries (
    country_id    NUMBER(4) CONSTRAINT countries_pk PRIMARY KEY,
    country_name  VARCHAR2(60)
);

CREATE TABLE locations (
    location_id     NUMBER(4) CONSTRAINT locations_pk PRIMARY KEY,
    street_address  VARCHAR2(40),
    postal_code     VARCHAR2(12),
    city            VARCHAR2(30) NOT NULL
);

CREATE TABLE jobs (
    job_id      NUMBER(4) CONSTRAINT jobs_pk PRIMARY KEY,
    job_title   VARCHAR2(35) NOT NULL,
    min_salary  NUMBER(6),
    max_salary  NUMBER(6),
    CONSTRAINT jobs_salary_range_ck CHECK (max_salary - min_salary >= 2000)
);

CREATE TABLE departments (
    department_id    NUMBER(4) CONSTRAINT departments_pk PRIMARY KEY,
    department_name  VARCHAR2(30) NOT NULL
);

CREATE TABLE employees (
    employee_id  NUMBER(6) CONSTRAINT employees_pk PRIMARY KEY,
    first_name   VARCHAR2(20),
    last_name    VARCHAR2(25) NOT NULL,
    email        VARCHAR2(25) NOT NULL,
    hire_date    DATE NOT NULL,
    job_id       NUMBER(4) NOT NULL,
    salary       NUMBER(8,2)
);

CREATE TABLE job_history (
    employee_id    NUMBER(6) NOT NULL,
    start_date     DATE NOT NULL,
    end_date       DATE NOT NULL,
    job_id         NUMBER(4) NOT NULL,
    CONSTRAINT job_history_pk PRIMARY KEY (employee_id, start_date),
    CONSTRAINT jhist_date_interval CHECK (end_date >= start_date)
);

ALTER TABLE countries ADD region_id NUMBER(4);
ALTER TABLE countries ADD CONSTRAINT countries_region_fk
    FOREIGN KEY (region_id) REFERENCES regions (region_id);

ALTER TABLE locations ADD state_province VARCHAR2(25);
ALTER TABLE locations ADD country_id NUMBER(4);
ALTER TABLE locations ADD CONSTRAINT loc_country_fk
    FOREIGN KEY (country_id) REFERENCES countries (country_id);

ALTER TABLE employees ADD phone_number VARCHAR2(20);
ALTER TABLE employees ADD commission_pct NUMBER(2,2);
ALTER TABLE employees ADD manager_id NUMBER(6);
ALTER TABLE employees ADD department_id NUMBER(4);

ALTER TABLE employees ADD CONSTRAINT emp_email_uk UNIQUE (email);
ALTER TABLE employees ADD CONSTRAINT emp_salary_min CHECK (salary > 0);
ALTER TABLE employees ADD CONSTRAINT emp_job_fk
    FOREIGN KEY (job_id) REFERENCES jobs (job_id);
ALTER TABLE employees ADD CONSTRAINT emp_manager_fk
    FOREIGN KEY (manager_id) REFERENCES employees (employee_id);
ALTER TABLE employees ADD CONSTRAINT emp_dept_fk
    FOREIGN KEY (department_id) REFERENCES departments (department_id);

ALTER TABLE departments ADD manager_id NUMBER(6);
ALTER TABLE departments ADD location_id NUMBER(4);
ALTER TABLE departments ADD CONSTRAINT dept_mgr_fk
    FOREIGN KEY (manager_id) REFERENCES employees (employee_id);
ALTER TABLE departments ADD CONSTRAINT dept_loc_fk
    FOREIGN KEY (location_id) REFERENCES locations (location_id);

ALTER TABLE job_history ADD department_id NUMBER(4);
ALTER TABLE job_history ADD CONSTRAINT jhist_emp_fk
    FOREIGN KEY (employee_id) REFERENCES employees (employee_id);
ALTER TABLE job_history ADD CONSTRAINT jhist_job_fk
    FOREIGN KEY (job_id) REFERENCES jobs (job_id);
ALTER TABLE job_history ADD CONSTRAINT jhist_dept_fk
    FOREIGN KEY (department_id) REFERENCES departments (department_id);

INSERT INTO jobs (job_id, job_title, min_salary, max_salary)
VALUES (1, 'Programmer',           4000,  8000);
INSERT INTO jobs (job_id, job_title, min_salary, max_salary)
VALUES (2, 'Stock',          2500,  5000);
INSERT INTO jobs (job_id, job_title, min_salary, max_salary)
VALUES (3, 'Accountant',    4200,  9000);
INSERT INTO jobs (job_id, job_title, min_salary, max_salary)
VALUES (4, 'Sales', 6000, 12000);

COMMIT;

INSERT INTO employees (employee_id, first_name, last_name, email, phone_number,
                       hire_date, job_id, salary, commission_pct, manager_id, department_id)
VALUES (1, 'user_1', 'first', 'user.first@email.com', '111111111',
        DATE '2020-01-15', 1, 7500, NULL, NULL, NULL);

INSERT INTO employees (employee_id, first_name, last_name, email, phone_number,
                       hire_date, job_id, salary, commission_pct, manager_id, department_id)
VALUES (4, 'user_4', 'fourth', 'user.fourth@email.com', '444444444',
        DATE '2019-09-20', 1, 6500, NULL, 1, NULL);

INSERT INTO employees (employee_id, first_name, last_name, email, phone_number,
                       hire_date, job_id, salary, commission_pct, manager_id, department_id)
VALUES (2, 'user_2', 'second', 'user.second@email.com', '222222222',
        DATE '2021-03-01', 2, 4000, NULL, 4, NULL);

INSERT INTO employees (employee_id, first_name, last_name, email, phone_number,
                       hire_date, job_id, salary, commission_pct, manager_id, department_id)
VALUES (3, 'user_3', 'third', 'user.third@email.com', '333333333',
        DATE '2021-06-10', 2, 3800, 0.10, 4, NULL);

COMMIT;

SELECT * FROM employees;

UPDATE employees
   SET manager_id = 1
 WHERE employee_id IN (2, 3);

COMMIT;

SELECT employee_id, last_name, manager_id FROM employees;

UPDATE jobs
   SET min_salary = min_salary + 500,
       max_salary = max_salary + 500
 WHERE LOWER(job_title) LIKE '%b%'
    OR LOWER(job_title) LIKE '%s%';

COMMIT;

SELECT * FROM jobs;


DELETE FROM jobs
 WHERE max_salary > 9000;

COMMIT;

SELECT * FROM jobs;

DROP TABLE job_history;

SELECT object_name, original_name, type, droptime
  FROM user_recyclebin;

FLASHBACK TABLE job_history TO BEFORE DROP;

SELECT * FROM job_history;
