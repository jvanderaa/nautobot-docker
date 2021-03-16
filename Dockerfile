FROM python:3.8 as base

ENV PYTHONUNBUFFERED 1

# -------------------------------------------------------------------------------------
# Install Nautobot requirements
# -------------------------------------------------------------------------------------
# During image build process, only Nautobot's requirements are installed.
#
# Local source code is mounted as volume into container. This approach does not require
# to rebuild a container when source code change occurs.
# -------------------------------------------------------------------------------------

RUN pip install --upgrade pip

# Install Poetry manually from GitHub because otherwise it installs its own
# dependencies globally which may conflict with ours.
# https://python-poetry.org/docs/#osx-linux-bashonwindows-install-instructions
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -

# Modify the PATH here because otherwise poetry fails 100% of the time. WAT??
ENV PATH="${PATH}:/root/.poetry/bin"

# Poetry shouldn't create a venv as we want global install
RUN poetry config virtualenvs.create false
# Poetry 1.1.0 added parallel installation as an option;
# unfortunately it seems to have some issues with installing/updating "requests" and "certifi"
# while simultaneously atttempting to *use* those packages to install other packages.
# For now we disable it.
RUN poetry config installer.parallel false

COPY poetry.lock pyproject.toml /opt/nautobot/
WORKDIR /opt/nautobot

RUN poetry install

FROM python:3.8-slim as final

ENV NAUTOBOT_ROOT /opt/nautobot

RUN apt update && apt upgrade -y && apt install -y git && apt autoremove -y && apt clean all

RUN useradd --system --shell /bin/bash --create-home --home-dir /opt/nautobot nautobot

USER nautobot

# Copy from base the required items
COPY --from=base /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages
COPY --from=base /usr/local/bin /usr/local/bin

# Required for static image, specifically the logo
COPY --from=base /etc/mime.types /etc/mime.types

WORKDIR /opt/nautobot

COPY nautobot_config.py contrib/uwsgi.ini entrypoint.sh ./

# Collect static files here, this increases the size of the container for the worker but decreases
# the necessary start time for the containers.
RUN nautobot-server collectstatic

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "nautobot-server", "check" ]

ENTRYPOINT ["./entrypoint.sh"]
CMD ["start", "--ini", "/opt/nautobot/uwsgi.ini"]
