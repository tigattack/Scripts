"""Get remap data from Celtic Tuning"""
import sys

import requests
from bs4 import BeautifulSoup

# Usage notes:
# python3 celtic.py AB12CDE

# Script only supports returning data for a "stage 1" map.
# For vehicles with supported "stage 2" maps, "economy" maps, etc., only the stage 1 result
#  will be returned.
# This isn't a technical limitation, simply a 'lack of fucks given' limitation on my part.

# Resources:
# https://realpython.com/beautiful-soup-web-scraper-python

VRN = sys.argv[1]
BASE_URL = 'https://www.celtictuning.co.uk'
SEARCH_URL = BASE_URL + '/component/ctvc/search?dvla=' + VRN

search_response = requests.get(
  SEARCH_URL,
  timeout=5,
  allow_redirects=False
)

redirect_url = search_response.headers['Location']

if redirect_url == '/component/ctvc/#t3-content':
    print(
f"""A vehicle with registration "{VRN}" could not be found.
Possible causes:
- Incorrect registration.
- Celtic Tuning does not have a tune for this vehicle.
- Celtic Tuning could not be identify the vehicle based on
  the information provided by the DVLA."""
    )
    sys.exit()

data_url = BASE_URL + redirect_url

data_response = requests.get(
  data_url,
  timeout=5
)

soup = BeautifulSoup(data_response.content, "html.parser")

# Parse remap data
map_data_divs = soup.find_all("div", class_="ctvc_gauge_text")

result_texts = []
for element in map_data_divs:
    element_text = element.find("h5")
    result_texts.append(element_text.text.strip())

stock_power   = result_texts[0]
mapped_power  = result_texts[1]
power_diff    = result_texts[2].lstrip('+')
stock_torque  = result_texts[3]
mapped_torque = result_texts[4]
torque_diff   = result_texts[5].lstrip('+')

# Parse vehicle title
vehicle_title_element = soup.find(id='ctvc-title')
vehicle_title = vehicle_title_element.text.strip().replace('\n', ' ').replace('  ', '')

# Parse vehicle information table
vehicle_data = {}
vehicle_data_table = soup.find('ul', attrs={'class':'ctvs_list'})

rows = vehicle_data_table.find_all('li')
for row in rows:
    row_text = row.text.strip().replace('\n', ' ').replace('  ', '')
    row_text = row_text.split(':')
    vehicle_data.update({row_text[0]: row_text[1]})

vehicle_data_pretty = ''
for key,value in vehicle_data.items():
    vehicle_data_pretty += f'{key}: {value}\n'

vehicle_data_pretty = vehicle_data_pretty.strip()

# Return data
print(f"""Found vehicle: {vehicle_title}

== VEHICLE DATA ==
{vehicle_data_pretty.strip()}

== REMAP DATA ==
Stock power:  {stock_power} BHP
Mapped power: {mapped_power} BHP

Stock torque:  {stock_torque} lb/ft
Mapped torque: {mapped_torque} lb/ft

Power increase:  {power_diff} BHP
Torque increase: {torque_diff} lb/ft""")
