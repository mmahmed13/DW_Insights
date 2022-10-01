import uuid

import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.dialects.postgresql import insert

from backend.constants import POSTGRES_USERNAME, POSTGRES_PASS, POSTGRES_ADDRESS, POSTGRES_PORT, POSTGRES_DATABASE


def get_engine(schema_name):
    """
    Gets Postgres engine
    :return:
    """
    engine = create_engine(f'postgresql://{POSTGRES_USERNAME}:{POSTGRES_PASS}@{POSTGRES_ADDRESS}:{POSTGRES_PORT}/'
                           f'{POSTGRES_DATABASE}',
                           connect_args={'options': '-csearch_path={}'.format(f'{schema_name}')})
    return engine


def update_insert(table, conn, keys, data_iter):
    """
    Callback function to perform update insert if primary key is available
    :param table: table name
    :param conn: database connection
    :param keys: primary keys
    :param data_iter: iterator
    :return:
    """
    data = [dict(zip(keys, row)) for row in data_iter]

    insert_statement = insert(table.table).values(data)
    upsert_statement = insert_statement.on_conflict_do_update(
        constraint=f"{table.table.name}_pkey",
        set_={c.key: c for c in insert_statement.excluded},
    )
    conn.execute(upsert_statement)


def write_reports_to_db(schema_name, reports):
    page_df, sponsor_df, post_df, post_statistics_df = get_tables_df(reports)

    try:
        engine = get_engine(schema_name)
        with engine.connect().execution_options(autocommit=True) as conn:
            page_df.to_sql('page', con=conn, if_exists='append', index=False, method=update_insert)
            sponsor_df.to_sql('sponsor', con=conn, if_exists='append', index=False, method=update_insert)
            post_df.to_sql('post', con=conn, if_exists='append', index=False, method=update_insert)
            post_statistics_df.to_sql('post_statistics', con=conn, if_exists='append', index=False)
    except Exception:
        return False
    return True


def get_tables_df(reports):
    """
    Gets each table data as a dataframe
    :param reports: list of reports
    :return: A tuple of dataframes for every table
    """
    pages = []
    sponsors = []
    posts = []
    posts_statistics = []

    for report in reports:
        # extract pages dataframe
        page_df = report[['page_name', 'user_name', 'facebook_id', 'page_category', 'page_admin_top_country',
                          'page_description', 'page_created']]
        pages.append(page_df)

        # extract sponsors dataframe
        sponsor_df = report[['sponsor_id', 'sponsor_name', 'sponsor_category']]
        sponsor_df = sponsor_df[~sponsor_df['sponsor_id'].isnull() & ~sponsor_df['sponsor_name'].isnull()]
        sponsors.append(sponsor_df)

        # extract posts dataframe
        post_df = report[['likes_at_posting', 'followers_at_posting', 'post_created', 'facebook_id',
                          'video_share_status', 'is_video_owner?', 'video_length', 'url', 'message', 'link',
                          'final_link', 'sponsor_id']]
        posts.append(post_df)

        # extract post statistics dataframe
        posts_statistics_df = report[['timestamp', 'interactions', 'post_views', 'total_views',
                                      'total_views_for_all_crossposts', 'post_created', 'facebook_id']]
        posts_statistics.append(posts_statistics_df)

    page_df = pd.concat(pages).drop_duplicates('facebook_id')

    sponsor_df = pd.concat(sponsors).drop_duplicates('sponsor_id')

    post_df = pd.concat(posts).drop_duplicates(['post_created', 'facebook_id'], keep='last')
    post_df = post_df.rename(columns={"facebook_id": "page_facebook_id"})

    posts_statistics_df = pd.concat(posts_statistics)
    posts_statistics_df = posts_statistics_df.rename(columns={"facebook_id": "page_facebook_id"})
    posts_statistics_df['statistics_id'] = posts_statistics_df.apply(lambda _: uuid.uuid4(), axis=1)

    return page_df, sponsor_df, post_df, posts_statistics_df