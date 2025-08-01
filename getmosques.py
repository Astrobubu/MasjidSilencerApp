import requests
import json
import csv

# Overpass API query for UAE mosques
query = """
[out:json][timeout:120];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](22.5,51.0,26.5,56.5);
  way["amenity"="place_of_worship"]["religion"="muslim"](22.5,51.0,26.5,56.5);
);
out center;
"""

# Make request to Overpass API
url = "https://overpass-api.de/api/interpreter"
response = requests.post(url, data=query)
data = response.json()

# Process and save as CSV
with open('uae_mosques.csv', 'w', newline='', encoding='utf-8') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(['Name', 'Latitude', 'Longitude'])
    
    for i, element in enumerate(data['elements']):
        # Get coordinates
        if element['type'] == 'node':
            lat, lon = element['lat'], element['lon']
        elif 'center' in element:
            lat, lon = element['center']['lat'], element['center']['lon']
        else:
            continue
            
        # Get name
        tags = element.get('tags', {})
        name = (tags.get('name') or 
                tags.get('name:en') or 
                tags.get('name:ar') or 
                f'Unnamed Mosque {i+1}')
        
        writer.writerow([name, lat, lon])

print(f"Saved {len(data['elements'])} mosques to uae_mosques.csv")
            