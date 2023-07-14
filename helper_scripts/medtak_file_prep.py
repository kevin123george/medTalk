import json

# Step 1: Read the JSON file
with open('final_data/combined_medical_data.json', 'r', encoding='utf-8') as file:
    data = json.load(file)

# Step 2: Convert the data to lowercase
lowercase_data = {}
for key, value in data.items():
    lowercase_key = key.lower()
    lowercase_value = {k: v.lower() if isinstance(v, str) else v for k, v in value.items()}
    lowercase_data[lowercase_key] = lowercase_value

# Step 3: Write the lowercase data to a new JSON file
with open('final_data/combined_medical_data_lower.json', 'w', encoding='utf-8') as file:
    json.dump(lowercase_data, file, ensure_ascii=False, indent=4)
