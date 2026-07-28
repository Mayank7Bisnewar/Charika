# AWS Deployment Guide for Charika Backend

This guide covers deploying the backend to AWS using Docker, Amazon ECR, Amazon RDS for PostgreSQL, AWS Secrets Manager, and Amazon ECS Fargate.

## Pre-requisites

- AWS account
- AWS CLI installed and configured (`aws configure`)
- Docker installed
- Git repo cloned locally
- AWS IAM user with permissions for ECR, ECS, RDS, IAM, and Secrets Manager

## 1. Build and push the Docker image to ECR

1. Create an ECR repository:

```bash
aws ecr create-repository --repository-name charika-backend --region us-east-1
```

2. Authenticate Docker to ECR:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.us-east-1.amazonaws.com
```

3. Build the Docker image:

```bash
cd backend
docker build -t charika-backend:latest .
```

4. Tag the image for ECR:

```bash
docker tag charika-backend:latest <your-account-id>.dkr.ecr.us-east-1.amazonaws.com/charika-backend:latest
```

5. Push to ECR:

```bash
docker push <your-account-id>.dkr.ecr.us-east-1.amazonaws.com/charika-backend:latest
```

## 2. Create PostgreSQL with Amazon RDS

1. Create a new RDS PostgreSQL instance using the AWS console or CLI.

Using CLI:

```bash
aws rds create-db-instance \
  --db-instance-identifier charika-db \
  --db-instance-class db.t4g.micro \
  --engine postgres \
  --master-username postgres \
  --master-user-password postgres \
  --allocated-storage 20 \
  --backup-retention-period 7 \
  --vpc-security-group-ids <your-sg-id> \
  --db-subnet-group-name <your-subnet-group> \
  --region us-east-1
```

2. Wait until the DB instance is available:

```bash
aws rds describe-db-instances --db-instance-identifier charika-db --region us-east-1
```

3. Get the endpoint from the output and use it to build the `DATABASE_URL`:

```text
postgresql+asyncpg://postgres:postgres@<rds-endpoint>:5432/charika
```

## 3. Store secrets securely

Use AWS Secrets Manager for production secrets.

1. Create a secret for `DATABASE_URL`:

```bash
aws secretsmanager create-secret \
  --name charika/DATABASE_URL \
  --secret-string '{"DATABASE_URL":"postgresql+asyncpg://postgres:postgres@<rds-endpoint>:5432/charika"}' \
  --region us-east-1
```

2. Create a secret for `JWT_SECRET_KEY`:

```bash
aws secretsmanager create-secret \
  --name charika/JWT_SECRET_KEY \
  --secret-string '{"JWT_SECRET_KEY":"REPLACE_WITH_SECURE_VALUE"}' \
  --region us-east-1
```

3. Create a secret for `GOOGLE_MAPS_API_KEY`:

```bash
aws secretsmanager create-secret \
  --name charika/GOOGLE_MAPS_API_KEY \
  --secret-string '{"GOOGLE_MAPS_API_KEY":"YOUR_GOOGLE_MAPS_API_KEY"}' \
  --region us-east-1
```

## 4. Deploy on ECS Fargate

### 4.1 Create an ECS cluster

```bash
aws ecs create-cluster --cluster-name charika-cluster --region us-east-1
```

### 4.2 Create an IAM role for ECS tasks

```bash
aws iam create-role --role-name ecsTaskExecutionRole --assume-role-policy-document file://<(cat <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"Service": "ecs-tasks.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
)
```

Attach the AWS managed policy:

```bash
aws iam attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

### 4.3 Create an ECS task definition

Create a JSON file `ecs-task-definition.json` with the following contents, replacing the ECR image URI and secret names:

```json
{
  "family": "charika-backend-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::<your-account-id>:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "charika-backend",
      "image": "<your-account-id>.dkr.ecr.us-east-1.amazonaws.com/charika-backend:latest",
      "portMappings": [{"containerPort": 8000, "hostPort": 8000, "protocol": "tcp"}],
      "essential": true,
      "environment": [],
      "secrets": [
        {"name": "DATABASE_URL", "valueFrom": "arn:aws:secretsmanager:us-east-1:<your-account-id>:secret:charika/DATABASE_URL"},
        {"name": "JWT_SECRET_KEY", "valueFrom": "arn:aws:secretsmanager:us-east-1:<your-account-id>:secret:charika/JWT_SECRET_KEY"},
        {"name": "GOOGLE_MAPS_API_KEY", "valueFrom": "arn:aws:secretsmanager:us-east-1:<your-account-id>:secret:charika/GOOGLE_MAPS_API_KEY"}
      ]
    }
  ]
}
```

Register the task definition:

```bash
aws ecs register-task-definition --cli-input-json file://ecs-task-definition.json --region us-east-1
```

### 4.4 Create a security group and load balancer

- Create a security group that allows inbound TCP 80/443 from the internet and outbound access to the database port 5432.
- Attach the security group to the ECS service and the RDS instance if needed.

### 4.5 Create the ECS service

```bash
aws ecs create-service \
  --cluster charika-cluster \
  --service-name charika-backend-service \
  --task-definition charika-backend-task \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[<subnet-1>,<subnet-2>],securityGroups=[<ecs-sg-id>],assignPublicIp=ENABLED}" \
  --region us-east-1
```

## 5. Confirm and test

1. Wait for ECS service tasks to become healthy.
2. Find the public IP or load balancer URL.
3. Open `http://<your-backend-url>:8000` and verify the root endpoint.

## Notes

- If you use a private RDS instance, the ECS service must run in the same VPC/subnets as RDS and have the right security group rules.
- Store secrets securely; do not hardcode them in your repository.
- For production, replace `JWT_SECRET_KEY` and all passwords with strong values.
- You can also use AWS App Runner for an even simpler deployment, but App Runner still needs VPC access to RDS.
