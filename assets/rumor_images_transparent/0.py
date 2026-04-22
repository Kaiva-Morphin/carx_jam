import os
import shutil

SRC = "0.png"
OUT = "."

FILES = [
    "original_board",
    "tape",
    "break_in",
    "sneakers",
    "bio_1",
    "missing_bottle",
    "mail",
    "cig",
    "safe",
    "documents",
    "bio_2",
    "letter",
    "drawings",
    "passport",
    "flask",
    "photo",
]

os.makedirs(OUT, exist_ok=True)

for name in FILES:
    dst = os.path.join(OUT, f"{name}.png")
    shutil.copyfile(SRC, dst)
    print("created:", dst)