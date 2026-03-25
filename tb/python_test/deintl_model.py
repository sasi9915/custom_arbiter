INPUT_FILE  = "/home/sasindu/work/custom_arbitor/custom_arbiter/misc/demod_frame_actual.txt"
OUTPUT_FILE = "/home/sasindu/work/custom_arbitor/custom_arbiter/misc/deinterleaver_expected_output.txt"

ROWS = 64
COLS = 64
TOTAL_LLRS = ROWS * COLS  # 4096


def load_input_llrs(path):
    """
    Read 32-bit deinterleaver input words.
    Each input word contains:
        lower 16 bits = first LLR
        upper 16 bits = second LLR
    This matches the stream you already captured at deinterleaver input.
    """
    llrs = []

    with open(path, "r") as f:
        for line_num, line in enumerate(f, start=1):
            word_hex = line.strip().split()[0]
            if not word_hex:
                continue
            if len(word_hex) != 8:
                raise ValueError(f"Line {line_num}: expected 8 hex chars, got '{word_hex}'")

            word = int(word_hex, 16)

            llr0 = word & 0xFFFF
            llr1 = (word >> 16) & 0xFFFF

            llrs.append(llr0)
            llrs.append(llr1)

    return llrs


def build_ddr_words_from_input_llrs(llrs):
    """
    Match the RTL write-side packing.

    The RTL stores incoming 32-bit words into sr_frame_data at:
        r_byte_idx * 32 + 31 downto r_byte_idx * 32
    so inside each 128-bit DDR word, the lane order is:

        lane0 = first input word lower16
        lane1 = first input word upper16
        lane2 = second input word lower16
        lane3 = second input word upper16
        lane4 = third input word lower16
        lane5 = third input word upper16
        lane6 = fourth input word lower16
        lane7 = fourth input word upper16

    i.e. 8 x 16-bit lanes per 128-bit word.
    """
    if len(llrs) != TOTAL_LLRS:
        raise ValueError(f"Expected {TOTAL_LLRS} LLRs, got {len(llrs)}")

    ddr_words = []
    for base in range(0, len(llrs), 8):
        lanes = llrs[base:base + 8]
        if len(lanes) != 8:
            raise ValueError("LLR stream is not a multiple of 8 lanes")

        ddr_word = 0
        for lane_idx, lane_val in enumerate(lanes):
            ddr_word |= (lane_val & 0xFFFF) << (16 * lane_idx)

        ddr_words.append(ddr_word)

    return ddr_words


def rtl_readback_llr_stream(ddr_words):
    """
    Match the RTL read-side traversal.

    RTL logical index:
        index = column * 64 + row

    with column advancing first, then row. That means output LLR order is:
        for row in 0..63:
            for col in 0..63:
                index = col * 64 + row

    Then:
        ddr_offset = index >> 4
        lane       = index & 0x7   (via fifo_dout / low 3 bits)
    """
    out_llrs = []

    for row in range(ROWS):
        for col in range(COLS):
            index = col * COLS + row   # matches RTL: column * C_COLS + row

            ddr_offset = index >> 3    # 8 lanes per 128-bit DDR word
            lane = index & 0x7

            ddr_word = ddr_words[ddr_offset]
            llr = (ddr_word >> (16 * lane)) & 0xFFFF
            out_llrs.append(llr)

    return out_llrs


def pack_output_words(read_llrs):
    """
    Match the RTL output packing:

    first read goes into r_out_data(15 downto 0)
    second read becomes upper16 and is concatenated with previous lower16

    final output word:
        [31:16] = second read
        [15:0]  = first read
    """
    if len(read_llrs) % 2 != 0:
        raise ValueError("Read LLR stream length must be even")

    out_words = []
    for i in range(0, len(read_llrs), 2):
        first_llr = read_llrs[i]
        second_llr = read_llrs[i + 1]
        word = ((second_llr & 0xFFFF) << 16) | (first_llr & 0xFFFF)
        out_words.append(f"{word:08x}")

    return out_words


def main():
    input_llrs = load_input_llrs(INPUT_FILE)
    print(f"Loaded {len(input_llrs)} input LLRs")

    ddr_words = build_ddr_words_from_input_llrs(input_llrs)
    print(f"Built {len(ddr_words)} DDR 128-bit words")

    read_llrs = rtl_readback_llr_stream(ddr_words)
    print(f"Generated {len(read_llrs)} readback LLRs")

    output_words = pack_output_words(read_llrs)
    print(f"Generated {len(output_words)} expected output words")

    with open(OUTPUT_FILE, "w") as f:
        for w in output_words:
            f.write(w + "\n")

    print(f"Done. Wrote expected deinterleaver output to: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()