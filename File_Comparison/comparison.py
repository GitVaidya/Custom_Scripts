import pandas as pd
import datacompy

# Load the two CSV files
df1 = pd.read_csv('E:\File comparison\file1.csv')  # Replace with your first file
df2 = pd.read_csv('E:\File comparison\file2.csv')  # Replace with your second file

# Print first few rows (optional)
print("First file preview:\n", df1.head())
print("\nSecond file preview:\n", df2.head())

# Perform comparison
compare = datacompy.Compare(
    df1,
    df2,
    join_columns='ID',  # Change this to your actual primary key column
    abs_tol=0,
    rel_tol=0,
    df1_name='Original',
    df2_name='New'
)

# Print comparison summary
print("\n=== Summary Report ===")
print(compare.report())

# Optional: Save report to a text file
with open("comparison_report.txt", "w") as f:
    f.write(compare.report())
