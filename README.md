# AWS Infrastructure Deployment with Terraform

This Terraform code sets up an AWS infrastructure consisting of an Autoscaling Group, Elastic Load Balancer, Security Group, Launch Configuration, and Subnets. The infrastructure is created in the specified AWS region and deploys instances with Docker to run a webserver.

## Prerequisites
- AWS CLI
- Terraform v1.0.5 or later
- Docker

## Usage
1. Clone the repository to your local machine.
2. Navigate to the directory containing the code.
3. Run `terraform init` to initialize the working directory.
4. Run `terraform plan` to create an execution plan.
5. Run `terraform apply` to apply the changes.
6. After the apply is complete, visit the Elastic Load Balancer's DNS URL to see the webserver's output.

## Terraform code explanation

The `aws` provider block configures Terraform to use AWS as the provider in the specified region.
`aws_default_subnet` resources are created in two different availability zones, which will be used to deploy instances in multiple subnets.
The `aws_launch_configuration` resource sets up the Launch Configuration for the Autoscaling Group. Here, the specified image is the latest Ubuntu AMI, the instance type is `t2.micro`, and the user data file (`userdata.sh`) is used to launch a Docker container running an Nginx webserver.
The `aws_autoscaling_group` resource sets up the Autoscaling Group. It uses the Launch Configuration created earlier and sets the minimum and maximum sizes to 2. Instances are deployed in the specified subnets and are connected to the Elastic Load Balancer. It also sets a Name tag with the value `${var.env}-Webserver-ASG`.
The `aws_elb` resource sets up the Elastic Load Balancer. It is attached to the Security Group and is configured to listen on port 80 with an HTTP health check on the root URL.
The `aws_security_group` resource sets up the Security Group to allow incoming traffic on ports 80 and 443.
Several variables are defined to customize the deployment and the `userdata.sh` file installs Docker, creates an Nginx Docker image, and launches a container running that image.

## Additional notes

- Docker is used to launch a webserver on instances created in the Autoscaling Group. The `userdata.sh` file is responsible for creating the Docker image and container.
- To update the website served by the webserver, modify the `index.html` file in the `userdata.sh` script and then run `terraform apply` to update the configuration.
- To delete the resources, run `terraform destroy`.

## Author 
Made by Vitali Aleksandrov on 07-May-2023.
