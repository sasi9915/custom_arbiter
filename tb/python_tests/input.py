INPUT_WORDS = 2048

with open("input_data_hex.txt", "w") as f:
    for i in range(INPUT_WORDS):
        f.write(f"{i:08x}\n")

print("Input data generated in input_data.txt")