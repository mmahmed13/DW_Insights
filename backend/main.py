import argparse
import os
import shutil
import time

from backend.db import write_reports_to_db
from backend.email import download_reports
from backend.utils import read_csv, preprocess_reports

if __name__ == "__main__":
    argparser = argparse.ArgumentParser()
    argparser.add_argument('-dp', '--data_path', type=str, default=os.path.join(os.getcwd(), "data"))
    argparser.add_argument('-sn', '--schema_name', type=str, default='daily_reports')
    args, unknown = argparser.parse_known_args()

    # download attachments
    print("Downloading latest reports...")
    file_names = download_reports(args.data_path)
    if len(file_names) == 0:
        print("No new reports downloaded")
        exit(0)
    print(f"Downloaded {len(file_names)} reports")

    # read csv files
    reports = [read_csv(args.data_path, name) for name in file_names]

    reports_updated = preprocess_reports(reports, file_names)

    start_time = time.time()
    print("Writing reports to database...")
    success = write_reports_to_db(args.schema_name, reports_updated)
    print(f"Elapsed time for reports saving: {time.time() - start_time}")

    if success:
        print("Reports saved successfully. Deleting files...")
        shutil.rmtree(args.data_path)

    print("Program finished!")
