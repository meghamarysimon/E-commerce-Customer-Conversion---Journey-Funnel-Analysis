from pathlib import Path
import pandas as pd

project_folder = Path(__file__).resolve().parents[1]
raw_data_folder = project_folder / "01_Raw_Data"

orders = pd.read_csv(raw_data_folder / "orders.csv")
orders["order_date"] = pd.to_datetime(orders["order_date"])

monthly_revenue = (
    orders.assign(month=orders["order_date"].dt.to_period("M").astype(str))
    .groupby("month", as_index=False)
    .agg(
        total_orders=("order_id", "nunique"),
        net_revenue=("net_revenue", "sum")
    )
)

monthly_revenue["net_revenue"] = monthly_revenue["net_revenue"].round(2)

output_file = Path(__file__).resolve().parent / "monthly_revenue_summary.csv"
monthly_revenue.to_csv(output_file, index=False)

print(monthly_revenue.to_string(index=False))