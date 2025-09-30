# Event Announcement System
Build a system where users can create events via an API, and subscribers receive notifications (email/SMS/push) whenever a new event is announced using AWS SNS, Lambda, and API Gateway.       

## AWS Services to Use:

API Gateway → expose REST API endpoints for creating events and managing subscriptions.

Lambda → process API requests, handle business logic, and publish messages.

SNS (Simple Notification Service) → manage subscriptions and send notifications to multiple channels.

DynamoDB → store event data (name, date, description, etc.) for history.      


## Architecture

User calls API Gateway endpoint to create an event.         

API Gateway triggers a Lambda function.         

Lambda stores event data in DynamoDB.         

Lambda publishes the event to an SNS Topic.       

SNS sends notifications to subscribers (Email/SMS/etc.).       


Diagram:          

[User] --> [API Gateway] --> [Lambda] --> [DynamoDB]         
                                      \         
                                       --> [SNS Topic] --> [Subscribers]            


