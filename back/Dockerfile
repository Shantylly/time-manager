# Use the official Elixir image from Docker Hub
FROM elixir:latest

COPY init.sql /docker-entrypoint-initdb.d/

# Install Debian packages
RUN apt-get update && \
    apt-get install -y build-essential inotify-tools postgresql-client git && \
    apt-get clean

ENV PGHOST=db
# Set the working directory
WORKDIR /back

# Copy the application code into the container
COPY . .

# Install Phoenix packages
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install --force hex phx_new 1.5.1



RUN mix deps.get

# Expose the port your Phoenix app will run on
EXPOSE 4000

CMD ["sh", "back/start.sh"]
