import json
import shutil
import os
import re

JSON_PATH = "0.json"
SRC_FILE = "0.mp3"
OUTPUT_DIR = "."


def clean_json(content: str) -> str:
    # удалить // комментарии
    content = re.sub(r"//.*", "", content)

    # удалить /* */ комментарии
    content = re.sub(r"/\*.*?\*/", "", content, flags=re.DOTALL)

    # удалить # комментарии
    content = re.sub(r"#.*", "", content)

    # заменить preload(...) на строку (валидный JSON)
    content = re.sub(r'preload\([^)]+\)', '"dummy.mp3"', content)

    # убрать висячие запятые перед } или ]
    content = re.sub(r",\s*([}\]])", r"\1", content)

    return content


def load_json_with_comments(path):
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    content = clean_json(content)

    if not content.strip():
        raise ValueError("Файл пуст после очистки")

    return json.loads(content)


def main():
    if not os.path.isfile(SRC_FILE):
        raise FileNotFoundError(f"Не найден файл: {SRC_FILE}")

    os.makedirs(OUTPUT_DIR, exist_ok=True)

    data = load_json_with_comments(JSON_PATH)

    for key in data.keys():
        filename = f"{key}.mp3"
        dst_path = os.path.join(OUTPUT_DIR, filename)

        shutil.copyfile(SRC_FILE, dst_path)
        print(f"Создан: {dst_path}")


if __name__ == "__main__":
    main()