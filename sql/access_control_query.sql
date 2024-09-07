-- Create a new role
CREATE ROLE readonly_group;

-- Grant SELECT (read-only) access to all tables in the 'public' schema
GRANT USAGE ON SCHEMA public TO readonly_group;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_group;

-- Optionally, grant access to future tables that are created
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readonly_group;

-- Create individual users
CREATE ROLE user1 WITH LOGIN PASSWORD 'user1password';
CREATE ROLE user2 WITH LOGIN PASSWORD 'user2password';

-- Assign the users to the readonly_group
GRANT readonly_group TO user1;
GRANT readonly_group TO user2;

--Additional Permissions for Specific Users
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO user1;

