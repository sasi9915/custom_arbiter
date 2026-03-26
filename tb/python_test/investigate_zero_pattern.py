from pathlib import Path

ROWS = 64
COLS = 64
TOTAL_LLRS = ROWS * COLS

DEM_IN_SV = Path("/home/sasindu/work/custom_arbitor/custom_arbiter/misc/demod_frame_actual_sv.txt")
DEM_IN_VHDL = Path("/home/sasindu/work/custom_arbitor/custom_arbiter/misc/demod_frame_actual.txt")
EXP_OUT = Path("/home/sasindu/work/custom_arbitor/custom_arbiter/misc/deinterleaver_expected_output.txt")
ACT_OUT = Path("/home/sasindu/work/custom_arbitor/custom_arbiter/misc/demod_deintrlv_output.txt")
HYP_OUT = Path("/home/sasindu/work/custom_arbitor/custom_arbiter/misc/deinterleaver_hyp_missing4_output.txt")


def load_hex32_lines(path: Path) -> list[int]:
    vals = []
    for n, line in enumerate(path.read_text().splitlines(), start=1):
        s = line.strip()
        if not s:
            continue
        if len(s) != 8:
            raise ValueError(f"{path}: line {n} is not 8 hex chars: {s}")
        vals.append(int(s, 16))
    return vals


def words_to_llrs(words: list[int]) -> list[int]:
    llrs = []
    for w in words:
        llrs.append(w & 0xFFFF)
        llrs.append((w >> 16) & 0xFFFF)
    return llrs


def llrs_to_ddr_words(llrs: list[int], drop_last_two_lanes: bool) -> list[int]:
    if len(llrs) != TOTAL_LLRS:
        raise ValueError(f"Expected {TOTAL_LLRS} llrs, got {len(llrs)}")

    out = []
    for i in range(0, len(llrs), 8):
        lanes = llrs[i:i + 8]
        if drop_last_two_lanes:
            lanes = lanes[:6] + [0, 0]

        ddr = 0
        for lane_idx, lane_val in enumerate(lanes):
            ddr |= (lane_val & 0xFFFF) << (16 * lane_idx)
        out.append(ddr)
    return out


def deinterleave_readback(ddr_words: list[int]) -> list[int]:
    read_llrs = []
    for row in range(ROWS):
        for col in range(COLS):
            idx = col * COLS + row
            off = idx >> 3
            lane = idx & 0x7
            w = ddr_words[off]
            read_llrs.append((w >> (16 * lane)) & 0xFFFF)
    return read_llrs


def pack_llrs_to_words(read_llrs: list[int]) -> list[int]:
    if len(read_llrs) % 2 != 0:
        raise ValueError("read llrs length must be even")
    out = []
    for i in range(0, len(read_llrs), 2):
        out.append(((read_llrs[i + 1] & 0xFFFF) << 16) | (read_llrs[i] & 0xFFFF))
    return out


def mismatch_count(a: list[int], b: list[int]) -> int:
    n = min(len(a), len(b))
    count = sum(1 for i in range(n) if a[i] != b[i])
    count += abs(len(a) - len(b))
    return count


def zero_ranges_vs_expected(expected: list[int], actual: list[int]) -> list[tuple[int, int]]:
    ranges = []
    in_bad = False
    start = 0

    for i, (e, a) in enumerate(zip(expected, actual), start=1):
        bad = (a == 0) and (e != 0)
        if bad and not in_bad:
            in_bad = True
            start = i
        elif not bad and in_bad:
            ranges.append((start, i - 1))
            in_bad = False

    if in_bad:
        ranges.append((start, len(actual)))

    return ranges


def save_words(path: Path, words: list[int]) -> None:
    path.write_text("".join(f"{w:08x}\n" for w in words))


def main() -> None:
    dem_in = DEM_IN_SV if DEM_IN_SV.exists() else DEM_IN_VHDL
    dem_words = load_hex32_lines(dem_in)
    exp_words = load_hex32_lines(EXP_OUT)
    act_words = load_hex32_lines(ACT_OUT)

    dem_llrs = words_to_llrs(dem_words)
    if len(dem_llrs) != TOTAL_LLRS:
        print(f"demod input trace used               : {dem_in}")
        print(f"demod words/llrs                     : {len(dem_words)}/{len(dem_llrs)}")
        print(f"expected llrs for full frame         : {TOTAL_LLRS}")
        print("input trace is incomplete; rerun simulation and use SV-side trace file")
        return

    ddr_normal = llrs_to_ddr_words(dem_llrs, drop_last_two_lanes=False)
    norm_words = pack_llrs_to_words(deinterleave_readback(ddr_normal))

    ddr_hyp = llrs_to_ddr_words(dem_llrs, drop_last_two_lanes=True)
    hyp_words = pack_llrs_to_words(deinterleave_readback(ddr_hyp))
    save_words(HYP_OUT, hyp_words)

    m_norm = mismatch_count(norm_words, act_words)
    m_hyp = mismatch_count(hyp_words, act_words)
    zero_ranges = zero_ranges_vs_expected(exp_words, act_words)

    print(f"normal_model vs actual mismatches    : {m_norm}")
    print(f"missing4_hypothesis vs actual mismatch: {m_hyp}")
    print(f"demod input trace used               : {dem_in}")
    print(f"hypothesis output written to          : {HYP_OUT}")
    print("zero ranges (line_start-line_end):")
    for s, e in zero_ranges:
        print(f"  {s}-{e} (len={e - s + 1})")


if __name__ == "__main__":
    main()
