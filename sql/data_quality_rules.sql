CREATE OR REPLACE FUNCTION payroll.validate_and_quarantine_payroll_data() 
RETURNS TRIGGER AS $$
BEGIN
    -- Check if "fiscalyear" is null or less than a reasonable value (e.g., 1900)
    IF (NEW."fiscalyear" IS NULL OR NEW."fiscalyear" < 1900) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Invalid Value', 'FiscalYear cannot be null or less than 1900');
        RETURN NULL;  -- Skip the insert into the original table

    -- Check if "PayrollNumber" is null
    ELSIF (NEW."PayrollNumber" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'PayrollNumber cannot be null');
        RETURN NULL;  -- Skip the insert into the original table

    -- Check if "AgencyID" is null
    ELSIF (NEW."agencyid" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'AgencyID cannot be null');
        RETURN NULL;  -- Skip the insert into the original table

    ELSIF (NEW."agencyname" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'AgencyName cannot be null');
        RETURN NULL;

    -- Check if "EmployeeID" is null
    ELSIF (NEW."employeeid"::integer IS NULL OR NEW."employeeid"::integer < 0) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'EmployeeID cannot be null');
        RETURN NULL;  -- Skip the insert into the original table
    ELSIF (NEW."lastname" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'lastname cannot be null');
        RETURN NULL;
    ELSIF (NEW."firstname" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'firstname cannot be null');
        RETURN NULL;
    ELSIF (NEW."agencystartdate" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'Agencystartdate cannot be null');
        RETURN NULL;
    ELSIF (NEW."worklocationborough" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'worklocationborough cannot be null');
        RETURN NULL;
    ELSIF NEW."titlecode"::integer IS NULL OR NEW."titlecode"::integer < 0) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'titlecode cannot be null');
        RETURN NULL;
    ELSIF (NEW."titledescription" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'titledescription cannot be null');
        RETURN NULL;
    ELSIF (NEW."leavestatusasofjune30" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'leavestatusasofjune30 cannot be null');
        RETURN NULL;

    -- Check if "BaseSalary" is null or less than 0
    ELSIF (NEW."basesalary"::integer IS NULL OR NEW."basesalary"::integer < 0) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Invalid Value', 'BaseSalary cannot be null or negative');
        RETURN NULL;  -- Skip the insert into the original table
    ELSIF (NEW."paybasis" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'PayBasis cannot be null');
        RETURN NULL;
    ELSIF (NEW."regularhours" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'regularhours cannot be null');
        RETURN NULL;
    ELSIF (NEW."regulargrosspaid" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'regulargrosspaid cannot be null');
        RETURN NULL;
    ELSIF (NEW."othours" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'othours cannot be null');
        RETURN NULL;
    ELSIF (NEW."totalotpaid" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'totalotpaid cannot be null');
        RETURN NULL;
    ELSIF (NEW."totalotherpay" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'totalotherpaid cannot be null');
        RETURN NULL;
    -- Add more checks as necessary for other fields...
    
    ELSE
        RETURN NEW;  -- Proceed with the insert if all data is valid
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER nyc_validate_before_insert
BEFORE INSERT ON payroll.staging_nycpayroll
FOR EACH ROW
EXECUTE FUNCTION payroll.validate_and_quarantine_payroll_data()

CREATE OR REPLACE FUNCTION payroll.validate_and_quarantine_agency_data() 
RETURNS TRIGGER AS $$
BEGIN
    -- Example validation: Ensure certain fields are not null and within expected ranges
    IF(NEW."agencyid"::integer IS NULL OR NEW."agencyid"::integer < 0) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'agencyid cannot be null');
        RETURN NULL;
    ELSIF (NEW."agencyname" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'AgencyName cannot be null');
        RETURN NULL;
	
	
    -- Add more checks as necessary
    ELSE
        RETURN NEW; -- Proceed with the insert if data is valid
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER agency_validate_before_insert
BEFORE INSERT ON payroll.staging_agencymaster
FOR EACH ROW
EXECUTE FUNCTION payroll.validate_and_quarantine_agency_data()

CREATE OR REPLACE FUNCTION payroll.validate_and_quarantine_employee_data() 
RETURNS TRIGGER AS $$
BEGIN
    -- Example validation: Ensure certain fields are not null and within expected ranges
    IF(NEW."employeeid"::integer IS NULL OR NEW."employeeid"::integer < 0) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'employeeid cannot be null');
        RETURN NULL;
    ELSIF (NEW."lastname" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'lastName cannot be null');
        RETURN NULL;
    ELSIF (NEW."firstname" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'firstname cannot be null');
        RETURN NULL;
	
	
    -- Add more checks as necessary
    ELSE
        RETURN NEW; -- Proceed with the insert if data is valid
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER emp_validate_before_insert
BEFORE INSERT ON payroll.staging_empmaster
FOR EACH ROW
EXECUTE FUNCTION payroll.validate_and_quarantine_employee_data()

CREATE OR REPLACE FUNCTION payroll.validate_and_quarantine_title_data() 
RETURNS TRIGGER AS $$
BEGIN
    -- Example validation: Ensure certain fields are not null and within expected ranges
    IF(NEW."titlecode"::integer IS NULL OR NEW."titlecode"::integer < 0) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'titlecode cannot be null');
        RETURN NULL;
    ELSIF (NEW."titledescription" IS NULL) THEN
        INSERT INTO payroll.quarantine_data (source_table_name, original_data, error_type, error_details)
        VALUES (TG_TABLE_NAME, row_to_json(NEW), 'Null Value', 'titledescription cannot be null');
        RETURN NULL;
	
	
    -- Add more checks as necessary
    ELSE
        RETURN NEW; -- Proceed with the insert if data is valid
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER title_validate_before_insert
BEFORE INSERT ON payroll.staging_titlemaster
FOR EACH ROW
EXECUTE FUNCTION payroll.validate_and_quarantine_title_data()

