# Build Elixir/Phoenix app

ARG ELIXIR_VERSION=1.12.2
ARG ERLANG_VERSION=24.1.1

ARG ALPINE_VERSION=3.14.0

# Build image
ARG BUILD_IMAGE_NAME=hexpm/elixir
ARG BUILD_IMAGE_TAG=${ELIXIR_VERSION}-erlang-${ERLANG_VERSION}-alpine-${ALPINE_VERSION}

# Deploy base image
ARG DEPLOY_IMAGE_NAME=alpine
ARG DEPLOY_IMAGE_TAG=$ALPINE_VERSION

# Output image
# ARG EARTHLY_GIT_HASH
ARG IMAGE_TAG=latest
ARG REPO_URL="gaslight/retroflect"
ARG OUTPUT_IMAGE_NAME=$REPO_URL

# Run "apk upgrade" to update packages to a newer version than what is in the base image.
# This ensures that we get the latest packages, but makes the build nondeterministic.
# It is most useful when here is a vulnerability which is fixed in packages but
# not yet released in an Alpine base image.
# ARG APK_UPGRADE="apk upgrade --update-cache -a"
ARG APK_UPGRADE=":"

# Docker registry for base images, default is docker.io
# If specified, should have a trailing slash
ARG REGISTRY=""

# Elixir release env to build
ARG MIX_ENV=prod

# Name of Elixir release
# This should match mix.exs, e.g.
# defp releases do
#   [
#     prod: [
#       include_executables_for: [:unix],
#     ],
#   ]
# end
ARG RELEASE=prod

# Name of app, used for directories
ARG APP_NAME=retroflective

# OS user that app runs under
ARG APP_USER=postgres

# OS group that app runs under
ARG APP_GROUP="$APP_USER"

# Runtime dir
ARG APP_DIR=/app

ARG LANG=C.UTF-8

ARG http_proxy
ARG https_proxy=$http_proxy

all:
    BUILD +test
    BUILD +run-tests

# Fetch OS build dependencies
os-deps:
    FROM ${REGISTRY}${BUILD_IMAGE_NAME}:${BUILD_IMAGE_TAG}

    # See https://wiki.alpinelinux.org/wiki/Local_APK_cache for details
    # on the local cache and need for the symlink
    RUN --mount=type=cache,target=/var/cache/apk \
        apk update && $APK_UPGRADE && \
        # apk add --no-progress alpine-sdk && \
        apk add --no-progress git build-base && \
        apk add --no-progress curl && \
        apk add --no-progress nodejs npm && \
        # Vulnerability checking
        curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

    # Database command line clients to check if DBs are up when performing integration tests
    # RUN apk add --no-progress postgresql-client mysql-client
    # RUN apk add --no-progress --no-cache curl gnupg --virtual .build-dependencies -- && \
    #     curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.5.2.1-1_amd64.apk && \
    #     curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.5.2.1-1_amd64.apk && \
    #     echo y | apk add --allow-untrusted msodbcsql17_17.5.2.1-1_amd64.apk mssql-tools_17.5.2.1-1_amd64.apk && \
    #     apk del .build-dependencies && rm -f msodbcsql*.sig mssql-tools*.apk
    # ENV PATH="/opt/mssql-tools/bin:${PATH}"

# Fetch app library dependencies
deps:
    FROM +os-deps

    WORKDIR /app

    # Get Elixir app deps
    COPY config config
    COPY mix.exs mix.lock ./

    RUN --mount=type=cache,target=~/.hex/packages/hexpm \
        --mount=type=cache,target=~/.cache/rebar3 \
        mix do local.rebar --force, local.hex --force, deps.get
        # mix do local.rebar --force, local.hex --force, deps.get --only $MIX_ENV

    SAVE ARTIFACT deps /deps

# Create environment to run tests
test:
    FROM +deps

    ENV MIX_ENV=test
    # ENV DATABASE_HOST=db

    WORKDIR /app

    COPY --dir lib priv test ./

    RUN --mount=type=cache,target=~/.hex/packages/hexpm \
        --mount=type=cache,target=~/.cache/rebar3 \
        mix do compile 

    SAVE IMAGE retroflect-test:latest

# Create database for tests
postgres:
    FROM "${REGISTRY}postgres:12"
    ENV POSTGRES_USER=postgres
    ENV POSTGRES_PASSWORD=postgres
    EXPOSE 5432
    SAVE IMAGE retroflect-db:latest

# Run tests in test environment with database
run-tests:
    FROM earthly/dind:alpine

    COPY docker-compose.test.yml ./docker-compose.yml

    WITH DOCKER \
            --load test:latest=+test \
            --load retroflect-db:latest=+postgres \
            --compose docker-compose.yml
        RUN docker-compose run test mix test
    END

assets:
    FROM +deps

    # Get assets from phoenix
    WORKDIR /app
    COPY +deps/deps deps
