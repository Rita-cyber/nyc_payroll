
import psycopg2
from psycopg2 import sql
import json
import pandas as pd
from dotenv import load_dotenv
import os


from data_loading_database import CSVLoader



# Load environment variables
load_dotenv()

def main():

    loader = CSVLoader()
    
    # Step 1: Create the staging tables
    loader.create_staging_tables()
    
    # Step 2: Load each CSV file into its corresponding staging table
    csv_to_table_mapping = {
        r'.\Data\nycpayroll_2020.csv': 'staging_nycpayroll',
        r'.\Data\EmpMaster.csv': 'staging_empmaster',
        r'.\Data\AgencyMaster.csv': 'staging_agencymaster',
        r'.\Data\TitleMaster.csv': 'staging_titlemaster'
    }
    
    for csv_file, table_name in csv_to_table_mapping.items():
        loader.load_csv_to_table(csv_file, table_name)
    
    # Step 3: Close the database connection
    loader.close_connection()



if __name__ == "__main__":
    main()
