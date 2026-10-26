
import matplotlib.pyplot as plt

months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
]

revenue = [
    23282.45, 19148.24, 28024.14, 28620.70,
    23028.99, 25041.41, 28395.14, 21457.03,
    22507.87, 26175.25, 24908.40, 22751.15
]

plt.figure(figsize=(11, 6))
bars = plt.bar(months, revenue)

plt.title("Monthly Net Revenue")
plt.xlabel("Month")
plt.ylabel("Net Revenue (₹)")

for bar, value in zip(bars, revenue):
    plt.text(
        bar.get_x() + bar.get_width() / 2,
        bar.get_height(),
        f"₹{value:,.0f}",
        ha="center",
        va="bottom",
        fontsize=8
    )

plt.tight_layout()
plt.savefig("05_Analysis/monthly_net_revenue.png", dpi=300)
plt.show()
