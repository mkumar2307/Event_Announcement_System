# Event Announcement System
Build a system where users can create events via an API, and subscribers receive notifications (email/SMS/push) whenever a new event is announced using AWS SNS, Lambda, and API Gateway.       

## AWS Services to Use:

API Gateway → expose REST API endpoints for creating events and managing subscriptions.

Lambda → process API requests, handle business logic, and publish messages.

SNS (Simple Notification Service) → manage subscriptions and send notifications to multiple channels.

DynamoDB → store event data (name, date, description, etc.) for history.      


## Architecture

1. User calls API Gateway endpoint to create an event.         

2. API Gateway triggers a Lambda function.         

3. Lambda stores event data in DynamoDB.         

4. Lambda publishes the event to an SNS Topic.       

5. SNS sends notifications to subscribers (Email/SMS/etc.).       


## Flow Diagram:          

[User] --> [API Gateway] --> [Lambda] --> [DynamoDB] --> [SNS Topic] --> [Subscribers]            

## Deployment Steps

Package Lambda:         

```bash
cd lambda/announce_event
zip -r announce_event.zip *
aws s3 cp announce_event.zip s3://your-lambda-code-bucket/
```

Initialize Terraform:            

```terraform init```

Plan:        

```terraform plan -var-file="terraform.tfvars"```

Apply:           

```terraform apply -var-file="terraform.tfvars"```