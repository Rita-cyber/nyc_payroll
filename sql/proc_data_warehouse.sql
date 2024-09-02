
--- procedure------
CREATE OR REPLACE PROCEDURE payroll.prc_nyc_recordsall()
AS $$
BEGIN
    -- Insert into dim_employee
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
    EXCEPTION
        WHEN OTHERS THEN
            -- Log the error
            RAISE NOTICE 'Error inserting into payroll.dim_employee at %: %', now(), SQLERRM;
            -- Optionally insert into an error log table
            INSERT INTO payroll.error_log (procedure_name, error_message, error_time)
            VALUES ('prc_nyc_recordsall', SQLERRM, now());
    END;

    -- Insert into dim_agency
    BEGIN
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
    EXCEPTION
        WHEN OTHERS THEN
            -- Log the error
            RAISE NOTICE 'Error inserting into payroll.dim_agency at %: %', now(), SQLERRM;
            -- Optionally insert into an error log table
            INSERT INTO payroll.error_log (procedure_name, error_message, error_time)
            VALUES ('prc_nyc_recordsall', SQLERRM, now());
    END;

    -- Insert into dim_Title
    BEGIN
        INSERT INTO payroll.dim_Title (TitleCode, Titledescription)
        SELECT
            COALESCE(title.titlecode, nyc.titlecode) AS TitleCode,
            COALESCE(title.titledescription, nyc.titledescription) AS Titledescription
        FROM payroll.staging_titlemaster title
        FULL OUTER JOIN (
            SELECT DISTINCT titlecode, titledescription
            FROM payroll.staging_nycpayroll
        ) nyc ON title.titlecode = nyc.titlecode
        ORDER BY COALESCE(title.titlecode, nyc.titlecode)
        ON CONFLICT (titlecode) DO NOTHING;
    EXCEPTION
        WHEN OTHERS THEN
            -- Log the error
            RAISE NOTICE 'Error inserting into payroll.dim_Title at %: %', now(), SQLERRM;
            -- Optionally insert into an error log table
            INSERT INTO payroll.error_log (procedure_name, error_message, error_time)
            VALUES ('prc_nyc_recordsall', SQLERRM, now());
    END;

    -- Insert into dim_date
    BEGIN
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
    EXCEPTION
        WHEN OTHERS THEN
            -- Log the error
            RAISE NOTICE 'Error inserting into payroll.dim_date at %: %', now(), SQLERRM;
            -- Optionally insert into an error log table
            INSERT INTO payroll.error_log (procedure_name, error_message, error_time)
            VALUES ('prc_nyc_recordsall', SQLERRM, now());
    END;

    -- Insert into fact_payroll
    BEGIN
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
            d.datekey,
            e.employee_id,
            t.TitleCode,
            a.agency_id,
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
            payroll.dim_Title t ON s.titlecode = t.titlecode
        JOIN
            payroll.dim_agency a ON s.agencyid = a.agency_id;
    EXCEPTION
        WHEN OTHERS THEN
            -- Log the error
            RAISE NOTICE 'Error inserting into payroll.fact_payroll at %: %', now(), SQLERRM;
            -- Optionally insert into an error log table
            INSERT INTO payroll.error_log (procedure_name, error_message, error_time)
            VALUES ('prc_nyc_recordsall', SQLERRM, now());
    END;

END;
$$ LANGUAGE plpgsql;

