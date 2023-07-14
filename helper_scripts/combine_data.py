import json

# Load data from the first JSON file
with open("final_data/translated_medical_data_english.json", "r", encoding="utf-8") as file:
    data1 = json.load(file)

# Load data from the second JSON file
with open("final_data/translated_medical_data_german.json", "r", encoding="utf-8") as file:
    data2 = json.load(file)

# Combine the dictionaries
combined_data = {**data1, **data2}

# Write the combined data to a new JSON file
with open("final_data/combined_medical_data.json", "w") as file:
    json.dump(combined_data, file, indent=4)
