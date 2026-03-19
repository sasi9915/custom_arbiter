# ==============================
# PARAMETERS (same as VHDL)
# ==============================
ROWS = 64
COLS = 64
BURST_LEN = 8   # 8 x 128-bit per burst

# ==============================
# STEP 1: INPUT (32-bit words)
# ==============================
def read_input_file(file):
    data32 = []
    with open(file, "r") as f:
        for line in f:
            line = line.strip()
            if len(line) == 8:
                data32.append(int(line, 16))
    return data32


# ==============================
# STEP 2: PACK 32 → 128 bit
# ==============================
def pack_128(data32):
    packed = []
    temp = 0
    count = 0

    for word in data32:
        temp |= (word << (count * 32))
        count += 1

        if count == 4:
            packed.append(temp)
            temp = 0
            count = 0

    return packed  # list of 128-bit ints


# ==============================
# STEP 3: DDR WRITE (linear)
# ==============================
def write_ddr(packed_128):
    ddr = {}

    for addr, word in enumerate(packed_128):
        ddr[addr] = word

    return ddr


# ==============================
# STEP 4: DDR READ (transpose)
# ==============================
def generate_read_addresses():
    addresses = []

    for row in range(ROWS):
        for col in range(COLS):
            addr = col * COLS + row   # <-- KEY (same as VHDL)
            addresses.append(addr)

    return addresses


# ==============================
# STEP 5: EXTRACT 16-bit pieces
# ==============================
def extract_16bit(ddr, read_addrs):
    extracted = []

    for addr in read_addrs:
        word_index = addr // 8          # which 128-bit word
        segment = addr % 8              # which 16-bit inside word

        word128 = ddr[word_index]

        # extract 16-bit chunk
        val16 = (word128 >> (segment * 16)) & 0xFFFF
        extracted.append(val16)

    return extracted


# ==============================
# STEP 6: PACK 16 → 32 bit output
# ==============================
def pack_32(data16):
    output32 = []

    for i in range(0, len(data16), 2):
        b0 = data16[i]
        b1 = data16[i+1]

        word32 = (b1 << 16) | b0
        output32.append(word32)

    return output32


# ==============================
# STEP 7: WRITE OUTPUT FILE
# ==============================
def write_output(file, data32):
    with open(file, "w") as f:
        for word in data32:
            f.write(f"{word:08x}\n")


# ==============================
# MAIN FLOW (matches RTL pipeline)
# ==============================
def run_model(input_file, output_file):

    # AXIS input
    data32 = read_input_file(input_file)

    # Pack to 128-bit (like sr_frame_data)
    packed128 = pack_128(data32)

    # Write to DDR
    ddr = write_ddr(packed128)

    # Generate transpose addresses
    read_addrs = generate_read_addresses()

    # Extract 16-bit chunks
    data16 = extract_16bit(ddr, read_addrs)

    # Repack to 32-bit
    output32 = pack_32(data16)

    # Save
    write_output(output_file, output32)

    print("Deinterleaving (RTL-like) complete!")


# ==============================
# RUN
# ==============================
run_model("input_data_hex.txt", "output.txt")