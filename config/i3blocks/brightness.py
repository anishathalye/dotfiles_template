#!/usr/bin/env python3
import subprocess

# Run the brightnessctl commands and capture their output
output_g = subprocess.check_output(["brightnessctl", "g"]).decode().strip()
output_m = subprocess.check_output(["brightnessctl", "m"]).decode().strip()

# Convert output to integers
brightness_g = int(output_g)
brightness_m = int(output_m)

# Perform the calculation
result = (brightness_g / brightness_m) * 100

# Output the result with a "%" suffix
print(f"{result:.0f}%")

