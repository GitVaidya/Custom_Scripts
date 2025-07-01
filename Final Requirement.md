✅ Final Requirements Recap
Input file contains exactly 11-digit numeric account numbers.

Any number not 11 digits or not all digits → Invalid

Compute checksum using weights:
[2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2]

Compute raw_checksum = total % 11

Then apply adjustment:

If raw_checksum == 1 → final_checksum = -1

Else if raw_checksum != 0 → final_checksum = 11 - raw_checksum

Else → final_checksum = 0