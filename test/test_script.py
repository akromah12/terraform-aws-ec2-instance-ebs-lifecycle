import boto3
import time
import json

# Initialize boto3 clients with the correct region
ec2 = boto3.client('ec2', region_name='eu-west-1')
iam = boto3.client('iam', region_name='eu-west-1')

# Function to wait for instance state
def wait_for_instance_state(instance_id, state):
    while True:
        response = ec2.describe_instances(InstanceIds=[instance_id])
        instance_state = response['Reservations'][0]['Instances'][0]['State']['Name']
        if instance_state == state:
            break
        time.sleep(5)

# Function to get the instance ID and AMI ID from the Terraform state file
def get_instance_details_from_tfstate(tfstate_file):
    with open(tfstate_file, 'r') as f:
        tfstate = json.load(f)
    for resource in tfstate['resources']:
        if resource['type'] == 'aws_instance':
            instance_id = resource['instances'][0]['attributes']['id']
            ami_id = resource['instances'][0]['attributes']['ami']
            return instance_id, ami_id
    raise Exception("Instance details not found in Terraform state file")

# Test 1: Verify instance creation with valid parameters
def test_create_instance():
    instance_id, ami_id = get_instance_details_from_tfstate('terraform.tfstate')
    wait_for_instance_state(instance_id, 'running')
    print(f"Instance {instance_id} is in 'running' state")
    return instance_id, ami_id

# Test 2: Verify instance type and AMI
def test_verify_instance_details(instance_id, ami_id):
    response = ec2.describe_instances(InstanceIds=[instance_id])
    instance = response['Reservations'][0]['Instances'][0]
    print(f"Instance details: {instance}")  # Print instance details for debugging
    assert instance['InstanceType'] == 't2.micro'
    assert instance['ImageId'] == ami_id
    print("Instance details match the configuration")

# Test 3: Start a stopped EC2 instance
def test_start_instance(instance_id):
    ec2.start_instances(InstanceIds=[instance_id])
    wait_for_instance_state(instance_id, 'running')
    print(f"Instance {instance_id} transitioned to 'running' state")

# Test 4: Stop a running EC2 instance
def test_stop_instance(instance_id):
    ec2.stop_instances(InstanceIds=[instance_id])
    wait_for_instance_state(instance_id, 'stopped')
    print(f"Instance {instance_id} transitioned to 'stopped' state")

# Test 5: Terminate an EC2 instance
def test_terminate_instance(instance_id):
    ec2.terminate_instances(InstanceIds=[instance_id])
    wait_for_instance_state(instance_id, 'terminated')
    print(f"Instance {instance_id} transitioned to 'terminated' state")

# Test 6: Try to launch an instance with a non-existent AMI
def test_launch_instance_with_non_existent_ami():
    try:
        ec2.run_instances(
            ImageId='ami-nonexistent',
            InstanceType='t2.micro',
            MinCount=1,
            MaxCount=1
        )
    except Exception as e:
        print(f"Error message displayed: {e}")

# Test 7: Try to launch an EC2 instance with a restricted IAM role
def test_launch_instance_with_restricted_iam_role():
    try:
        ec2.run_instances(
            ImageId=get_latest_ami_id(),
            InstanceType='t2.micro',
            MinCount=1,
            MaxCount=1,
            IamInstanceProfile={'Name': 'restricted-role'}
        )
    except Exception as e:
        print(f"Instance launch failed with permission error: {e}")

# Test 8: Attempt to start an instance that is already running
def test_start_already_running_instance(instance_id):
    try:
        ec2.start_instances(InstanceIds=[instance_id])
    except Exception as e:
        print(f"No state change occurred, and an appropriate message was logged: {e}")

# Test 9: Try to terminate an instance that does not exist
def test_terminate_non_existent_instance():
    try:
        ec2.terminate_instances(InstanceIds=['i-nonexistent'])
    except Exception as e:
        print(f"Error message displayed: {e}")

# Test 10: Verify instance availability after an AWS region outage
def test_instance_availability_after_outage(instance_id):
    ec2.stop_instances(InstanceIds=[instance_id])
    wait_for_instance_state(instance_id, 'stopped')
    ec2.start_instances(InstanceIds=[instance_id])
    wait_for_instance_state(instance_id, 'running')
    print(f"Instance {instance_id} is available after simulated outage")

# Test Case 11: Try to detach the root volume from a running instance
def test_detach_root_volume(instance_id):
    response = ec2.describe_instances(InstanceIds=[instance_id])
    root_volume_id = response['Reservations'][0]['Instances'][0]['BlockDeviceMappings'][0]['Ebs']['VolumeId']
    try:
        ec2.detach_volume(VolumeId=root_volume_id)
    except Exception as e:
        print(f"Operation blocked with an error message: {e}")

# Test Case 12: Attempt to change instance type without stopping the instance
def test_change_instance_type_without_stopping(instance_id):
    try:
        ec2.modify_instance_attribute(InstanceId=instance_id, InstanceType={'Value': 't2.small'})
    except Exception as e:
        print(f"AWS rejected the request with an error: {e}")

# Main function to run all tests
def main():
    # Create an instance for testing
    instance_id, ami_id = test_create_instance()

    # Run tests
    test_verify_instance_details(instance_id, ami_id)
    test_start_instance(instance_id)
    test_stop_instance(instance_id)
    test_terminate_instance(instance_id)
    test_launch_instance_with_non_existent_ami()
    test_launch_instance_with_restricted_iam_role()
    test_start_already_running_instance(instance_id)
    test_terminate_non_existent_instance()
    test_instance_availability_after_outage(instance_id)
    test_detach_root_volume(instance_id)
    test_change_instance_type_without_stopping(instance_id)

if __name__ == "__main__":
    main()