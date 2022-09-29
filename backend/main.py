import argparse
import os

from backend.db import write_data
from backend.email import download_reports
from backend.utils import read_csv

if __name__ == "__main__":
    argparser = argparse.ArgumentParser()
    argparser.add_argument('-dp', '--data_path', type=str, default=os.path.join(os.getcwd(), "data"))
    args, unknown = argparser.parse_known_args()

    # download attachments
    file_names = download_reports(args.data_path)
    if len(file_names) == 0:
        print("No new reports downloaded")
        exit(0)
    print(f"Downloaded {len(file_names)} reports")

    # read csv files
    reports = [read_csv(args.data_path, name) for name in file_names]

    write_data(reports)

