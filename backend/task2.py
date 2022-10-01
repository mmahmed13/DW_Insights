import argparse

import pandas as pd
from sqlalchemy import create_engine

from backend.db import get_engine

if __name__ == "__main__":
    argparser = argparse.ArgumentParser()
    argparser.add_argument('-sn', '--schema_name', type=str, default='fb_insights')
    argparser.add_argument('-tn', '--table_name', type=str, default='insights')
    args, unknown = argparser.parse_known_args()

    engine = get_engine(args.schema_name)
    df=pd.read_csv('dwh_dl_facebook_post_insights.csv')
    df.to_sql(args.table_name, engine, index=False)
