INPUT_FILE  = "/home/sasindu/work/custom_arbitor/custom_arbiter/misc/interlever_loopback_debug.txt"
OUTPUT_FILE = "/home/sasindu/work/custom_arbitor/custom_arbiter/misc/demod_frame_expected.txt"

def bit_to_llr16(bit_val):
    return 0x7FFF if bit_val else 0x8001

expected_words = []

with open(INPUT_FILE, "r") as f:
    for line_num, line in enumerate(f, start=1):
        word_hex = line.strip()
        if not word_hex:
            continue

        if len(word_hex) != 8:
            print(f"Skipping line {line_num}: invalid word '{word_hex}'")
            continue

        word = int(word_hex, 16)

        # LSB-first bit extraction
        bits = [(word >> i) & 1 for i in range(32)]

        # 32 bits -> 16 demod/deinterleaver-input words
        for pair_idx in range(16):
            b0 = bits[2 * pair_idx]
            b1 = bits[2 * pair_idx + 1]

            exp_word = (bit_to_llr16(b1) << 16) | bit_to_llr16(b0)
            expected_words.append(f"{exp_word:08X}")

with open(OUTPUT_FILE, "w") as f:
    for w in expected_words:
        f.write(w + "\n")

print(f"Done. Wrote {len(expected_words)} expected words to {OUTPUT_FILE}")