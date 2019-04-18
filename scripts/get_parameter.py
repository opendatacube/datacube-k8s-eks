#!/usr/bin/env python3
"""
Utility script to help managing secrets in AWS SSM Parameter store
"""

import boto3
from botocore.exceptions import ClientError
import argparse
import logging
import secrets
import string
import sys

SECRET_LENGTH=16

def get_secret(name, readonly, value=None):
  """
    Reads a value from parameter store, or generates a new one
    
    :param str name: The name of the parameter to read or create
    :param bool readonly: Setting this to true will fail instead of generate a new secret
    :param str value: A default value to set in the parameter (won't override)
    :return: str secret
    """
  # Read the secret if it exists
  logging.info('Trying to read secret %s', name )
  ssm = boto3.client('ssm')
  try:
    parameter = ssm.get_parameter(Name=name, WithDecryption=True)
    return parameter['Parameter']['Value']
  except ClientError as e:
    # Generate the secret if it doesn't exist
    if e.response['Error']['Code'] == 'ParameterNotFound':
        logging.info('Could not find parameter %s', name)
        if not readonly:
          if value == None:
            logging.info('Generating new password')
            alphabet = string.ascii_letters + string.digits
            value = ''.join(secrets.choice(alphabet) for i in range(SECRET_LENGTH))
          # Upload the secret to param store
          logging.info('Creating parameter in parameter store %s', name)
          response = ssm.put_parameter(
              Name=name,
              Description='secret generated from datakube',
              Value=value,
              Type='SecureString',
              Overwrite=False
          )
          return value
        else:
          logging.error('ReadOnly flag is set, exiting without generating parameter: %s', name)
          sys.exit(1)
    else:
        logging.error('Unexpected error: %s' % e)
        sys.exit(1)

def main():

    # Parse Args
    parser = argparse.ArgumentParser(description="Read secrets or generate new ones")
    parser.add_argument('-n', 
                        '--name', 
                        help='Name of parameter')
    parser.add_argument('-r', 
                        '--readonly', 
                        help='Disables secret generation functionality', 
                        action='store_true')
    parser.add_argument('-v', 
                        '--value', 
                        help='Value to set on the parameter')
    args = parser.parse_args()

    # Configure Logging
    logging.basicConfig(format='%(asctime)s %(levelname)s %(message)s', level=logging.INFO)

    secret = get_secret(name=args.name, readonly=args.readonly, value=args.value)
    return secret

if __name__ == '__main__':
    sys.stdout.write(main())