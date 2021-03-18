#!/bin/bash
# Apply database migrations
echo "Apply database migrations"
nautobot-server migrate

# Collect static
echo "Collecting static files"
nautobot-server collectstatic --noinput --skip-checks --clear

# Start server
echo "Starting server"
nautobot-server $@