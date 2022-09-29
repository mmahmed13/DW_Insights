import argparse
import os

from backend.email import download_reports

if __name__ == "__main__":
    argparser = argparse.ArgumentParser()
    argparser.add_argument('-dp', '--data_path', type=str, default=os.path.join(os.getcwd(), "data"))
    args, unknown = argparser.parse_known_args()

    file_names = download_reports(args.data_path)