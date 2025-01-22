#!/usr/bin/env python3
import csv
from datetime import datetime
import os
import sys
import socket

#
# Set the location where your CSV file will be stored
CSV_FILE = os.path.expanduser(
    f"~/Nextcloud/unlock_log_{socket.gethostname()}.csv"
)  # Adjust the path as needed


def log_event(event_type):
    today_date = datetime.now().strftime("%Y-%m-%d")
    time_str = datetime.now().strftime("%H:%M:%S")
    row_found = False

    # Check if the CSV file exists; if not, create it and add the header
    if not os.path.isfile(CSV_FILE):
        with open(CSV_FILE, mode="w", newline="") as file:
            writer = csv.writer(file)
            writer.writerow(["Date", "WorkIn", "WorkOut"])  # Header row

    # Read existing rows
    with open(CSV_FILE, mode="r", newline="") as file:
        rows = list(csv.reader(file))

    # Check if header exists and is valid; if not, add it
    if not rows or rows[0] != ["Date", "WorkIn", "WorkOut"]:
        rows.insert(0, ["Date", "WorkIn", "WorkOut"])  # Insert header if not present

    # Find today's row or create a new row if not found
    for row in rows[1:]:  # Start from the second row to skip the header
        if row[0] == today_date:
            row_found = True
            if event_type == "unlock":
                if row[1] == "":  # First unlock of the day
                    row[1] = time_str  # Log WorkIn time
                else:
                    row[2] = time_str  # Update WorkOut time for the day
            elif event_type == "lock":
                row[2] = time_str  # Update WorkOut time on lock
            break

    # If no row for today, create a new row
    if not row_found:
        new_row = [today_date, "", ""]
        if event_type == "unlock":
            new_row[1] = time_str  # Log WorkIn for the first unlock
        rows.append(new_row)

    # Write updated rows back to the CSV file
    with open(CSV_FILE, mode="w", newline="") as file:
        writer = csv.writer(file)
        writer.writerows(rows)


if __name__ == "__main__":
    import sys

    if len(sys.argv) != 2:
        print("Usage: python log_unlock_time.py <event_type>")
        sys.exit(1)

    event_type = sys.argv[1]
    if event_type not in ["lock", "unlock"]:
        print("Invalid event type. Use 'lock' or 'unlock'.")
        sys.exit(1)

    log_event(event_type)
