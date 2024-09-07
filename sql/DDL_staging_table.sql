CREATE TABLE payroll.staging_nycpayroll (
            ID SERIAL PRIMARY KEY,
            fiscalyear INTEGER,
            PayrollNumber VARCHAR(255),
            AgencyID VARCHAR(255),
            AgencyName VARCHAR(255),
            EmployeeID VARCHAR(255),
            LastName VARCHAR(255),
            FirstName VARCHAR(255),
            AgencyStartDate DATE,
            WorkLocationBorough VARCHAR(255),
            TitleCode VARCHAR(255),
            TitleDescription VARCHAR(255),
            LeaveStatusasofJune30 VARCHAR(255),
            BaseSalary FLOAT,
            PayBasis VARCHAR(255),
            RegularHours INTEGER,
            RegularGrossPaid FLOAT,
            OTHours FLOAT,
            TotalOTPaid FLOAT,
            TotalOtherPay FLOAT
        );

        -- Create staging_empmaster table
        CREATE TABLE payroll.staging_empmaster (
            EmployeeID VARCHAR(255) Primary Key,
            LastName VARCHAR(255),
            FirstName VARCHAR(255)
         
        );

        -- Create staging_agencymaster table
        CREATE TABLE payroll.staging_agencymaster (
            AgencyID VARCHAR(255) Primary Key,
            AgencyName VARCHAR(255),
            AgencyAddress VARCHAR(255)
            
        );

        -- Create staging_titlemaster table
        CREATE TABLE payroll.staging_titlemaster (
            TitleCode VARCHAR(255) Primary Key,
            TitleDescription VARCHAR(255));
           