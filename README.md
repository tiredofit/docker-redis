# hub.docker.com/tiredofit/redis

[![Build Status](https://img.shields.io/docker/build/tiredofit/redis.svg)](https://hub.docker.com/r/tiredofit/redis)
[![Docker Pulls](https://img.shields.io/docker/pulls/tiredofit/redis.svg)](https://hub.docker.com/r/tiredofit/redis)
[![Docker Stars](https://img.shields.io/docker/stars/tiredofit/redis.svg)](https://hub.docker.com/r/tiredofit/redis)
[![Docker Layers](https://images.microbadger.com/badges/image/tiredofit/redis.svg)](https://microbadger.com/images/tiredofit/redis)
[![Image Size](https://img.shields.io/microbadger/image-size/tiredofit/redis.svg)](https://microbadger.com/images/tiredofit/redis)

# Introduction

This will build a [Redis](https://www.redis.org) Database Container.

This Container uses Alpine as a base. Also included are
* [s6 overlay](https://github.com/just-containers/s6-overlay) enabled for PID 1 Init capabilities
* [zabbix-agent](https://zabbix.org) for individual container monitoring.
* Cron installed along with other tools (bash,curl, less, logrotate, nano, vim) for easier management.



[Changelog](CHANGELOG.md)

# Authors

- [Dave Conroy](https://github.com/tiredofit)

# Table of Contents

- [Introduction](#introduction)
    - [Changelog](CHANGELOG.md)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
    - [Data Volumes](#data-volumes)
    - [Environment Variables](#environmentvariables)   
    - [Networking](#networking)
- [Maintenance](#maintenance)
    - [Shell Access](#shell-access)
   - [References](#references)

# Prerequisites

No prerequisites


# Installation

Automated builds of the image are available on [Docker Hub](https://hub.docker.com/tiredofit/redis) and is the recommended method of 
installation.


```bash
docker pull hub.docker.com/tiredofit/redis:(tag)
```

- Available Tags

* `latest` - Alpine 3.6 - Redis 4
* `4` - Alpine 3.6 - Redis 4
* `3` - Alpine 3.5 - Redis 3

# Quick Start

* The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See 
the examples folder for a working [docker-compose.yml](examples/docker-compose.yml) that can be 
modified for development or production use.

* Set various [environment variables](#environment-variables) to understand the capabilities of this 
image.
* Map [persistent storage](#data-volumes) for access to configuration and data files for backup.
* Make [networking ports](#networking) available for public access if necessary



# Configuration

### Data-Volumes

The Following Data Volumes are available.

| Parameter | Description |
|-----------|-------------|
| `/data`    | Application Directory |
      

### Environment Variables

Along with the Environment Variables from the [Base image](https://hub.docker.com/r/tiredofit/alpine), below is the complete list of available options that can be used to customize your installation.

### Networking

The following ports are exposed.

| Port      | Description |
|-----------|-------------|
| `6379` | Redis Port |


# Maintenance
#### Shell Access

For debugging and maintenance purposes you may want access the containers shell. 

```bash
docker exec -it (whatever your container name is e.g. redis) bash
```

# References

* https://redis.org/


