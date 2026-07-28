# Charika.app

## Backend Setup

This project uses FastAPI with PostgreSQL, Google Maps, and Docker.

### Local development

1. Copy the backend environment file:

```bash
cp backend/.env.example backend/.env
```

2. Fill in `backend/.env`:

- `DATABASE_URL`: PostgreSQL connection string
- `JWT_SECRET_KEY`: secure JWT signing key
- `GOOGLE_MAPS_API_KEY`: your Google Maps API key

3. Start the database and backend locally:

```bash
docker-compose up --build
```

4. The API will be available at `http://localhost:8000`.

### PostgreSQL

Local development uses PostgreSQL in Docker. The app reads `DATABASE_URL` from environment variables.

### Google Maps

The backend uses Google Maps Geocoding to convert addresses into coordinates. Set `GOOGLE_MAPS_API_KEY` in `backend/.env`.

### AWS Deployment

For AWS deployment, build and push the Docker image, then run it on ECS, App Runner, or another AWS container service.
Use an AWS-managed RDS PostgreSQL instance and secure environment variables with AWS Secrets Manager or Parameter Store.

Required environment variables on AWS:

- `DATABASE_URL`
- `JWT_SECRET_KEY`
- `GOOGLE_MAPS_API_KEY`

### Terraform Automation

Use the Terraform configuration in `terraform/` to provision the full AWS stack automatically.

See `terraform/README.md` for setup and commands.
