
CREATE OR REPLACE PROCEDURE payroll.prc_nyc_recordsonly()
AS $$
BEGIN
    -- Insert into dim_employee
    BEGIN
        INSERT INTO payroll.dim_employee (employee_id, last_name, first_name, work_location_borough, leavestatusasofjune30)
        SELECT DISTINCT
            s.employeeid,  
            s.lastname,    
            s.firstname,   
            s.worklocationborough,  
            s.leavestatusasofjune30  
        FROM 
            payroll.staging_nycpayroll s
        LEFT JOIN 
            payroll.dim_employee e
        ON 
            s.employeeid = e.employee_id
        WHERE 
            e.employee_id IS NULL;
    EXCEPTION
        WHEN OTHERS THEN
            -- Log the error
            INSERT INTO payroll.error_log (procedure_name, error_message, error_time)
            VALUES ('prc_nyc_recordsonly', SQLERRM, now());
           
    END;

    -- Insert into dim_title
    BEGIN
        INSERT INTO payroll.dim_title (TitleCode, Titledescription)
        SELECT DISTINCT
            s.titlecode,  
            s.titledescription
        FROM 
            payroll.staging_nycpayroll s
        LEFT JOIN 
            payroll.dim_title t
        ON 
            s.titlecode = t.TitleCode
        WHERE 
            t.TitleCode IS NULL;
    EXCEPTION
        WHEN OTHERS THEN
            -- Log the error
            INSERT INTO payroll.error_log (procedure_name, error_message, error_time)
            VALUES ('prc_nyc_recordsonly', SQLERRM, now());
           
    END;

    -- Insert into dim_agency
    BEGIN
        INSERT INTO payroll.dim_agency (agency_id, agency_name, agency_startDate)
        SELECT DISTINCT
            s.agentcode AS agency_id,  
            s.agencyname,  
            s.agencystartdate
        FROM 
            payroll.staging_nycpayroll s
        LEFT JOIN 
            payroll.dim_agency a
        ON 
            s.agentcode = a.agency_id
        WHERE 
            a.agency_id IS NULL;
    EXCEPTION
        WHEN OTHERS THEN
            -- Log the error
            INSERT INTO payroll.error_log (procedure_name, error_message, error_time)
            VALUES ('prc_nyc_recordsonly', SQLERRM, now());
           
            
    END;

    -- Insert into dim_date
    BEGIN
        WITH DATES_CTE AS (
            SELECT DISTINCT agencystartdate AS datekey 
            FROM payroll.staging_nycpayroll
        )
        INSERT INTO payroll.dim_date (datekey, year, quarter, month, week, dayOfWeek)
        SELECT 
            datekey, 
            EXTRACT(YEAR FROM datekey) AS year, 
            EXTRACT(QUARTER FROM datekey) AS quarter, 
            EXTRACT(MONTH FROM datekey) AS month, 
            EXTRACT(WEEK FROM datekey) AS week, 
            EXTRACT(DOW FROM datekey) AS dayOfWeek
        FROM 
            DATES_CTE
        LEFT JOIN 
            payroll.dim_date d ON DATES_CTE.datekey = d.datekey
        WHERE 
            d.datekey IS NULL;
    EXCEPTION
        WHEN OTHERS THEN
            -- Log the error
            INSERT INTO payroll.error_log (procedure_name, error_message, error_time)
            VALUES ('prc_nyc_recordsonly', SQLERRM, now());
     
           
    END;

    -- Insert into fact_payroll
    BEGIN
        INSERT INTO payroll.fact_payroll (
            datekey,
            employee_id,
            titlecode,
            agency_id,  -- This now corresponds to agentcode
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
            d.datekey,
            e.employee_id,
            t.TitleCode,
            s.agentcode AS agency_id,  -- Map agentcode to agency_id
            s.fiscalyear,
            s.PayrollNumber,
            s.BaseSalary,
            s.PayBasis,
            s.RegularHours,
            s.RegularGrossPaid,
            s.OTHours,
            s.TotalOTPaid,
            s.TotalOtherPay
        FROM
            payroll.staging_nycpayroll s
        JOIN
            payroll.dim_date d ON s.agencystartdate = d.datekey
        JOIN
            payroll.dim_employee e ON s.employeeid = e.employee_id
        JOIN
            payroll.dim_title t ON s.titlecode = t.TitleCode
        JOIN
            payroll.dim_agency a ON s.agentcode = a.agency_id;
    EXCEPTION
        WHEN OTHERS THEN
            -- Log the error
            INSERT INTO payroll.error_log (procedure_name, error_message, error_time)
            VALUES ('prc_nyc_recordsonly', SQLERRM, now());
                       
    END;

END;
$$ LANGUAGE plpgsql;

