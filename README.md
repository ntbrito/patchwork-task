## Summary of this project
The web service runs from a docker container deployed in AWS service Elastic Container Service (ECS).

This is not a ready to production platform as there are many missing parts to make it secure and reliable.
As it is described below.

### How to deploy the infrastructure
* Change to the folder 'terraform' 
* Run the commands 
  * terraform init
  * terraform plan
  * terraform apply

Once this is complete we can push the container to ECR
### How to deploy the application
* change to the folder devops-test-80d0a4c483NB-main
* Run the bash script deploy.sh with the arguments account id and region
  * ./deploy.sh accountid region

The region is hardcoded on the variables file to be London (eu-west-2) and unfortunately this region
needs to be passed to the deployment script, otherwise the container image is not accessible.

Since there is no DNS, to access the application we will have to use the Load Balancer DNS
name.

## Regarding Best Practices
### Security
There are a few security issues with this solution. Even though access to the web application is
protected by a security group, the container is running on a public network segment with a public IP.

The reason for this was the fact that to run the service on a private network I would have to create a
NAT Gateway to allow the service to reach the internet, for this I would have to use Elastic IPs that
come with a cost.

There is no support for SSL and HTTPS, the traffic is completely in plain text which makes the
solution vulnerable. Again this was purely to avoid the cost of registering a domain and buying a
corresponding certificate. Probably a self-signed certificate and a domain for testing purposes could
be used but this doesn't seem to be the main goal of the task, as the main requirements are around
provisioning and deploying an application.

### Resilience 
While the container will be restarted after a failure, as the desired count is set to 1, there will
be a downtime if the task stops. This solution does not contemplate autoscaling and if for some
reason the resources are exhausted the application will become unresponsive. I choose not to
implement autoscaling to be able to deliver the solution on a timely manner. 

### Observability
The application publishes logs on AWS CloudWatch, while this allows to troubleshoot failures with the
application it doesn't provide an immediate visibility of possible issue.

To have a better understanding of possible problems with the application we would need a monitoring
system that can keep track of relevant metrics and present a visualization of those metrics. The
monitoring system would be even more efficient if we added some thresholds on relevant metrics and have
the possibility to create alerts and send notifications when a threshold on those metrics is met.

Logging systems are mostly useful to troubleshoot when a problem occurs.

### Deployments and updates
To update the current solution we need to run the script deploy.sh to create a new container image and
push it to ECR. Then we will need to stop the running task and wait for it to start and pull the
new image available.

Ideally we would have a pipeline describing all this steps and running from a CI/CD tool like jenkins
or some pipeline offered by some control version systems like BitBucket Pipelines or GitHub Actions.
