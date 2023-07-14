from deep_translator import GoogleTranslator
import json

# Specify the file paths
input_file_path = "combined_medical_data.json"
output_file_path = "translated_medical_data.json"

# Read the JSON input file
with open(input_file_path, 'r', encoding="utf-8") as file:
    json_data = json.load(file)

# Open the output JSON file for writing
with open(output_file_path, 'w', encoding="utf-8") as file:
    count = 0
    unable_count = 0

    # Iterate over the JSON data
    for key, value in json_data.items():
        try:
            translated_key = GoogleTranslator(source='auto', target='de').translate(key)
            translated_value = GoogleTranslator(source='auto', target='de').translate(value["Definition"])

            # Create a dictionary with the translated data
            translated_data = {translated_key: {"Definition": translated_value}}

            # Write the translated data to the output file
            json.dump(translated_data, file, indent=4, ensure_ascii=False)
            file.write('\n')  # Add a newline after each translated entry

            print(translated_key)
            print("$$$$$$$$$$$$$")
            print(2078 - count)
            print("$$$$$$$$$$$$$")
            count += 1
        except:
            print("unable")
            print("%%%%%%%%%%%%%")
            print(unable_count)
            print("%%%%%%%%%%%%%")
            print("------------------")
            unable_count += 1

print("Translation completed. Translated data saved to:", output_file_path)
