# nautobot-docker

The intention of this is to 

1. Product ready deployable Nautobot container
  - Does not include NGINX/HA Proxy, but should be served by UWSGI
  - Healthchecks
  - No plugins (supports adding to as needed)
  - External DB and REDIS configuration required and easy
  - Follows the official installation method of Nautobot as closely as possible
  - Not be based on alpine
  - follow docker best practices
  - Run as separate user, not as root
  - Way to specify external configuration file
  - Use artifacts from contrib directory where possible
  - Documentation why the Python container
  - Dump logs to stdout (very 12 factor - yes)
  - Follow 12 factor best practices
    - Config should be controlled by the environment
  - Kubernetes, Nomad, & Docker Secrets
  - Daily packaging
  - Install latest security patches
  - CI Pipeline
    - Docker Linting
    - Docker vulnerability - quay by default?

Nice to haves:
  - CIS Benchmarks
  - Create Super User (would be default to none)
    - Default to no
    - Use environment variable
  - Import from YAML (separated by endpoint) **Separate out to separate project so it can be used by anyone**
  - Support loading secrets via middleware connector
  - Helm Chart
  - Daily Locust Tests (as part of pipeline testing)