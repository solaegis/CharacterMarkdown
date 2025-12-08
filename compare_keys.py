import re

def extract_keys(filename):
    keys = set()
    with open(filename, 'r') as f:
        for line in f:
            # Match lines like | **Attribute** | **Value** | (header) -> skip
            # Match lines like | **Level** | 50 | (row) -> extract Level
            # Regex to find **Key**
            match = re.search(r'\|\s*\*\*(.*?)\*\*\s*\|', line)
            if match:
                key = match.group(1).strip()
                # Exclude header rows if they match the pattern (Start with Attribute, Category, Set, Slot)
                if key not in ['Attribute', 'Category', 'Ability', 'Resistance', 'Damage Type', 'Healing', 'Set', 'Slot', 'Total', '1']:
                    keys.add(key)
    return keys

masisi_keys = extract_keys('masisi_head.md')
stoirmgheal_keys = extract_keys('stoirmgheal_head.md')

print("Keys in Masisi but not in Stoirmgheal:")
for k in sorted(masisi_keys - stoirmgheal_keys):
    print(f"- {k}")

print("\nKeys in Stoirmgheal but not in Masisi:")
for k in sorted(stoirmgheal_keys - masisi_keys):
    print(f"- {k}")
