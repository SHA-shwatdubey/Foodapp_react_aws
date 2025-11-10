aws_region       = "us-east-1"
project_name     = "food-app"
instance_type    = "t2.micro"
key_pair_name    = "food-app-key" # Change this to your AWS EC2 Key Pair name
vpc_cidr         = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
ssh_allowed_cidr = ["0.0.0.0/0"] # Change to your IP for production security
