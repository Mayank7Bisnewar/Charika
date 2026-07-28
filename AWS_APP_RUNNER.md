# AWS App Runner Deployment for Charika Backend

This guide shows how to deploy the backend using AWS App Runner as a simpler alternative to ECS.

## Pre-requisites

- AWS CLI installed and configured
- Docker installed
- ECR repository with backend image pushed
- AWS App Runner permissions

## 1. Push the backend image to ECR

Use the same ECR steps from `AWS_DEPLOYMENT.md` to build and push the image.

## 2. Create the App Runner service

1. Open the AWS console and navigate to App Runner.
2. Choose `Create service`.
3. Select `Container registry` and choose `Amazon ECR`.
4. Select the repository and image tag for `charika-backend`.
5. In the `Environment variables` section, add variables from Secrets Manager or plain values:
   - `DATABASE_URL`
   - `JWT_SECRET_KEY`
   - `GOOGLE_MAPS_API_KEY`
6. For a secure production environment, use App Runner environment secrets via AWS Secrets Manager.
7. Choose `Next`, then `Create and deploy`.

## 3. Connect to PostgreSQL RDS

If your Postgres instance is in a private VPC, App Runner must be configured with VPC Connector support.

1. Create a VPC Connector in App Runner and attach it to the same subnets/VPC as your RDS instance.
2. Attach the connector to your service.
3. Ensure the App Runner service security group can connect to the RDS security group on port 5432.

## 4. Verify deployment

1. Wait until the App Runner service status is `Running`.
2. Open the App Runner service URL.
3. Verify the backend root route at `https://<app-runner-url>/`.

## Notes

- App Runner is easier than ECS for simple web services, but requires VPC Connector for private databases.
- Use AWS Secrets Manager for API keys and database credentials.
- For production, keep `JWT_SECRET_KEY` and all database credentials secure and rotate them regularly.
