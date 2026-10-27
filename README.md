# Roots Bedrock WordPress Development Environment

A Docker-based WordPress development environment powered by [Roots Bedrock](https://roots.io/bedrock/), [FrankenPHP](https://frankenphp.dev/), [Caddy](https://caddyserver.com/), and MySQL.

The environment provides a local HTTPS development setup with Composer-based dependency management through Bedrock.

## Prerequisites

Before getting started, ensure you have the following installed:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/)

## Getting Started

Follow these steps to configure and start the development environment.

### 1. Configure Environment Variables

Create a `.env` file from the provided example:

```bash
cp env.example .env
```

Review the `.env` file and update any environment variables as needed for your local setup.

> **Note:** Keep `.env` files containing secrets out of version control. Commit changes to `env.example` when introducing new configuration variables, but never include sensitive values.

### 2. Build and Start the Environment

Build the Docker images and start the services in detached mode:

```bash
docker compose up -d --build
```

To check the status of the running services:

```bash
docker compose ps
```

To view the service logs:

```bash
docker compose logs -f
```

Press `Ctrl+C` to stop following the logs without stopping the containers.

### 3. Access WordPress

Once the environment is running, open your browser and navigate to:

**https://localhost/**

HTTPS is provided by Caddy. On first access, your browser may display a certificate warning if the local development certificate is not trusted by your system.

### 4. Stop the Environment

Stop the running services:

```bash
docker compose down
```

This stops and removes the containers while preserving named volumes, such as the database volume, unless those volumes are explicitly removed.

To stop the environment and remove its named volumes as well:

```bash
docker compose down -v
```

> **Warning:** Removing volumes may permanently delete local database contents and other persisted data.

## WordPress Plugin Management

WordPress dependencies are managed through Composer using Roots Bedrock.

### Install a Plugin

Add the required plugin to `bedrock/composer.json` using the appropriate Composer package name, then install or update dependencies as needed.

For example, to install a plugin available through Roots [WP Packages](https://wp-packages.org/):

```bash
cd bedrock
composer require wp-plugin/plugin-slug
```

Replace `plugin-slug` with the plugin's actual package slug.

Commit the updated `composer.json` and `composer.lock` files to ensure dependencies can be installed consistently across environments.

> **Note:** Composer package names vary by plugin source. Check the package's installation instructions before adding it.

## WordPress CLI (WP-CLI)

Run WP-CLI commands inside the WordPress container using `docker compose exec`.

For example, to list installed plugins:

```bash
docker compose exec wordpress wp plugin list
```

Other useful commands include:

**Check the WordPress version**

```bash
docker compose exec wordpress wp core version
```

**List WordPress themes**

```bash
docker compose exec wordpress wp theme list
```

**Check the database connection**

```bash
docker compose exec wordpress wp db check
```

**Display available WP-CLI commands**

```bash
docker compose exec wordpress wp help
```

## HTTPS and Local Certificates

Caddy handles HTTPS for the local development environment.

If your browser displays a certificate warning, the local certificate authority may not yet be trusted by your operating system or browser.

Refer to the [Caddy documentation](https://caddyserver.com/docs/automatic-https) for information about local HTTPS and certificate trust.

## Troubleshooting

### Containers fail to start

Check the service status and logs:

```bash
docker compose ps
docker compose logs
```

To inspect logs for the WordPress service specifically:

```bash
docker compose logs -f wordpress
```

### The application is unavailable

Confirm that the containers are running:

```bash
docker compose ps
```

If necessary, rebuild and restart the environment:

```bash
docker compose up -d --build
```

### WordPress cannot connect to MySQL

Review the database-related variables in `.env` and confirm that the MySQL service is running and configured with matching credentials.

Inspect the service logs for additional details:

```bash
docker compose logs mysql
```

> **Note:** This command assumes the database service is named `mysql`. If your Compose configuration uses a different service name, replace `mysql` with the appropriate name.

## Project Structure

The key project files and directories are:

```text
.
├── bedrock/
│   ├── composer.json
│   ├── composer.lock
│   └── web/
├── .env
├── env.example
└── docker-compose.yml
```

This is an illustrative overview. Your actual directory structure may differ depending on the repository layout.

## Contributing

When changing the development environment:

- Update `env.example` when adding or changing required environment variables.
- Keep WordPress dependencies managed through Composer.
- Avoid committing secrets or local-only configuration.
- Update this README when setup steps or development workflows change.
