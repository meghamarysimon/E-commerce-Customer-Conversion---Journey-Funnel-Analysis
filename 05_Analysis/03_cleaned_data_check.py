from pathlib import Path
import pandas as pd

project_folder = Path(__file__).resolve().parents[1]
cleaned_data_folder = project_folder / "02_Cleaned_Data"

files = [
    "customers.csv",
    "products.csv",
    "sessions.csv",
    "events.csv",
    "orders.csv",
    "order_items.csv"
]

for file_name in files:

    file_path = cleaned_data_folder / file_name
    data = pd.read_csv(file_path)

    print("=" * 50)
    print(f"FILE: {file_name}")
    print(f"Rows: {data.shape[0]}")
    print(f"Columns: {data.shape[1]}")
    print(f"Duplicate rows: {data.duplicated().sum()}")
    print(f"Missing values: {data.isnull().sum().sum()}")

print("=" * 50)
print("Cleaned data verification completed.")