CREATE TABLE payroll.error_log (
    log_id SERIAL PRIMARY KEY,
    procedure_name TEXT,
    error_message TEXT,
    error_time TIMESTAMP
);


CREATE TABLE payroll.dim_employee (
	--id serial primary key,
    employee_id varchar(50) primary key,  -- Surrogate key
    last_name varchar(50),
    first_name varchar(50),
	worklocationborough varchar(50),
	leavestatusasofjune30 varchar(50)
	);

CREATE INDEX worklocationborough ON payroll.dim_employee (worklocationborough);



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




