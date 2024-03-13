# Service Orchestration Take-Home Project

Welcome to the Pocket Worlds Service Orchestration Take-Home Project! In this repository, we'd like you to demonstrate your
skills by creating the infrastructure as code to run the simple web app container included here.

This project will serve as the primary jumping off point for our technical interviews. We expect you to spend a 
couple of hours building an MVP that meets the requirements in the Product Description. You are free to implement 
your solution and modify the provided template in the way that makes the most sense to you, but make sure to 
update the README accordingly so that it's clear how to run and test your project. During the interviews, you will 
be asked to demo your solution and discuss the reasoning behind your implementation decisions and their trade-offs. 
Be prepared to share your screen for live coding and problem solving with your interviewers based on this discussion.

## Prerequisites

You will need to have Docker or compatible container tools installed to complete this exercise. You are welcome to use any tools
you prefer in addition, but make sure to document/automate anything required to run this test when you submit it.

## Project Description

Your task is to build appropriate orchestration as code for a deployment of the provided service container and the redis database it connects to that could receive 
public traffic from users.

If you use a Kubernetes based solution, you do not need to include setting up a K8s cluster. As long as we can apply the code/templates to any kube cluster, that is sufficient. Make sure your code works targeting a fresh kubernetes cluster, minikube installation, etc. You don't need all the bells and whistles for the test, target more of an MVP. There will be time in later interviews to elaborate on how you would approach a more fully featured setup. Targeting minikube is fine for the purposes of this test.

If you use tools specific to a single Cloud provider, use AWS.

From a local development standpoint, docker compose would be a quick way to run and configure the application and Redis, but you would 
need to additionally design and code hosting the application for public use.

You will only turn in your code. You can test your solution however you want, but we need to load the test in our own infrastructure for review. We will supply our own credentials, and if your solution creates DNS entries, document where to update those so that we can use DNS names we can manage.

## Getting Started

To begin the project, fork this repository:

```commandline
git clone https://github.com/pocketzworld/service-orchestration-tech-test.git
```

Then clone your fork to your local machine.

### Building the Service Container

This repository contains a simple web service and container, described [here](https://github.com/pocketzworld/service-orchestration-tech-test/blob/main/service/README.md).

The service container can be built using `make build` from the root directory of the test. Feel free to customize existing commands or add new ones as you see fit. You are not required to use the Makefile. The included Dockerfile is sufficient to run this service for the purposes of the test. You are welcome to make changes to support tools you want to use or demonstrate other patterns, but do not add config files or configuration related environment variables to the Dockerfile.

### Testing

The service API exposes swagger docs that can be used to inspect and test the API endpoints. Running the container locally with `make run` would make the swagger docs available at `http://localhost:8000/docs`

## Submission Guidelines

When you have completed the project, please follow these guidelines for submission:

1. Commit and push your code to your forked GitHub repository.
2. Update this README with any additional instructions, notes, or explanations regarding your implementation, if necessary.
3. Provide clear instructions on how to run and test your project.
4. Share the repository URL with the hiring team or interviewer.

## Additional Information

Feel free to be creative in how you approach this project. Your solution will be evaluated based on code quality,
efficiency, and how well it meets the specified requirements. Be prepared to discuss the reasoning behind your
implementation decisions and their trade-offs.

Remember that this project is the basis for the technical interviews, which do include live coding. We will not
ask you to solve an algorithm, but you will be expected to demo your solution and explain your thought process.

Good luck, and we look forward to seeing your URL Shortener project! If you have any questions or need
clarifications, please reach out to us.

## Implementation Details

### Prerequisites

To deploy this application you will need a kubernetes cluster and kubectl, helm, and kustomize installed. 

### Deployment

Use `make deploy` to run a bash script which orchestrates the following:
1. Using Helm to install [redis](https://github.com/bitnami/charts/tree/main/bitnami/redis).
2. Using Helm to install the [nginx-controller](https://github.com/kubernetes/ingress-nginx).
3. Using kubectl and kustomize to deploy the application to the cluster.

With your current kubectl context set to the cluster you wish to deploy to, simply run `make deploy` and the script will deploy what is necessary to run the application, as well as the application itself, as defined above.

### Infrastructure

The infrastructure that is set up here is a deployment with 2 replicas which uses a config map and volume mount approach to mount the redis configuration file on to the pod for the service to use. The service retrieves this config file from `/etc/config/service.cfg`. We are also installing nginx to front the service with a load balancer ingress which can be wired up to aws ALB controller and externalDNS to manage an AWS Route53 Zone. And, of course, we are installing a redis cluster which sets up a single master and single replica.

### Technology

I used [colima](https://github.com/abiosoft/colima) for a local install of kubernetes and docker, which allowed me to build the image in my local docker cache and the colima kubernetes instance was able to pull from it. This means that I could just run `make build` to create my local image tagged `pw/crudservice:latest` and the [deployment](./k8s/deployment.yaml) which pulls that image will pull it successfully from my local docker without ever reaching out to a remote registry. In a real environment, the image would be hosted in ECR or the like and there would potentially be the need for `imagePullSecrets` or IAM permissions on nodegroups in the case of EKS.