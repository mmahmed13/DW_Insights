# DW_Insights

This repository provides a Python implementation to download
daily social media reports from an email account using Gmail API, and saves the reports 
in a PostgreSQL database. Additionally, it contains SQL scripts to transform tables and 
extract insights from the data.

## Table of Contents

 - **Getting Started**
 - **Task 1 - Daily Reports**
 - **Task 2 - Facebook Insights**
 
## Getting Started

### Prerequisites

You're going to need:

 - **Python 3+** — In this project, [Python 3.8] was used.
 - **PostgreSQL 10+**
 - **pip** — Comes preinstalled with Python 3.8+
 
 [Python 3.8]: https://www.python.org/downloads/release/python-3813/
 
### Installing
 
 1. Make sure the above mentioned requirements are installed.
 2. Clone this repository.
 3. Run `pip install -r requirements.txt` 
 
## Task 1 - Daily Reports
 
### Running
 1. Import the database schema
 2. Run `python -m backend.main` for reading emails and saving reports
 3. Run queries in `sql/task1` to gather insights

### Approach

The task was approached in the following steps:

#### Attachments Downloading

- For reading emails, I used Gmail API since it is well supported/documented, 
secure and does not involve specifying email password in code (unlike IMAP)
- Instead of simply relying on the email subject, I performed the following checks to identify relevant emails:
	- Email should be from the pre-defined senders (defined in `backend/constants.py`) 
	- Email should not be older than `7` days (defined in `backend/constants.py`)
	- Email contian CSV attachment that includes the word `Historical-Report` 

 #### Schema Design
 
 - Before creating the tables, I did the following:
    - In order to understand each CSV column, I performed analysis using Excel and Pandas
    - I identified entities, their relationships and column data types
    - I created an ERD diagram based on the identifications
 - I decided to save all reactions columns into a single json column called `interactions` as this saves space and 
 reduces clutter
 - I excluded redundant columns from the reports like `Total Interactions`, `Post Created Date`, 
 `Post Created Time` since this information is retrievable from other columns.
 
 #### Reports Saving
 
 - I decided to make use of Pandas dataframe flexibility and preprocess the reports in Python
  before they are saved in the database. This preprocessing includes updating column names, 
  updating unwanted values and removing rows that are missing sponsor names since that cannot be 
  NULL in the database.
 - For saving the results, the biggest dilemma for me was to either use SQLAlchemy's ORM or
 divide the Pandas into datarames similar to the tables and use `df.to_csv`. Eventually, I 
 decided to go with the latter approach since it is more flexible, straight-forward and 
 computationally less expensive.

#### Insights

The following insights can be generated using the scripts in `sql/task1`:
- How many followers did DW Business gain since the upload of video 'X'?
- Which video generated the most negative reactions (sad + angry)? Alternatively, we can
also query positive reactions (like, haha, love + care)
- What were the top 10 most viewed videos of August that were owned?
- What was the most liked video of August for Sports Category pages?

### Challenges
- The biggest challenge was to breakdown the identified entities further. I wanted to separate video data from
post data but could not visualize a meaningful ERD for it.
- Since it was my first time working with Gmail API, I had to constantly go through the documentation.

### Further Ideas
- The Python script can be converted into a service that checks every midnight for a new report in the past day
and downloads the attachment.


## Task 2 - Facebook Insights

### Running
 1. Import the database schema from `sql/schema.sql`
 2. Copy file `dwh_dl_facebook_post_insights.csv` to the repository
 3. Run `python -m backend.task2` for reading emails and saving reports
 4. Run script `sql/task2/extract_insert.sql` to import CSV into table
 5. Run queries in `sql/task2/view_time_insights.sql` to gather insights

### Approach

The task was approached in the following steps:

#### Data Import

Instead of manually creating the table, I wanted to use the CSV headers to generate the table automatically.
For that, I used approaches found [here]. The problem with this approach is that it makes all the columns of type text.
Hence, I used Pandas dataframe again.

[here]: https://stackoverflow.com/a/34884609

#### JSON Extraction and Insert

I wrote a function that iterates over each of the 3 rows, then iterates over all the key value pairs of JSON object. 

### Further Ideas

 - In JSON extraction and insert script, it would be computationally better to perform a bulk insert instead of
 inserting in a loop.