CREATE TABLE payroll.dim_employee (
	--id serial primary key,
    employee_id varchar(50) primary key,  -- Surrogate key
    last_name varchar(50),
    first_name varchar(50),
	worklocationborough varchar(50),
	leavestatusasofjune30 varchar(50)
	);

CREATE INDEX worklocationborough ON payroll.dim_employee (worklocationborough);


drop table payroll.dim_employee
drop table payroll.dim_employee_p2



-- Partition for employees working in Brooklyn


select * from payroll.dim_date

select * from payroll.dim_Title
where worklocationborough = 'MANHATTAN';

select agency_startdate from payroll.dim_agency



-- Additional partitions as needed
drop table payroll.dim_agency
CREATE TABLE payroll.dim_agency(
	agency_id varchar primary key,
	agency_name varchar(255),
	agency_startDate Date
	);
CREATE INDEX agency_startDate ON payroll.dim_agency (agency_startDate);


	CREATE TABLE payroll.dim_date(
		datekey date primary key,
		year integer,
		quarter integer,
		month integer,
		week integer,
		dayOfWeek integer
	);


drop table payroll.dim_Title
CREATE TABLE payroll.dim_Title(
		TitleCode varchar(1000) primary key,
		Titledescription varchar(1000)
	);
	
CREATE INDEX TitleCode ON payroll.dim_Title (TitleCode);



CREATE TABLE payroll.fact_payroll (
    id SERIAL PRIMARY KEY,
    datekey DATE,
    employee_id VARCHAR(50),
    titlecode VARCHAR(1000),
    agency_id VARCHAR(50),
    fiscalyear INTEGER,
    PayrollNumber VARCHAR(255),
    BaseSalary FLOAT,
    PayBasis VARCHAR(255),
    RegularHours INTEGER,
    RegularGrossPaid FLOAT,
    OTHours FLOAT,
    TotalOTPaid FLOAT,
    TotalOtherPay FLOAT,
    
    FOREIGN KEY (datekey) REFERENCES payroll.dim_date(datekey),
    FOREIGN KEY (employee_id) REFERENCES payroll.dim_employee(employee_id),
    FOREIGN KEY (titlecode) REFERENCES payroll.dim_Title(TitleCode),
    FOREIGN KEY (agency_id) REFERENCES payroll.dim_agency(agency_id)
);






--- procedure------
CREATE PROCEDURE payroll.prc_nyc_recordsall
AS
BEGIN

INSERT INTO payroll.dim_employee (employee_id, last_name, first_name, worklocationborough, leavestatusasofjune30)
SELECT
    COALESCE(a.employeeid, b.employeeid) AS employee_id,
    COALESCE(a.lastname, b.lastname) AS last_name,
    COALESCE(a.firstname, b.firstname) AS first_name,
    b.worklocationborough,
    b.leavestatusasofjune30
FROM payroll.staging_empmaster a
FULL OUTER JOIN (
    SELECT DISTINCT employeeid, lastname, firstname, worklocationborough, leavestatusasofjune30
    FROM payroll.staging_nycpayroll
) b ON a.employeeid = b.employeeid
ORDER BY COALESCE(a.employeeid, b.employeeid);


INSERT INTO payroll.dim_agency (agency_id, agency_name, agency_startDate)
SELECT
    COALESCE(agency.agencyid, nyc.agencyid) AS agency_id,
    COALESCE(agency.agencyname, nyc.agencyname) AS agency_name,
    nyc.agencystartdate AS agency_startDate 
FROM payroll.staging_agencymaster agency
FULL OUTER JOIN (
    SELECT DISTINCT agencyid, agencyname, agencystartdate
    FROM payroll.staging_nycpayroll
) nyc ON agency.agencyid = nyc.agencyid
ORDER BY COALESCE(agency.agencyid, nyc.agencyid)
ON CONFLICT (agency_id) DO NOTHING;

INSERT INTO payroll.dim_Title (TitleCode,Titledescription )
SELECT
    COALESCE(title.titlecode, nyc.titlecode) AS TitleCode ,
    COALESCE(title.titledescription, nyc.titledescription) AS Titledescription 
FROM payroll.staging_titlemaster title
FULL OUTER JOIN (
    SELECT DISTINCT titlecode, titledescription
    FROM payroll.staging_nycpayroll
) nyc ON title.titlecode = nyc.titlecode
ORDER BY COALESCE(title.titlecode, nyc.titlecode)
ON CONFLICT (titlecode) DO NOTHING;
	
	

	WITH dates_cte AS (
    SELECT DISTINCT agencystartdate::date AS datekey
    FROM payroll.staging_nycpayroll
)
INSERT INTO payroll.dim_date (datekey, "year", "quarter", "month", "week", dayofweek)
SELECT 
    datekey, 
    EXTRACT(YEAR FROM datekey) AS "year", 
    EXTRACT(QUARTER FROM datekey) AS "quarter", 
    EXTRACT(MONTH FROM datekey) AS "month", 
    EXTRACT(WEEK FROM datekey) AS "week", 
    EXTRACT(DOW FROM datekey) AS dayofweek
FROM dates_cte;


INSERT INTO payroll.dim_employee (employee_id, last_name, first_name, worklocationborough, leavestatusasofjune30)
SELECT
    COALESCE(a.employeeid, b.employeeid) AS employee_id,
    COALESCE(a.lastname, b.lastname) AS last_name,
    COALESCE(a.firstname, b.firstname) AS first_name,
    b.worklocationborough,
    b.leavestatusasofjune30
FROM payroll.staging_empmaster a
FULL OUTER JOIN (
    SELECT DISTINCT employeeid, lastname, firstname, worklocationborough, leavestatusasofjune30
    FROM payroll.staging_nycpayroll
) b ON a.employeeid = b.employeeid
ORDER BY COALESCE(a.employeeid, b.employeeid);
	
	
select * from payroll.fact_payroll

	INSERT INTO payroll.fact_payroll (
    datekey,
    employee_id,
    titlecode,
    agency_id,
    fiscalyear,
    PayrollNumber,
    BaseSalary,
    PayBasis,
    RegularHours,
    RegularGrossPaid,
    OTHours,
    TotalOTPaid,
    TotalOtherPay
)
SELECT
    d.datekey,                                 -- Date key from the dim_date table
    e.employee_id,                             -- Employee ID from the dim_employee table
    t.TitleCode,                               -- Title code from the dim_Title table
    a.agency_id,                               -- Agency ID from the dim_agency table
    s.fiscalyear,                              -- Fiscal year from the staging table
    s.PayrollNumber,                           -- Payroll number from the staging table
    s.BaseSalary,                              -- Base salary from the staging table
    s.PayBasis,                                -- Pay basis from the staging table
    s.RegularHours,                            -- Regular hours from the staging table
    s.RegularGrossPaid,                        -- Regular gross paid from the staging table
    s.OTHours,                                 -- Overtime hours from the staging table
    s.TotalOTPaid,                             -- Total overtime paid from the staging table
    s.TotalOtherPay                            -- Total other pay from the staging table
FROM
    payroll.staging_nycpayroll s
JOIN
    payroll.dim_date d ON s.agencystartdate = d.datekey
JOIN
    payroll.dim_employee e ON s.employeeid = e.employee_id
JOIN
    payroll.dim_Title t ON s.titlecode = t.titlecode
JOIN
    payroll.dim_agency a ON s.agencyid = a.agency_id;


