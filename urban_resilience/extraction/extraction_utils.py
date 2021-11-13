#!/usr/bin/env python
import csv
import datetime
import json
import os
import shutil

def format_data_to_csv(source_name, source_format):
    """
    Transforms datasets in other formats to CSV data
    (current supported formats: JSON)

    Parameters:
    :param source_name (str): Human-readable name of the source.
    :param source_format (str): Data source format

    Returns:
    bool: Formatting status (False if not succesful)
    """

    if source_format == 'csv':
        return True

    try:
        file_path = f".tmp/{source_name}.{source_format}"
        with open(file_path) as sf:
            data = json.load(sf)

        output_file_path = f".tmp/{source_name}.csv"
        with open(output_file_path, "w+") as out:
            csv_file = csv.writer(out)

            # Write header
            csv_file.writerow([c['id'] for c in data['fields']])

            # Write records
            for r in data['records']:
                csv_file.writerow(r)
        return True
    except Exception as e:
        print(e)
        return False


def create_data_version(filename):
    """
    Creates a data version out of a tmp file

    Parameters:
    :param filename (str): String with name and format

    Returns:
    """

    try:
        tmp_path = f".tmp/{filename}"
        today = datetime.datetime.now().strftime("%Y%m%d")

        # Create source data directories if missing
        version_dir = f"data/{today}"
        latest_dir = f"data/latest"
        if not os.path.exists(version_dir):
            os.makedirs(version_dir)

        if not os.path.exists(latest_dir):
            os.makedirs(latest_dir)

        version_path = f"{version_dir}/{filename}"
        latest_path = f"{latest_dir}/{filename}"

        shutil.copyfile(tmp_path, version_path)
        shutil.copyfile(tmp_path, latest_path)

    except Exception as e:
        print(e)
