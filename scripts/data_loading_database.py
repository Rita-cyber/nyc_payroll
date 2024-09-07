
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
