import unittest
from unittest.mock import patch, MagicMock
import psycopg2
import pandas as pd



from scripts.data_loading_database import CSVLoader  # Replace with your actual module name
class TestCSVLoader(unittest.TestCase):
    @patch('psycopg2.connect')
    def setUp(self, mock_connect):
        # Mock the database connection and cursor
        self.mock_conn = MagicMock()
        self.mock_cursor = MagicMock()
        mock_connect.return_value = self.mock_conn
        self.mock_conn.cursor.return_value = self.mock_cursor

        # Instantiate the CSVLoader with the mocked connection
        self.loader = CSVLoader()


    @patch('pandas.read_csv')
    def test_load_csv_to_table(self, mock_read_csv):
        # Mock the DataFrame returned by pandas.read_csv
        mock_df = MagicMock()
        mock_read_csv.return_value = mock_df
        mock_df.columns = ['AgencyID', 'AgencyName']  # Add more columns as necessary
        mock_df.itertuples.return_value = [(1, 'Agency A'), (2, 'Agency B')]  # Mock rows
        
        # Call the load_csv_to_table method
        self.loader.load_csv_to_table('dummy.csv', 'staging_agencymaster')

        # Assert that the cursor's execute method was called with the correct SQL
        self.assertTrue(self.mock_cursor.execute.called)
        self.mock_cursor.execute.assert_called()

        # Check if rename was called in case 'AgencyCode' was in the columns
        if 'AgencyCode' in mock_df.columns:
            mock_df.rename.assert_called_with(columns={'AgencyCode': 'AgencyID'}, inplace=True)
        
        self.mock_conn.commit.assert_called()

    def tearDown(self):
        # Close the connection at the end of each test
        self.loader.close_connection()
        self.assertTrue(self.mock_cursor.close.called)
        self.assertTrue(self.mock_conn.close.called)

if __name__ == '__main__':
    unittest.main()

