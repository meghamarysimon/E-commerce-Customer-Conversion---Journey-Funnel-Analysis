from pathlib import Path
import pandas as pd

project_folder = Path(__file__).resolve().parents[1]
raw_data_folder = project_folder / "01_Raw_Data"

events = pd.read_csv(raw_data_folder / "events.csv")

funnel_stages = [
    "visit",
    "product_view",
    "add_to_cart",
    "checkout",
    "payment",
    "purchase"
]

funnel = (
    events[events["event_type"].isin(funnel_stages)]
    .groupby("event_type")["session_id"]
    .nunique()
    .reindex(funnel_stages)
    .reset_index()
)

funnel.columns = ["funnel_stage", "sessions"]
funnel["conversion_from_previous_percent"] = (
    funnel["sessions"] / funnel["sessions"].shift(1) * 100
).round(2)

funnel.loc[0, "conversion_from_previous_percent"] = 100

funnel["drop_off_sessions"] = (
    funnel["sessions"].shift(1) - funnel["sessions"]
).fillna(0).astype(int)

funnel["drop_off_percent"] = (
    100 - funnel["conversion_from_previous_percent"]
).fillna(0).round(2)

output_file = Path(__file__).resolve().parent / "funnel_summary.csv"
funnel.to_csv(output_file, index=False)

print(funnel.to_string(index=False))

print(f"\nSaved funnel summary to: {output_file.name}")