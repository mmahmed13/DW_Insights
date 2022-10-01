import base64

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

import os

from backend import constants
from backend.utils import write_csv


def get_service():
    """
    Authenticates gmail account and returns service
    """
    creds = None
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', constants.SCOPES)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', constants.SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.json', 'w') as token:
            token.write(creds.to_json())

    service = build('gmail', 'v1', credentials=creds)

    return service


def download_reports(path):
    """
    Filter emails, downloads valid attachments and returns the file names
    :param path: path to download the reports
    """
    file_names = []
    try:
        # get email service
        service = get_service()

        # filter relevant emails
        email_ids = service.users().messages().list(userId='me', labelIds=['INBOX'],
                                                 q=f'newer_than:{constants.EMAIL_DAYS_FILTER}d has:attachment '
                                                   f'from:{constants.AUTH_EMAIL_SENDER}').execute().get('messages', [])

        # download valid attachments
        for email_id in email_ids:
            email = service.users().messages().get(userId='me', id=email_id['id']).execute()
            for part in email['payload']['parts']:
                # validate attachment
                if part['mimeType'] == 'text/csv' and constants.ATTACHMENT_NAME_SUBSTR in part['filename']:
                    att_id = part['body']['attachmentId']
                    file_name = part['filename']

                    att = service.users().messages().attachments().get(userId='me', messageId=email['id'],
                                                                       id=att_id).execute()
                    data = att.get('data')
                    file_data = base64.urlsafe_b64decode(data.encode('UTF-8'))

                    write_csv(path, file_name, file_data)
                    file_names.append(file_name)

    except HttpError as error:
        print(f'Error occurred: {error}')

    return file_names
