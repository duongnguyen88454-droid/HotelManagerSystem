# -*- coding: utf-8 -*-
target_path = r"d:\Learn\College\Lap trinh web\HotelManagerSystem\docs\02_Web_Application\BaoCao_ThucThi\02_BaoCao_KienTruc\BaoCao_ThucThi_GiaiDoan_3.md"

with open(target_path, "r", encoding="utf-8") as f:
    text = f.read()

# Replace tab followed by 'o$' with '\to$'
text = text.replace("$\to$", " -> ")
text = text.replace("$\to$", " -> ")
text = text.replace("$\to$", " -> ")
# Also handle any literal tab + o$
text = text.replace("$\to$", " -> ")
text = text.replace("$\to$", " -> ")
text = text.replace("$\to$", " -> ")
text = text.replace("$\to$", " -> ")
# specifically handle $\t
text = text.replace("$\t" + "o$", " -> ")

with open(target_path, "w", encoding="utf-8") as f:
    f.write(text)

print("Fixed arrows.")
