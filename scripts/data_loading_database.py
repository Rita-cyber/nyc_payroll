
import os
import psycopg2
import pandas as pd
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class CSVLoader:
    def __init__(self):
        """
        Initialize the CSVLoader class.
        
        :param db_params: Dictionary containing database connection parameters
        """

        # Establish a connection to the PostgreSQL database
        self.conn = psycopg2.connect(
           host = os.getenv('PG_HOST'),
            db = os.getenv('PG_DB'),
            user = os.getenv('PG_USER'),
            password = os.getenv('PG_PASSWORD')
        )
        self.cursor = self.conn.cursor()

    def create_staging_tables(self):
        # SQL to create staging tables if they don't exist
        create_tables_queries = {
                        
                                    '''
                            
    
                                    -- Drop the staging tables with CASCADE to remove dependent objects
                                    


                                    DROP TABLE IF EXISTS payroll.staging_nycpayroll CASCADE;
                                    DROP TABLE IF EXISTS payroll.staging_empmaster CASCADE;
                                    DROP TABLE IF EXISTS payroll.staging_agencymaster CASCADE;
                                    DROP TABLE IF EXISTS payroll.staging_titlemaster CASCADE;


                                    '''

            'staging_nycpayroll': '''
                CREATE TABLE IF NOT EXISTS payroll.staging_nycpayroll (
                    ID SERIAL PRIMARY KEY,
                                        fiscalyear INTEGER,
                                        PayrollNumber VARCHAR(255),
                                        AgencyID VARCHAR(255),
                                        AgencyName VARCHAR(255),
                                        EmployeeID VARCHAR(255),
                                        LastName VARCHAR(255),
                                        FirstName VARCHAR(255),
                                        AgencyStartDate DATE,
                                        WorkLocationBorough     VARCHAR(255),
                                        TitleCode               VARCHAR(255),
                                        TitleDescription        VARCHAR(255),
                                        LeaveStatusasofJune30   VARCHAR(255),
                                        BaseSalary              FLOAT,   
                                        PayBasis                VARCHAR(255),
                                        RegularHours            INTEGER,
                                        RegularGrossPaid        FLOAT,
                                        OTHours                 FLOAT,
                                        TotalOTPaid             FLOAT,
                                        TotalOtherPay           FLOAT
                );
            ''',
            'staging_empmaster': '''
                CREATE TABLE IF NOT EXISTS payroll.staging_empmaster (
                    EmployeeID VARCHAR(255),
                                            LastName VARCHAR(255),
                                            FirstName VARCHAR(255),
                                            -- Add additional columns as needed
                                            PRIMARY KEY (EmployeeID)
                );
            ''',
            'staging_agencymaster': '''
                CREATE TABLE IF NOT EXISTS payroll.staging_agencymaster (
                    AgencyID VARCHAR(255),
                                            AgencyName VARCHAR(255),
                                            AgencyAddress VARCHAR(255),
                                                -- Add additional columns as needed
                                            PRIMARY KEY (AgencyID)
                );
            ''',
            'staging_titlemaster': '''
                CREATE TABLE IF NOT EXISTS payroll.staging_titlemaster (
                    TitleCode VARCHAR(255),
                                            TitleDescription VARCHAR(255),
                                        -- Add additional columns as needed
                                            PRIMARY KEY (TitleCode)
                );
            '''
        }
        
        for table_name, create_query in create_tables_queries.items():
            try:
                self.cursor.execute(create_query)
                self.conn.commit()
                print(f"Table {table_name} created successfully.")
            except Exception as e:
                print(f"Error creating table {table_name}: {e}")

    def load_csv_to_table(self, csv_file, table_name):

        """
    Insert data from a csvfilepath into a PostgreSQL table in batch.
        
    :param csv_file: csv files to be inserted
    :param table_name: Target table name in PostgreSQL

        """

        try:
            # Read the CSV file into a DataFrame
            df = pd.read_csv(csv_file)

            # Generate the SQL for inserting data
            #columns = ', '.join(df.columns)
            #values = ', '.join(['%s'] * len(df.columns))
            #insert_query = f'INSERT INTO payroll.{table_name} ({columns}) VALUES ({values})'

            # Map columns to handle differences like AgencyID vs AgencyCode
            # You can expand this dictionary to include other similar mappings
            # Check if 'AgencyCode' exists in the dataframe and rename it to 'AgencyID'
            if 'AgencyCode' in df.columns and 'AgencyID' not in df.columns:
                df.rename(columns={'AgencyCode': 'AgencyID'}, inplace=True)

            # Prepare the data to be inserted (as a list of tuples)
            data = [tuple(row) for row in df.itertuples(index=False, name=None)]
            
            # Generate the SQL for inserting data
            columns = ', '.join(df.columns)
            values = ', '.join(['%s'] * len(df.columns))
            # Assuming table_name is defined
            insert_query = f'INSERT INTO payroll.{table_name} ({columns}) VALUES ({values})'
            
            # Insert DataFrame rows into the table
            for row in df.itertuples(index=False, name=None):
                self.cursor.execute(insert_query, row)
            
            self.conn.commit()
            print(f"Data from {csv_file} loaded into {table_name} successfully.")
        
        except Exception as e:
            print(f"Error loading data from {csv_file} into {table_name}: {e}")

    def close_connection(self):
        # Close the cursor and the connection
        self.cursor.close()
        self.conn.close()
