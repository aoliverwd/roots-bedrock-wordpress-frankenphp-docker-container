# Roots Bedrock WordPress Development Environment

A Docker-based local WordPress development environment powered by [Roots Bedrock](https://roots.io/bedrock/), [FrankenPHP](https://frankenphp.dev/), and [Caddy](https://caddyserver.com/).

The environment provides local HTTPS, Composer-based dependency management, and a choice of **MySQL or SQLite** for database storage.

## Features

- **Roots Bedrock:** A modern WordPress project structure with environment-based configuration and Composer-managed dependencies.
- **FrankenPHP:** Runs the PHP application.
- **Caddy:** Provides HTTPS for local development.
- **Database flexibility:** Choose between MySQL and SQLite.
- **Docker Compose:** Build, run, and manage the development environment with simple commands.
- **WP-CLI:** Manage WordPress directly from the command line.

## Prerequisites

Install the following tools before getting started:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/) (or the Docker Compose plugin included with Docker Desktop and many Docker Engine installations)

Verify your installation:

```bash
docker --version
docker compose version
```

## Getting Started

### 1. Configure Environment Variables

Create a local environment file from the example:

```bash
cp env.example .env
```

Review `.env` and update the variables to match your local configuration.

> [!CAUTION]
> Never commit `.env` files containing secrets or environment-specific credentials. When adding configuration variables, update `env.example` with safe example values, but never include real secrets.

### 2. Choose a Database

Select the database backend you want to use.

**MySQL (default)**

Start the environment using the default Compose configuration:

```bash
docker compose up -d --build
```

**SQLite**

Start the environment using the SQLite-specific Compose configuration:

```bash
docker compose -f docker-compose-sqlite.yml up -d --build --remove-orphans
```

Use the same Compose configuration for subsequent commands, including inspecting logs and stopping services.

> [!NOTE]
> SQLite support may require different persistence or initialization settings from MySQL. Follow the configuration defined in `docker-compose-sqlite.yml` and the relevant application environment variables.

### 3. Verify the Environment

Check the status of the running services:

```bash
docker compose ps
```

For the SQLite configuration, use:

```bash
docker compose -f docker-compose-sqlite.yml ps
```

View service logs:

```bash
docker compose logs -f
```

For SQLite, include the Compose file in the command:

```bash
docker compose -f docker-compose-sqlite.yml logs -f
```

Press `Ctrl+C` to stop following the logs. This does not stop the containers.

### 4. Access WordPress

Once the services are running, open:

**[https://localhost/](https://localhost/)**

Caddy handles HTTPS for local development. Depending on your operating system and browser, you may see a certificate warning the first time you access the site. See [HTTPS and Local Certificates](#https-and-local-certificates) for details.

### 5. Stop the Environment

Stop the default environment:

```bash
docker compose down
```

For SQLite:

```bash
docker compose -f docker-compose-sqlite.yml down
```

These commands stop and remove the containers and associated Compose network while preserving named volumes.

To also remove named volumes, use:

```bash
docker compose down -v
```

Or, for SQLite:

```bash
docker compose -f docker-compose-sqlite.yml down -v
```

> **Warning:** Removing volumes can permanently delete database contents and other persisted data. Back up anything you need before running these commands.

## WordPress Plugin and Theme Management

Roots Bedrock manages WordPress plugins and themes through Composer. Dependencies are declared in `bedrock/composer.json` and tracked in `bedrock/composer.lock`.

### Install a Plugin

Navigate to the Bedrock project directory:

```bash
cd bedrock
```

Install a plugin using its Composer package name. For example, a plugin available through [WP Packages](https://wp-packages.org/) might be installed with:

```bash
composer require wp-plugin/plugin-slug
```

Replace `wp-plugin/plugin-slug` with the actual package name specified by the plugin's documentation.

Commit both `composer.json` and `composer.lock` so other developers and environments can install the same dependency versions.

### Update Dependencies

To update dependencies according to the constraints in `composer.json`:

```bash
cd bedrock
composer update
```

To install the versions already recorded in `composer.lock`:

```bash
cd bedrock
composer install
```

Use `composer update` deliberately, as it can change dependency versions and update the lock file.

> [!NOTE]
> Composer package names and installation requirements vary by plugin source. Consult the plugin's documentation before adding it.

## WordPress CLI (WP-CLI)

Run WP-CLI commands inside the WordPress container with `docker compose exec`.

The examples below use the default MySQL configuration. If you use SQLite, add `-f docker-compose-sqlite.yml` to each command.

### List Installed Plugins

```bash
docker compose exec wordpress wp plugin list
```

### List Installed Themes

```bash
docker compose exec wordpress wp theme list
```

### Check the WordPress Version

```bash
docker compose exec wordpress wp core version
```

### Check Database Connectivity

```bash
docker compose exec wordpress wp db check
```

This command is intended for database configurations supported by the relevant WP-CLI command. SQLite-specific support may vary depending on the installed database integration.

### Display WP-CLI Help

```bash
docker compose exec wordpress wp help
```

For more commands and usage examples, see the [WP-CLI documentation](https://developer.wordpress.org/cli/commands/).

## HTTPS and Local Certificates

Caddy provides HTTPS for the local development environment.

If your browser reports that the connection is not trusted, the local certificate authority may not be trusted by your operating system or browser.

Consult the [Caddy Automatic HTTPS documentation](https://caddyserver.com/docs/automatic-https) for details on local certificates and certificate trust.

Do not disable certificate verification as a general workaround. Configure local certificate trust where appropriate for your development environment.

## Troubleshooting

### Containers Fail to Start

Check the service status:

```bash
docker compose ps
```

Review the logs:

```bash
docker compose logs
```

To inspect the WordPress service specifically:

```bash
docker compose logs -f wordpress
```

For SQLite, add `-f docker-compose-sqlite.yml` before the command.

### WordPress Is Unavailable

1. Confirm that the containers are running.
2. Check the WordPress and web server logs.
3. Verify that the expected ports are available and the Compose configuration is correct.
4. Confirm that `.env` contains the required configuration values.

If necessary, rebuild and restart the environment.

For MySQL:

```bash
docker compose up -d --build
```

For SQLite:

```bash
docker compose -f docker-compose-sqlite.yml up -d --build --remove-orphans
```

### WordPress Cannot Connect to MySQL

Check the following:

- The MySQL service is running.
- The database name, username, password, and host in `.env` match the database configuration.
- The database service has completed initialization.
- The WordPress container can reach the database service over the Compose network.

Inspect the database logs:

```bash
docker compose logs db
```

If your database service uses a different name, replace `db` with the service name defined in `compose.yaml` or `docker-compose.yml`.

### HTTPS Certificate Warnings

If you see a browser certificate warning:

- Confirm that Caddy is running.
- Check the Caddy logs for certificate-related errors.
- Verify that the local certificate authority is trusted by your operating system and browser.

Refer to the [Caddy documentation](https://caddyserver.com/docs/automatic-https) for troubleshooting guidance.

### Changes to Environment Variables Are Not Applied

After modifying `.env`, restart the affected services so they receive the updated configuration:

```bash
docker compose up -d
```

For SQLite:

```bash
docker compose -f docker-compose-sqlite.yml up -d
```

Some configuration changes may require rebuilding an image or recreating a container. Database initialization variables, in particular, may not change the credentials or settings of an already initialized database volume.

## Development Notes

- Keep environment-specific configuration in `.env` and document required variables in `env.example`.
- Manage WordPress plugins and themes through Composer wherever possible.
- Commit `composer.lock` to ensure consistent dependency versions.
- Avoid removing persistent volumes unless you intend to delete their contents.
- Use the same Compose configuration when starting, inspecting, and stopping a given environment.

## Useful Resources

- [Roots Bedrock](https://roots.io/bedrock/)
- [FrankenPHP](https://frankenphp.dev/)
- [Caddy](https://caddyserver.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [WP-CLI](https://developer.wordpress.org/cli/commands/)
- [WP Packages](https://wp-packages.org/)
