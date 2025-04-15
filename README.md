# Symfony Development Environment with Docker

This project provides a complete development environment for Symfony using Docker, including:
- Docker
- PHP 8.2
- Symfony 6.4
- MySQL 8.0
- Webpack Encore
- Nginx

## Prerequisites

- Docker
- Docker Compose

## Installation

To initialize the project, run:

```bash
git clone git@github.com:jbdz/symfony-starter.git
cd symfony-starter
make install
```

This command will:
1. Build Docker images
2. Start containers
3. Install dependencies via Composer
4. Create the database

To watch frontend changes: 
```bash
make make asset.watch
```

Visit http://localhost:8080 to access the application.

## Available Commands

Use `make help` to see all available commands.

Enjoy !