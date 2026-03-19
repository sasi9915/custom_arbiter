ROWS = 64
COLS = 64
BASE_ADDR = 1000  # same as RTL

output_file = "ref_read_addresses.txt"

with open(output_file, "w") as f:
    for row in range(ROWS):
        for col in range(COLS):

            # same as RTL
            addr_index = col * COLS + row

            # word index (128-bit aligned)
            ddr_offset = addr_index // 16

            # actual DDR address
            ddr_address = BASE_ADDR + ddr_offset * 16

            # which 16-bit inside 128-bit word
            segment = addr_index % 8

            f.write(f"{ddr_address:08x}\n")

print("Read address file generated!")