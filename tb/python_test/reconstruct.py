INPUT_FILE  = "/home/sasindu/work/custom_arbitor/custom_arbiter/misc/demod_deintrlv_output.txt"
OUTPUT_FILE = "/home/sasindu/work/custom_arbitor/custom_arbiter/misc/demod_exact_loopback.txt"

BITS_PER_WORD = 32

bit_buffer = []
output_words = []

def llr16_to_bit(llr_hex):
    val = int(llr_hex, 16)

    # convert unsigned 16-bit hex to signed 16-bit integer
    if val & 0x8000:
        val -= 0x10000

    # negative LLR -> bit 1, positive/non-negative -> bit 0
    return 0 if val < 0 else 1

with open(INPUT_FILE, "r") as f:
    for line_num, line in enumerate(f, start=1):
        line = line.strip()
        if not line:
            continue

        if len(line) != 8:
            raise ValueError(f"Line {line_num}: expected 8 hex chars, got '{line}'")

        # line = [upper16][lower16]
        llr_high = line[0:4]
        llr_low  = line[4:8]

        # preserve word order as two 16-bit samples per 32-bit word
        bit_buffer.append(llr16_to_bit(llr_low))
        bit_buffer.append(llr16_to_bit(llr_high))

        while len(bit_buffer) >= BITS_PER_WORD:
            bits = bit_buffer[:BITS_PER_WORD]
            bit_buffer = bit_buffer[BITS_PER_WORD:]

            word = 0
            for i, bit in enumerate(bits):
                word |= (bit << i)

            output_words.append(f"{word:08X}")

if bit_buffer:
    raise ValueError(f"Leftover bits: {len(bit_buffer)}")

with open(OUTPUT_FILE, "w") as f:
    for word in output_words:
        f.write(word + "\n")

print(f"Conversion done. {len(output_words)} words written.")