import json
import time
from datetime import datetime

import requests

API_KEY = "<APIKEYHERE>"
BASE_URL = "http://localhost"
API_PATH = "/api/v1/points"
HEADERS = {'accept': 'application/json'}


def unix_to_human(unix_time: float) -> str:
    dt = datetime.fromtimestamp(unix_time)
    return dt.strftime('%Y-%m-%d %H:%M:%S')


def check_service_availability():
    while True:
        try:
            response = requests.get(BASE_URL)
            if response.status_code < 400:
                return True
        except requests.RequestException as e:
            print(f"Service check failed: {e}")
        time.sleep(10) # Wait for 10s before retrying


def get_points(start_at, end_at):
    url = f"{BASE_URL}{API_PATH}?api_key={API_KEY}&start_at={start_at}&end_at={end_at}"
    try:
        response = requests.get(url, headers=HEADERS)
        response.raise_for_status()
        return response.json()
    except requests.HTTPError:
        if response.status_code >= 500:
            print(f"GET request failed for range {start_at} to {end_at}, status code: {response.status_code}")
            print("Checking service availability...")
            check_service_availability()

            start_dt = datetime.strptime(start_at, "%Y-%m-%dT%H:%M:%S")
            end_dt = datetime.strptime(end_at, "%Y-%m-%dT%H:%M:%S")
            mid_dt = start_dt + (end_dt - start_dt) / 2
            mid_str = mid_dt.strftime("%Y-%m-%dT%H:%M:%S")

            print(f"Service is available again. Retrying GET request with smaller range: {start_at} to {mid_str} and {mid_str} to {end_at}")

            first_half = get_points(start_at, mid_str)
            second_half = get_points(mid_str, end_at)
            return first_half + second_half
        else:
            response.raise_for_status()


def delete_point(point_id: int | str) -> int:
    url = f"{BASE_URL}{API_PATH}/{point_id}?api_key={API_KEY}"
    response = requests.delete(url, headers={'accept': '*/*'})
    response.raise_for_status()
    return response.status_code


def main():
    year_range = range(2013, 2024)
    ids_to_delete = []

    for year in year_range:
        start_at = f"{year}-01-01T00:00:00"
        end_at = f"{year}-12-31T23:59:59"

        print(f"Getting points for range {start_at} to {end_at}...")

        points = get_points(start_at, end_at)

        print(f"Got {len(points)} points, parsing...")

        with open("deleted_points.json", "a+", encoding="utf-8") as f:
            for point in points:
                latitude = str(point.get('latitude', ''))
                if '54.' in latitude or latitude.startswith('0'):
                    ids_to_delete.append(point['id'])
                    json.dump(point, f)

        print(f"Found {len(ids_to_delete)} bad points in range.")

    deleted_points = 0
    for point_id in ids_to_delete:
        try:
            delete_point(point_id)
            print(f"Deleted point with ID: {point_id}")
            deleted_points += 1
        except requests.HTTPError as e:
            print(f"Failed to delete point with ID: {point_id}, error: {e}")

    print(f"Deleted {deleted_points} points.")


if __name__ == "__main__":
    main()
