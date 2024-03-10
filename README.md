  
Use the submodules dropdown above to view the 4 submodules defined within this module.


 


Features
 
1- Create mutlistack application with MySQl, Elasticached, ActiveMQ in the backend, and Beanstalk in the frontend.

2- Iam role and policies for beantalk



Usage
 
1- create a Directory where the network codes are set as root module. Then create a directory called modules where your bastion, frontend, db, and iam_role directories will be created

The root module create a network for the whole infrastructure. It has public subnets in 2 AZ where the bastion and beanstalk instances will be deployed. A private subnets for backend resources; two elastic IPs, two nat gateways in the public subnet; route tables for public and private subnets.

terraform init
 terraform plan
 terraform apply


2- Set up the bastion host to login to your RDS: create a Directory called bastion inside your modules directory. If you change the directory name, remember to adjust the path in terraform block.   

 terraform init
 terraform plan
 terraform apply

Edit bastion security group to add SSH rule from MyIP
 

Important: The network should have been created already, beacuse you need to refere this data.terraform_remote_state.vpc in your bastion main.tf code file

Without the terraform local backend block, terraform will tell you that The process cannot access the file because another process has locked a portion of the file



3-Set up your backend: create a directory called db, If you change the directory name, remember to adjust the path in the terraform block.

terraform init
 terraform plan
 terraform apply

It will generate passwords for mysql and ActiveMQ and stored them in the parameter store in the system manager.

Will create RDS, Elaticached, and ActiveMQ instances and a backend securyty group.

You must set up the data.terraform_remote_state.bastion, data.terraform_remote_state.vpc, and the terraform local backend for terraform apply to work without error messages.

The bastion module should be created prior to db moddule.

Without this block: the terraform local backend , an error message will be generated saying the state file could not be read.


Login into your bastionHost to initialize the db with the schema  using the below command

clone the source code

commands: mysql -h "dbendpoint" -u "dbusername" -p"dbpassword" "DBaccountName" < db_backup.sql

Edit your application.properties file with the rds, elasticcahe, and activeMq endpoints as well as password and username of your rds and activeMq.

built your artifact 



4- create a directory called iam_role, If you change the directory name, remember to adjust the path in terraform block.


This module create IAM role service and policies for Elasticbeanstalk and an instance profile.

The instance profile is used to pass an IAM role to Beanstalk EC2 instance

terraform init
 terraform plan
 terraform apply

5- set up the frontend: create a directory called frontend, If you change the directory name, remember to adjust the path in terraform block.

 The vpc, the beanstalk service role and ec2 role should have been created already, because you must refere them here using data block.

 Without the terraform local backend block, terraform will tell you that the state file cannot be read.

The source bundle is needed for your elasticbeanstalk app. Found here
https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/tutorials.html.

My domain name server was purchased in Goddady. I added a CNAME record and the value provided was my beanstalk domain name. After provisioning your environment, edit the configuration to add listener https and provide your domain name certificate.

The path of the source bundle will be provided in your "aws_s3_object" resource in the source argument.

Important: The s3 bucket provisions in this code will store only the source bundle zip file. Beanstalk will create automaticaly its own bucket where the artifact, and other resources will be stored. 



To delete the resources provisioned do it in the following order

1- DB
2- bastion
3- network
4- frontend
5- last iam_role



Author
--------------------------------------------------------------------------------------------------------------------------
by Ernestine D Motouom


