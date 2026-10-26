from pathlib import Path
import pandas as pd

project_folder = Path(__file__).resolve().parents[1]
raw_data_folder = project_folder / "01_Raw_Data"

csv_files = [
    "customers.csv",
    "products.csv",
    "sessions.csv",
    "events.csv",
    "orders.csv",
    "order_items.csv"
]

for file_name in csv_files:
    file_path = raw_data_folder / file_name
    data = pd.read_csv(file_path)

    print("=" * 60)
    print(f"FILE: {file_name}")
    print(f"Rows: {data.shape[0]}")
    print(f"Columns: {data.shape[1]}")
    print(f"Column names: {', '.join(data.columns)}")

    print(f"Duplicate rows: {data.duplicated().sum()}")

    missing_values = data.isnull().sum()
    missing_values = missing_values[missing_values > 0]

    if missing_values.empty:
        print("Missing values: None")
    else:
        print("Missing values:")
        print(missing_values)

    print()