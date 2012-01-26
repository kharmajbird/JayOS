#!/usr/bin/env python
# written by Bryce Boe (http://www.bryceboe.com/)

import os, sys

try:
    import boto.s3
    boto.s3.key.Key.change_storage_class
except ImportError, e:
    sys.stderr.write('Package boto (svn rev. >= 1595) must be installed.\n')
    sys.exit(1)
except AttributeError, e:
    sys.stderr.write('Invalid version of boto. Required svn rev. >= 1595.\n')
    sys.exit(1)

def convert(bucket_name, aws_id, aws_key):
    s3 = boto.connect_s3(aws_id, aws_key)
    bucket = s3.lookup(bucket_name)
    if not bucket:
        sys.stderr.write('Invalid authentication, or bucketname. Try again.\n')
        sys.exit(1)
    print 'Found bucket: %s' % bucket_name
    sys.stdout.write('Converting: ')
    sys.stdout.flush()
    found = converted = 0
    try:
        for key in bucket.list():
            found += 1
            if key.storage_class != 'REDUCED_REDUNDANCY':
                key.change_storage_class('REDUCED_REDUNDANCY')
                converted += 1
            if found % 100 == 0:
                sys.stdout.write('.')
                sys.stdout.flush()
    except KeyboardInterrupt: pass

    print '\nConverted %d items out of %d to reduced redundancy storage.' % \
        (converted, found)

def main():
    def usage(msg=None):
        if msg:
            sys.stderr.write('<Error>\n%s\n</Error>\n' % msg)
        sys.stderr.write(''.join(['Usage: %s bucket [aws_access_key_id ',
                                  'aws_secret_access_key]\n']) % sys.argv[0])
        sys.exit(1)

    if len(sys.argv) == 2:
        bucket = sys.argv[1]
        msg = ''
        if 'AWS_ACCESS_KEY_ID' in os.environ:
            aws_id = os.environ['AWS_ACCESS_KEY_ID']
        else:
            msg += 'Environment does not contain AWS_ACCESS_KEY_ID.\n'
        if 'AWS_SECRET_ACCESS_KEY' in os.environ:
            aws_key = os.environ['AWS_SECRET_ACCESS_KEY']
        else:
            msg += 'Environment does not contain AWS_SECRET_ACCESS_KEY.\n'
        if msg:
            usage(msg + 'Please set values in environment or pass them in.')
    elif len(sys.argv) == 4:
        bucket = sys.argv[1]
        aws_id = sys.argv[2]
        aws_key = sys.argv[3]
    else:
        usage()

    convert(bucket, aws_id, aws_key)

if __name__ == '__main__':
    main()
