import copy
import json
import os
import pandas as pd
import numpy as np
import datetime
import traceback

import pytz

from backend import constants


def write_csv(path, file_name, data):
    """
    Writes file to path
    :param path: path to directory
    :param file_name: file name including extension
    :param data: data to write
    """
    if not os.path.isdir(path):
        os.makedirs(path)
    with open(os.path.join(path, file_name), 'wb') as f:
        f.write(data)


def read_csv(path, file_name):
    """
    Read csv from path with file name
    :param path: path of the file
    :param file_name: name of the file
    :return: dataframe
    """
    file_path = os.path.join(path, file_name)
    data = pd.read_csv(file_path, delimiter=',')
    return data


def get_datetime_from_filename(name):
    """
    Extracts datetime from csv file name. Used for tracking post statistics
    """
    try:
        datetime_li = name.split(constants.ATTACHMENT_NAME_SUBSTR)[0].rstrip('-').split('-')
        datetime_ints = [int(i) for i in datetime_li[:-1]]

        dt = datetime.datetime(datetime_ints[0], datetime_ints[1], datetime_ints[2], datetime_ints[3], datetime_ints[4], datetime_ints[5], 0)
        datetime_str = str(dt) + f' {datetime_li[-1]}'
    except Exception:
        print(f"Error occurred with file {name}")
        print(traceback.format_exc())
        datetime_str = str(datetime.datetime.now(pytz.utc))

    return datetime_str


def preprocess_reports(reports, file_names):
    """
    Prepares reports by updating dataframe columns and updating unwanted entries
    :param reports: list of dataframe
    :param file_names: list of file names
    :return: updated dataframes list
    """
    reports_updated = copy.deepcopy(reports)
    for idx, report in enumerate(reports_updated):
        # change column names to lower case and remove spaces
        report.columns = report.columns.str.lower()
        report.columns = report.columns.str.replace(' ', '_')

        # change - to nan
        report.loc[report['is_video_owner?'] == '-', 'is_video_owner?'] = np.nan

        # merge number of reactions and comments as a json
        interactions_cols = ['likes', 'comments', 'shares', 'love', 'wow', 'haha', 'sad', 'angry', 'care']
        interactions_df = report[interactions_cols]
        interactions_json = interactions_df.to_json(orient='records')
        report['interactions'] = json.loads(interactions_json)
        report['interactions'] = report['interactions'].apply(json.dumps)
        report = report.drop(columns=interactions_cols)

        # add report timestamp to df
        datetime_str = get_datetime_from_filename(file_names[idx])
        report['timestamp'] = datetime_str

        # remove rows where sponsor name is missing
        report = report.drop(report[~report['sponsor_id'].isnull() & report['sponsor_name'].isnull()].index)
        reports_updated[idx] = report

    return reports_updated