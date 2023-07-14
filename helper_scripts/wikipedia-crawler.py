import requests
import json
from bs4 import BeautifulSoup

url = "https://en.wikipedia.org/wiki/Glossary_of_medicine"
response = requests.get(url)
html_content = response.content

soup = BeautifulSoup(html_content, "html.parser")

div_mw_parser_output = soup.find("div", class_="mw-parser-output")
ul_tags = div_mw_parser_output.find_all("li")

payload = {}
headers = {
    'Cookie': 'GeoIP=DE:BY:Nuremberg:49.45:11.06:v4; WMF-Last-Access-Global=25-Jun-2023; NetworkProbeLimit=0.001; WMF-DP=9c6; WMF-Last-Access=25-Jun-2023'
}

extracted_data = {}
count = 0
for ul_tag in ul_tags:
    a_tags = ul_tag.find_all("a")

    for a_tag in a_tags:
        href = a_tag.get("href")
        title = a_tag.get("title")

        if href is not None and not href.startswith("#"):
            last_part = href.split("/")[-1]
            api_url = f"https://en.wikipedia.org/api/rest_v1/page/summary/{last_part}"

            response = requests.get(api_url, headers=headers)
            api_data = response.json()
            print(href)
            print(count)
            count = count + 1


            try:
                description = api_data["description"]
            except KeyError:
                try:
                    description = api_data["extract"]
                except KeyError:
                    print("Both 'description' and 'extract' not found for:", href)
                    continue

            extracted_data[title] = {"Definition": description}

# Write the extracted data to a JSON file
with open("extracted_data_wiki.json", "w") as file:
    json.dump(extracted_data, file, indent=4)
