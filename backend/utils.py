import os
import pandas as pd


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
    file_path = os.path.join(path, file_name)
    data = pd.read_csv(file_path, delimiter=',')
    return data