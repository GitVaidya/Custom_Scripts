import pandas as pd
import datacompy

# Load the two CSV files
df1 = pd.read_csv('file3.csv')  # First file
df2 = pd.read_csv('file4.csv')  # Second file

# Reset index to use row position as a key (since no primary key exists)
df1.reset_index(inplace=True)
df2.reset_index(inplace=True)

# Perform the comparison using 'index' as the artificial join key
compare = datacompy.Compare(
    df1,
    df2,
    join_columns='index',  # Use row index as join key
    abs_tol=0,
    rel_tol=0,
    df1_name='Original',
    df2_name='New'
)

# Print report summary
print(compare.report())

# Get mismatched rows (as a DataFrame)
df_mismatches = compare.all_mismatch()

# Save mismatches to CSV
df_mismatches.to_csv("mismatched_rows.csv", index=False)
print("\nMismatches saved to 'mismatched_rows.csv'")
