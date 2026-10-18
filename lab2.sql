-- 1
BEGIN
    FOR t IN (SELECT table_name FROM user_tables) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE "' || t.table_name || '" CASCADE CONSTRAINTS PURGE';
    END LOOP;
END;
/

-- 2
CREATE TABLE regions AS SELECT * FROM hr.regions;
CREATE TABLE countries AS SELECT * FROM hr.countries;
CREATE TABLE locations AS SELECT * FROM hr.locations;
CREATE TABLE departments AS SELECT * FROM hr.departments;
CREATE TABLE jobs AS SELECT * FROM hr.jobs;
CREATE TABLE employees AS SELECT * FROM hr.employees;
CREATE TABLE job_history AS SELECT * FROM hr.job_history;
CREATE TABLE job_grades AS SELECT * FROM hr.job_grades;
CREATE TABLE sales AS SELECT * FROM hr.sales;
CREATE TABLE products AS SELECT * FROM hr.products;

-- 2
ALTER TABLE regions ADD (
    CONSTRAINT regions_pk PRIMARY KEY (region_id)
);

ALTER TABLE countries ADD (
    CONSTRAINT countries_pk PRIMARY KEY (country_id),
    CONSTRAINT countries_region_fk FOREIGN KEY (region_id) REFERENCES regions (region_id)
);

ALTER TABLE locations ADD (
    CONSTRAINT locations_pk PRIMARY KEY (location_id),
    CONSTRAINT loc_country_fk FOREIGN KEY (country_id) REFERENCES countries (country_id)
);

ALTER TABLE jobs ADD (
    CONSTRAINT jobs_pk PRIMARY KEY (job_id)
);

ALTER TABLE departments ADD (
    CONSTRAINT departments_pk PRIMARY KEY (department_id),
    CONSTRAINT dept_loc_fk FOREIGN KEY (location_id) REFERENCES locations (location_id)
);

ALTER TABLE employees ADD (
    CONSTRAINT employees_pk PRIMARY KEY (employee_id),
    CONSTRAINT emp_job_fk FOREIGN KEY (job_id) REFERENCES jobs (job_id),
    CONSTRAINT emp_manager_fk FOREIGN KEY (manager_id) REFERENCES employees (employee_id),
    CONSTRAINT emp_dept_fk FOREIGN KEY (department_id) REFERENCES departments (department_id)
);

ALTER TABLE departments ADD (
    CONSTRAINT dept_mgr_fk FOREIGN KEY (manager_id) REFERENCES employees (employee_id)
);

ALTER TABLE job_history ADD (
    CONSTRAINT job_history_pk PRIMARY KEY (employee_id, start_date),
    CONSTRAINT jhist_emp_fk FOREIGN KEY (employee_id) REFERENCES employees (employee_id),
    CONSTRAINT jhist_job_fk FOREIGN KEY (job_id) REFERENCES jobs (job_id),
    CONSTRAINT jhist_dept_fk FOREIGN KEY (department_id) REFERENCES departments (department_id)
);

ALTER TABLE job_grades ADD (
    CONSTRAINT job_grades_pk PRIMARY KEY (grade)
);

ALTER TABLE products ADD (
    CONSTRAINT products_pk PRIMARY KEY (product_id)
);

ALTER TABLE sales ADD (
    CONSTRAINT sales_pk PRIMARY KEY (sale_id),
    CONSTRAINT sales_emp_fk FOREIGN KEY (employee_id) REFERENCES employees (employee_id),
    CONSTRAINT sales_prod_fk FOREIGN KEY (product_id) REFERENCES products (product_id)
);

-- 3

-- 1
CREATE OR REPLACE VIEW v_1 AS
SELECT last_name || ' ' || salary AS wynagrodzenie
FROM employees
WHERE department_id IN (20, 50)
  AND salary BETWEEN 2000 AND 7000
ORDER BY last_name;

SELECT * FROM v_1;

-- 2
SELECT hire_date, last_name, salary
FROM employees
WHERE manager_id IS NOT NULL
  AND EXTRACT(YEAR FROM hire_date) = 2005
ORDER BY salary;

-- 3
SELECT first_name || ' ' || last_name AS imie_nazwisko,
       salary,
       phone_number
FROM employees
WHERE LOWER(SUBSTR(last_name, 3, 1)) = 'e'
  AND LOWER(first_name) LIKE '%' || LOWER('a') || '%'
ORDER BY 1 DESC, 2;

-- 4
CREATE OR REPLACE VIEW v_4 AS
SELECT first_name || ' ' || last_name AS imie_nazwisko,
       liczba_miesiecy,
       CASE
           WHEN liczba_miesiecy < 150 THEN salary * 0.10
           WHEN liczba_miesiecy < 200 THEN salary * 0.20
           ELSE salary * 0.30
       END AS wysokosc_dodatku
FROM (
    SELECT first_name, last_name, salary,
           ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) AS liczba_miesiecy
    FROM employees
)
ORDER BY liczba_miesiecy;

SELECT * FROM v_4;

-- 5
CREATE OR REPLACE VIEW v_5 AS
SELECT department_id,
       SUM(salary) AS suma_zarobkow,
       ROUND(AVG(salary)) AS srednia_zarobkow
FROM employees
WHERE department_id IS NOT NULL
GROUP BY department_id
HAVING MIN(salary) > 5000;

SELECT * FROM v_5;

-- 6
CREATE OR REPLACE VIEW v_6 AS
SELECT e.last_name, e.department_id, d.department_name, e.job_id
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id
WHERE l.city = 'Toronto';

SELECT * FROM v_6;

-- 7
CREATE OR REPLACE VIEW v_7 AS
SELECT j.first_name || ' ' || j.last_name AS pracownik,
       c.first_name || ' ' || c.last_name AS wspolpracownik
FROM employees j
JOIN employees c ON j.department_id = c.department_id
                AND j.employee_id <> c.employee_id
WHERE j.first_name = 'Jennifer';

SELECT * FROM v_7;

-- 8
CREATE OR REPLACE VIEW v_8 AS
SELECT d.department_id, d.department_name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
);

SELECT * FROM v_8;

-- 9
CREATE OR REPLACE VIEW v_9 AS
SELECT e.first_name, e.last_name, e.job_id, d.department_name, e.salary, g.grade
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
JOIN job_grades g ON e.salary BETWEEN g.min_salary AND g.max_salary;

SELECT * FROM v_9;

-- 10
CREATE OR REPLACE VIEW v_10 AS
SELECT first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

SELECT * FROM v_10;

-- 11
CREATE OR REPLACE VIEW v_11 AS
SELECT employee_id, first_name, last_name
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM employees
    WHERE LOWER(last_name) LIKE '%u%'
);

SELECT * FROM v_11;

-- 12
CREATE OR REPLACE VIEW v_12 AS
SELECT employee_id, first_name, last_name, hire_date
FROM employees
WHERE SYSDATE - hire_date > (SELECT AVG(SYSDATE - hire_date) FROM employees);

SELECT * FROM v_12;

-- 13
CREATE OR REPLACE VIEW v_13 AS
SELECT d.department_name,
       COUNT(e.employee_id) AS liczba_pracownikow,
       ROUND(AVG(e.salary), 2) AS srednie_wynagrodzenie
FROM departments d
JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY liczba_pracownikow DESC;

SELECT * FROM v_13;

-- 14
CREATE OR REPLACE VIEW v_14 AS
SELECT first_name, last_name
FROM employees
WHERE salary < ANY (
    SELECT e.salary
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    WHERE d.department_name = 'IT'
);

SELECT * FROM v_14;

-- 15
CREATE OR REPLACE VIEW v_15 AS
SELECT d.department_id, d.department_name
FROM departments d
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
      AND e.salary > (SELECT AVG(salary) FROM employees)
);

SELECT * FROM v_15;

-- 16
CREATE OR REPLACE VIEW v_16 AS
SELECT job_title, srednie_zarobki
FROM (
    SELECT j.job_title, ROUND(AVG(e.salary), 2) AS srednie_zarobki
    FROM employees e
    JOIN jobs j ON e.job_id = j.job_id
    GROUP BY j.job_title
    ORDER BY AVG(e.salary) DESC
)
WHERE ROWNUM <= 5;

SELECT * FROM v_16;

-- 17
CREATE OR REPLACE VIEW v_17 AS
SELECT r.region_name,
       COUNT(DISTINCT c.country_id) AS liczba_krajow,
       COUNT(e.employee_id) AS liczba_pracownikow
FROM regions r
LEFT JOIN countries c ON c.region_id = r.region_id
LEFT JOIN locations l ON l.country_id = c.country_id
LEFT JOIN departments d ON d.location_id = l.location_id
LEFT JOIN employees e ON e.department_id = d.department_id
GROUP BY r.region_name;

SELECT * FROM v_17;

-- 18
CREATE OR REPLACE VIEW v_18 AS
SELECT e.first_name, e.last_name
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;

SELECT * FROM v_18;

-- 19
CREATE OR REPLACE VIEW v_19 AS
SELECT EXTRACT(MONTH FROM hire_date) AS miesiac,
       COUNT(*) AS liczba_pracownikow
FROM employees
GROUP BY EXTRACT(MONTH FROM hire_date)
ORDER BY miesiac;

SELECT * FROM v_19;

-- 20
CREATE OR REPLACE VIEW v_20 AS
SELECT department_name, srednie_wynagrodzenie
FROM (
    SELECT d.department_name,
           ROUND(AVG(e.salary), 2) AS srednie_wynagrodzenie
    FROM departments d
    JOIN employees e ON e.department_id = d.department_id
    GROUP BY d.department_name
    ORDER BY AVG(e.salary) DESC
)
WHERE ROWNUM <= 3;

SELECT * FROM v_20;