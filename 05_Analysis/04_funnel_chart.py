
import matplotlib.pyplot as plt

stages = [
    "Visit",
    "Product View",
    "Add to Cart",
    "Checkout",
    "Payment",
    "Purchase"
]

sessions = [12000, 8852, 4545, 2577, 1909, 1750]

plt.figure(figsize=(10, 6))
bars = plt.bar(stages, sessions)

plt.title("E-commerce Customer Funnel Stage Counts")
plt.xlabel("Funnel Stage")
plt.ylabel("Number of Sessions")
plt.xticks(rotation=20)

for bar, value in zip(bars, sessions):
    plt.text(
        bar.get_x() + bar.get_width() / 2,
        bar.get_height(),
        f"{value:,}",
        ha="center",
        va="bottom"
    )

plt.tight_layout()
plt.savefig("05_Analysis/funnel_stage_counts.png", dpi=300)
plt.show()
