

-- The Top 5 employees with highest otpaid and their respective leave status.
SELECT
    d.employee_id,
    d.last_name,
    d.first_name,
    d.worklocationborough AS work_location,
    t.titledescription AS title_description,
    s.leavestatusasofjune30 AS leave_status,
    AVG(f.othours) AS average_overtime_hours,
    SUM(f.totalotpaid) AS total_overtime_paid
FROM
    payroll.dim_employee d
JOIN
    payroll.fact_payroll f ON d.employee_id = f.employee_id
JOIN
    payroll.dim_title t ON f.titlecode = t.titlecode
JOIN
    payroll.staging_nycpayroll s ON f.employee_id = s.employeeid
GROUP BY
    d.employee_id,
    d.last_name,
    d.first_name,
    d.worklocationborough,
    t.titledescription,
    s.leavestatusasofjune30
ORDER BY
    total_overtime_paid DESC
LIMIT 5;


--- The trend of top 5 employees with the highest ot hours.
SELECT
    e.employee_id,
    e.last_name,
    e.first_name,
    e.leavestatusasofjune30 AS leave_status,
    d."year",
    d."month",
    SUM(f.othours) AS total_overtime_hours
FROM
    payroll.dim_employee e
JOIN
    payroll.fact_payroll f ON e.employee_id = f.employee_id
JOIN
    payroll.dim_date d ON f.datekey = d.datekey
GROUP BY
    e.employee_id,
    e.last_name,
    e.first_name,
    e.leavestatusasofjune30,
    d."year",
    d."month"
ORDER BY
	total_overtime_hours DESC
LIMIT 5;

-- Compare the wages,otpaid of employees
SELECT
    e.employee_id,
    e.last_name,
    e.first_name,
    SUM(f.totalotpaid) AS total_overtime_paid,
    AVG(f.BaseSalary) AS average_base_salary,
    SUM(f.RegularGrossPaid) AS total_regular_wages
FROM
    payroll.dim_employee e
JOIN
    payroll.fact_payroll f ON e.employee_id = f.employee_id
JOIN
    payroll.dim_date d ON f.datekey = d.datekey
WHERE
    d."year" >= EXTRACT(YEAR FROM CURRENT_DATE) - 5  -- Filter for the last 5 years
GROUP BY
    e.employee_id,
    e.last_name,
    e.first_name
ORDER BY
    total_overtime_paid DESC
LIMIT 5;


