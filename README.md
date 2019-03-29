# dcos-terraform-install
This Terraform script is used to install and manage Mesosphere on AWS.  The script will setup the required AWS resources within a specified region and install the DC/OS software.      

## Setup
To use this script you will need an AWS Account, AWS CLI, and Terraform
1. Setup an AWS account
2. Install Python3
3. Install AWS CLI using PIP
4. Install Terraform using PIP
5. Setup ec2 SSH keypair using AWS

### Configure AWS Profile
AWS CLI uses profiles to determine variables and credentials for use with your account.  After setting up IAM in AWS you need to create a profile that can be used with Terraform.  This information is stored within `$HOME/.aws/` in the `config` and `credentials` files.

Replace `<name>` with the IAM username for your AWS account with permissions to configure resources.  Change the region and access and secret keys for your environment.     

Example config:
```
[profile <name>]
region = us-west-2
output = json
```

Example credentials:
```
[<name>]
aws_access_key_id = XYZ
aws_secret_access_key = XYZ
```
### Setup SSH keypair
Create a new ec2 SSH keypair in AWS.  Download the .pem file and copy into the `$HOME/.ssh` directory.  

Chmod the pem file so only the owner/user has read permissions
```
$ chmod 400 <filename>.pem
```
In Unix/Linux ssh-agent is a background program that handles passwords for SSH private keys.  Once you add a private key to ssh-agent using ssh-add you will not be prompted for a key when accessing a host that has the public key.

### Setup ssh-agent
```
$ eval `ssh-agent`
```
Note: Make sure you use the back-ticks under the ~ key and not single quotes.

### Add the key to ssh-agent
```
$ ssh-add ~/.ssh/<key-file>
```
### Configure .bash_profile
The Terraform script will use an environment variable `AWS_PROFILE` to access the AWS profile and credentials.  The script will also need SSH access into the ec2 instances to install software and configure the Mesosphere nodes.  Adding the below lines to your `.bash_profile` ensures variables are set when opening a terminal/shell.

Add the below lines to your `$HOME/.bash_profile` file using the `<name>` and `<key-file>` from above.    
```
#AWS Profile
export AWS_PROFILE=<name>

#SSH Keys
eval `ssh-agent` 
ssh-add ~/.ssh/aws/northlogic.pem
```
  
## Usage
Copy the `main.tf` to a new directory i.e. `$HOME/Mesosphere` and use terraform to install Mesosphere

Initialize the configuration
```
$ terraform init
```

Apply the configuration
```
$ terraform apply
```

Remove the configuration and tear down all deployed resources, using the configuration defined in the .tf file
```
$ terraform destroy
```

Note: This command executes all *.tf files in a directory.  This command combines terraform plan and terraform apply commands into single command

The output will display specific value or when the value displayed is <computed>, it means that the value won't be known until the resource is created.  If terraform apply failed with an error, read the error message and fix the error that occurred. At this stage, it is likely to be a syntax error in the configuration.

If the plan was created successfully, Terraform will now pause and wait for approval before proceeding. If anything in the plan seems incorrect or dangerous, it is safe to abort here with no changes made to your infrastructure. If the plan looks good, type yes at the confirmation prompt to proceed.

Terraform also writes some data into the `.tfstate` file. This state file is extremely important; it keeps track of the IDs of created resources so that Terraform knows what it is managing.  
