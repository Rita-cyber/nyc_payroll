-- Create a new role
CREATE ROLE readonly_group;

-- Grant SELECT (read-only) access to all tables in the 'payroll' schema
GRANT USAGE ON SCHEMA payroll TO readonly_group;
GRANT SELECT ON ALL TABLES IN SCHEMA payroll TO readonly_group;

-- Optionally, grant access to future tables that are created
ALTER DEFAULT PRIVILEGES IN SCHEMA payroll GRANT SELECT ON TABLES TO readonly_group;

-- Create individual users
CREATE ROLE user1 WITH LOGIN PASSWORD 'user1password';
CREATE ROLE user2 WITH LOGIN PASSWORD 'user2password';

-- Assign the users to the readonly_group
GRANT readonly_group TO user1;
GRANT readonly_group TO user2;

----Create modify roles
CREATE ROLE modify_group

---Grant modify privileges to the modify_group
GRANT INSERT, UPDATE, DELETE,REFERENCES ON ALL TABLES IN SCHEMA payroll TO modify_group;

----Create users of modify_group
CREATE USER user3 WITH PASSWORD 'user1password';

CREATE USER user4 WITH PASSWORD 'user1password';


--Permissions for Specific Users
GRANT INSERT, UPDATE,REFERENCES ON ALL TABLES IN SCHEMA payroll TO user3;
GRANT DELETE ON ALL TABLES IN SCHEMA payroll TO user4;

