exp_file = "/home/sasindu/work/custom_arbitor/custom_arbiter/misc/demod_frame_expected.txt"
act_file = "/home/sasindu/work/custom_arbitor/custom_arbiter/misc/demod_frame_actual.txt"

with open(exp_file) as f:
    exp = [x.strip().lower() for x in f if x.strip()]

with open(act_file) as f:
    act = [x.strip().lower() for x in f if x.strip()]

print("Expected count:", len(exp))
print("Actual count  :", len(act))

min_len = min(len(exp), len(act))

mismatch_found = False
for i in range(min_len):
    if exp[i] != act[i]:
        print(f"Mismatch at index {i}")
        print(f"  expected = {exp[i]}")
        print(f"  actual   = {act[i]}")
        mismatch_found = True
        break

if not mismatch_found:
    if len(exp) == len(act):
        print("All words match perfectly.")
    else:
        print("Data matches up to min length, but file lengths differ.")