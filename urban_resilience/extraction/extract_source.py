#!/usr/bin/env python
import requests

def extract_source(source_name, resource_id, source_format):
    """
    Sends a GET request to ADIP CKAN catalog and saves successful
    response in a file with the same source format (ideally, a JSON file).

    Parameters:
    :param source_name (str): Human-readable name of the source.
    :param resource_id (str): Resource ID as to be found in the CKAN datastore.
    :param source_format (str): Format to download and save (CSV, JSON or TSV).

    Returns:
    bool: Extraction status (False if not succesful)
    """

    print(source_name)

    try:
        source_url = ("https://datos.cdmx.gob.mx/datastore/dump/"
                      f"{resource_id}?format={source_format}")

        response = requests.get(source_url)
        response.raise_for_status()

        file_name = f".tmp/{source_name}.{source_format}"
        output_file = open(file_name, 'w')
        output_file.write(response.text)
        return True
    except Exception as e:
        print(e)
        return False

