import boto3
from botocore.exceptions import ClientError

# Define S3 endpoint URL and credentials
s3_endpoint_url = 'https://s3.domain.tdl'
aws_access_key_id = ''
aws_secret_access_key = ''
bucket_name = ''

def test_s3_access(bucket_name, s3_endpoint_url, aws_access_key_id, aws_secret_access_key):
    # Initialise S3 client with endpoint URL and creds
    s3 = boto3.client(
        's3',
        endpoint_url=s3_endpoint_url,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key)

    # Test write access by uploading a test file
    try:
        s3.upload_file("test_file.txt", bucket_name, "test_file.txt")
        print("Write access test successful")
    except ClientError as exc:
        if exc.response['Error']['Code'] == 'AccessDenied':
            print("Write access denied. Check your IAM permissions.")
        else:
            print("An error occurred while testing write access:", exc)
    except Exception as exc:
        print("An error occurred:", exc)

    # Test read access by downloading the test file
    try:
        s3.download_file(bucket_name, "test_file.txt", "downloaded_test_file.txt")
        print("Read access test successful")
    except ClientError as exc:
        if exc.response['Error']['Code'] == 'AccessDenied':
            print("Read access denied. Check your IAM permissions.")
        elif exc.response['Error']['Code'] == 'NoSuchKey':
            print("Test file not found in the bucket.")
        else:
            print("An error occurred while testing read access:", exc)
    except Exception as exc:
        print("An error occurred:", exc)
    finally:
        # Cleanup: Delete the test files
        try:
            s3.delete_object(Bucket=bucket_name, Key="test_file.txt")
            s3.delete_object(Bucket=bucket_name, Key="downloaded_test_file.txt")
        except Exception as exc:
            print("An error occurred while cleaning up:", exc)


if __name__ == "__main__":
    # Create test file
    with open("test_file.txt", "w", encoding="utf-8") as f:
        f.write("This is a test file.")

    test_s3_access(bucket_name, s3_endpoint_url, aws_access_key_id, aws_secret_access_key)
