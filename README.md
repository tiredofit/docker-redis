# hub.docker.com/r/tiredofit/redis

[![Docker Pulls](https://img.shields.io/docker/pulls/tiredofit/redis.svg)](https://hub.docker.com/r/tiredofit/redis)
[![Docker Stars](https://img.shields.io/docker/stars/tiredofit/redis.svg)](https://hub.docker.com/r/tiredofit/redis)
[![Docker
Layers](https://images.microbadger.com/badges/image/tiredofit/redis.svg)](https://microbadger.com/images/tiredofit/redis)

## Introduction

This will build a [Redis](https://www.redis.org) Database Container.

This Container uses Alpine as a base. Also included are
* [s6 overlay](https://github.com/just-containers/s6-overlay) enabled for PID 1 Init capabilities
* [zabbix-agent](https://zabbix.org) for individual container monitoring.
* Cron installed along with other tools (bash,curl, less, logrotate, nano, vim) for easier management.

[Changelog](CHANGELOG.md)

## Authors

- [Dave Conroy](https://github.com/tiredofit)

## Table of Contents

- [Introduction](#introduction)
- [Authors](#authors)
- [Table of Contents](#table-of-contents)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Quick Start](#quick-start)
- [Configuration](#configuration)
  - [Data-Volumes](#data-volumes)
  - [Environment Variables](#environment-variables)
  - [Networking](#networking)
- [Maintenance](#maintenance)
  - [Shell Access](#shell-access)
- [References](#references)

## Prerequisites

No prerequisites


## Installation

Automated builds of the image are available on [Docker Hub](https://hub.docker.com/r/tiredofit/redis) and is the recommended method of
installation.


```bash
docker pull tiredofit/redis:(tag)
```

- Available Tags

* `latest` -  Redis 6
* `6` -  Redis 6
* `5` -  Redis 5
* `4` - Redis 4
* `3` - Redis 3

### Quick Start

* The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See
the examples folder for a working [docker-compose.yml](examples/docker-compose.yml) that can be
modified for development or production use.

* Set various [environment variables](#environment-variables) to understand the capabilities of this
image.
* Map [persistent storage](#data-volumes) for access to configuration and data files for backup.
* Make [networking ports](#networking) available for public access if necessary

## Configuration

### Data-Volumes

The Following Data Volumes are available.

| Parameter    | Description           |
| ------------ | --------------------- |
| `/data/db`   | Application Directory |
| `/data/logs` | Logfiles              |

### Environment Variables

Along with the Environment Variables from the [Base image](https://hub.docker.com/r/tiredofit/alpine), below is the complete list of available options that can be used to customize your installation.


| Parameter     | Description                            | Default  |
| ------------- | -------------------------------------- | -------- |
| `ENABLE_LOGS` | Enable Logfiles `TRUE` or `FALSE`      | `FALSE`  |
| `LOG_LEVEL`   | Log level                              | `notice` |
| `REDIS_PORT`  | Listening Port                         | `6379`   |
| `REDIS_PASS`  | (optional) Require password to connect |          |

### Networking

The following ports are exposed.

| Port   | Description |
| ------ | ----------- |
| `6379` | Redis Port  |


## Maintenance
### Shell Access

For debugging and maintenance purposes you may want access the containers shell.

```bash
docker exec -it (whatever your container name is e.g. redis) bash
```

## References

* https://redis.org/


