#!/usr/bin/env python3

import boto3
import datetime

client = boto3.client('ec2')
DAYS_AGO = 4

def delete_image(image_prefix, timestamp):
  """Searches for images in the format: <image_prefix>-<timestamp> deregisters images
  older than timestamp
  :param image_prefix: The prefix of out image name
  :param timestamp: Deregister images older than this date
  """
  print('Searching for images with the image name: ' + image_prefix + '\n')

  # Get a list of images
  images = client.describe_images(Owners=['self'])
  if not images['Images']:
      print('Error: Image not found')
      exit(1)
  else:
      for image in images['Images']:
          if (image['Name'].startswith(image_prefix)):
            # Extract the timestamp from the image name
            imagetime = int((image['Name'].rpartition('-')[2]))
            if imagetime < timestamp:
              # Delete images older than DAYS_AGO
              print('Deregistering:' + image['Name'])
              client.deregister_image(
                ImageId = image['ImageId']
              )
            else:
              print('Keeping: ' + image['Name'])
  # Make the output readable
  print('\n')
  
if __name__ == '__main__':
  # Get unix timestamp from DAYS_AGO
  now = datetime.datetime.now()
  then = now - datetime.timedelta(days=DAYS_AGO)
  timestamp = int(then.timestamp())
  print ('Deregistering images older than ' + str(DAYS_AGO) + ' days old \n')

  # delete images older that DAYS_AGO
  delete_image('dea-datakube-compute', timestamp)