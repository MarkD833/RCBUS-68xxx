import sys
import os
import re

# replace 2 spaces and a 6 digit address with 00 and the 6 digit address
# Regex breakdown:
# ^     : Matches the start of a line
# [ ]{2}: Matches exactly two spaces
# (\d)  : Matches a digit and captures it in 'group 1'
pattern1 = r'^[ ]{2}(\d)'
replacement1 = r'00\1'

# remove the sequence of a TAB + 3 dots to leave a blank line
# Regex breakdown:
# \t   : Matches a tab
# \.{3}: Matches exactly three literal dots
pattern2 = r'\t\.{3}'
replacement2 = '\n'

#
# MAIN script starts here
#
if __name__ == "__main__":
    # sys.argv[0] is the script name itself
    # sys.argv[1] is the name of the GCC listig produced by objdump
    # sys.argv[2] is the address of the first instruction to execute
    if len(sys.argv) < 3:
        print("Usage: python gcc2easy.py <filename>,<start address in hex>")
        sys.exit(1)
        
    # get the name of the input file and create a temporary output filename
    input_file = sys.argv[1]
    output_file = os.path.splitext(sys.argv[1])[0]+'.l68'
   
    try:
        with open(input_file, 'r') as f_in, open(output_file, 'w') as f_out:
            # insert the addres of the first instruction to execute
            f_out.write(sys.argv[2].zfill(8) + "  Starting Address")
            
            for line in f_in:
                # Apply the first replacement
                line = re.sub(pattern1, replacement1, line)

                # Apply the second replacement
                line = re.sub(pattern2, replacement2, line)

                f_out.write(line)

        print(f"Success! Processed file saved as: {output_file}")
        
    except FileNotFoundError:
        print("Error: The input file was not found.")
