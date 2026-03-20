ROWS = 64
COLS = 64

# read input data (32-bit words) from file, convert from hex to int
def read_input(file):
    data = []
    with open(file, "r") as f:
        for line in f:
            data.append(int(line.strip(), 16))
    return data


# pack 32-bit words into 128-bit words 

def pack_128(data32):
    packed = []
    for i in range(0, len(data32), 4):
        w = 0
        for j in range(4):
            w |= data32[i + j] << (j * 32)
        packed.append(w)
    return packed


# ddr write (model of AXI write, but just store in list for now)
def write_ddr(packed):
    return packed[:]   # list = memory



# funtion to read from ddr in 16-bit chunks, simulating the deinterleaver's read pattern
def read_ddr(ddr):
    out16 = []

    for row in range(ROWS):
        for col in range(COLS):

            addr = col * COLS + row

            word_index = addr >> 4      # /16
            segment    = addr & 0x7     # %8

            word = ddr[word_index]

            val16 = (word >> (segment * 16)) & 0xFFFF

            out16.append(val16)

    return out16

# pack 16-bit values back into 32-bit words for output
def pack_32(data16):
    out = []
    for i in range(0, len(data16), 2):
        w = (data16[i+1] << 16) | data16[i]
        out.append(w)
    return out



def run(in_file, out_file):
    d32 = read_input(in_file)
    p128 = pack_128(d32)
    ddr = write_ddr(p128)

    d16 = read_ddr(ddr)
    out32 = pack_32(d16)

    with open(out_file, "w") as f:
        for w in out32:
            f.write(f"{w:08x}\n")

    print(" PERFECT RTL MATCH MODEL")


run("input_data_hex.txt", "output_model.txt")