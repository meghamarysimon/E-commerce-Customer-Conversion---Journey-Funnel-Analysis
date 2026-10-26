from pathlib import Path
import pandas as pd

# Project folders
project_folder = Path(__file__).resolve().parents[1]
raw_data_folder = project_folder / "01_Raw_Data"
cleaned_data_folder = project_folder / "02_Cleaned_Data"

# Create cleaned-data folder if it does not exist
cleaned_data_folder.mkdir(exist_ok=True)

# Main project tables
files = [
    "customers.csv",
    "products.csv",
    "sessions.csv",
    "events.csv",
    "orders.csv",
    "order_items.csv"
]

for file_name in files:

    input_file = raw_data_folder / file_name
    output_file = cleaned_data_folder / file_name

    # Read raw data
    data = pd.read_csv(input_file)

    # Remove accidental spaces from column names
    data.columns = data.columns.str.strip()

    # Remove completely duplicated rows
    data = data.drop_duplicates()

    # Convert date/time columns
    date_columns = [
        column for column in data.columns
        if "date" in column.lower() or "ts" in column.lower()
        or "start" in column.lower()
    ]

    for column in date_columns:
        data[column] = pd.to_datetime(data[column], errors="coerce")

    # Remove leading/trailing spaces from text columns
    text_columns = data.select_dtypes(include="object").columns

    for column in text_columns:
        data[column] = data[column].str.strip()

    # Save cleaned data
    data.to_csv(output_file, index=False)

    print(f"Cleaned: {file_name}")
    print(f"Rows: {len(data)}")
    print(f"Columns: {len(data.columns)}")
    print("-" * 50)

print("Cleaning completed successfully.")
print(f"Cleaned files saved in: {cleaned_data_folder}")