#!/bin/bash

# Apply database migrations
echo "Apply database migrations"
nautobot-server migrate

# Start server
echo "Starting server"
nautobot-server runserver 0.0.0.0:8000