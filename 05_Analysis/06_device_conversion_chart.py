
import matplotlib.pyplot as plt

devices = ["Desktop", "Mobile", "Tablet"]
conversion_rates = [18.19, 12.93, 13.31]

plt.figure(figsize=(9, 6))
bars = plt.bar(devices, conversion_rates)

plt.title("Conversion Rate by Device")
plt.xlabel("Device Type")
plt.ylabel("Conversion Rate (%)")
plt.ylim(0, 22)

for bar, rate in zip(bars, conversion_rates):
    plt.text(
        bar.get_x() + bar.get_width() / 2,
        bar.get_height(),
        f"{rate:.2f}%",
        ha="center",
        va="bottom"
    )

plt.tight_layout()
plt.savefig("05_Analysis/device_conversion_rate.png", dpi=300)
plt.show()
