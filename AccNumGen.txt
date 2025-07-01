def calculate_checksum(account_number):
    weights = [2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2]
    total = sum(int(digit) * weight for digit, weight in zip(account_number, weights))
    print(account_number,total)
    raw_checksum = total % 11

    if raw_checksum == 1:
        final_checksum = -1
    elif raw_checksum != 0:
        final_checksum = 11 - raw_checksum
    else:
        final_checksum = 0

    return raw_checksum, final_checksum

def process_account_numbers(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        outfile.write("AccountNumber\tFinalChecksum\tRawChecksum\n")
        for line in infile:
            acc = line.strip()
            if len(acc) == 11 and acc.isdigit():
                raw, final = calculate_checksum(acc)
                outfile.write(f"{acc}\t{final}\t{raw}\n")
            else:
                outfile.write(f"{acc}\tINVALID\tINVALID\n")

# Example usage
input_filename = 'input_accounts.txt'     # Input file: one account number per line
output_filename = 'output_checksums.txt'  # Output file

process_account_numbers(input_filename, output_filename)
