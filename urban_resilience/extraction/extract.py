#!/usr/bin/env python
import yaml

from urban_resilience.extraction.extract_source import extract_source
from urban_resilience.extraction.extraction_utils import format_data_to_csv, create_data_version

def extract():
    """
    Extracts a list of datasets indicated by the configuration
    found in sources YAML.
    """
    with open('urban_resilience/configs/sources.yaml') as fh:
        sources_data = yaml.safe_load(fh)

    for source_name in sources_data.keys():
        resource_id = sources_data[source_name]['resource_id']
        source_format = sources_data[source_name]['format']
        print("Extracting")
        extract_source(
            source_name,
            resource_id,
            source_format
        )

        filename = f"{source_name}.{source_format}"
        print("Formatting file to CSV")
        format_data_to_csv(source_name, source_format)

        print("Creating data version")
        create_data_version(filename)

if __name__ == "__main__":
    extract()
