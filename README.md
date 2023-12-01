# `ghcr.io/duyet/docker-images`

[![Build and Push](https://github.com/duyet/docker-images/actions/workflows/ci.yaml/badge.svg)](https://github.com/duyet/docker-images/actions/workflows/ci.yaml)

**See all images here: <https://github.com/duyet/docker-images/pkgs/container/docker-images/versions>**

Pull image from the command line:

```bash
$ docker pull ghcr.io/duyet/docker-images:<tag>
```

Use as base image in Dockerfile:


```Dockerfile
FROM ghcr.io/duyet/docker-images:<tag>
```

# Adding images


Github Workflows will build and publish images to `ghrc.io/duyet/docker-images/<tag>`.

Need to generate the `.github/workflows/ci.yaml` whenever adding new image tags folders. 

For example, adding

```
rust/typos/Dockerfile
```

Run the command below to re-generate github workflows:


```bash
pipenv shell && pipenv install
python3 gen.py
```

# Image lists

<!-- BEGIN IMAGE LIST -->
- [`gcloud`](#gcloud)
    - [`ghcr.io/duyet/docker-images:gcloud_debian_python3`](#gcloudgcloud_debian_python3)
    - [`ghcr.io/duyet/docker-images:gcloud_alpine_python39`](#gcloudgcloud_alpine_python39)
- [`upptime`](#upptime)
    - [`ghcr.io/duyet/docker-images:upptime_monitor`](#upptimeupptime_monitor)
- [`rust`](#rust)
    - [`ghcr.io/duyet/docker-images:typos`](#rusttypos)
    - [`ghcr.io/duyet/docker-images:sccache`](#rustsccache)
    - [`ghcr.io/duyet/docker-images:python`](#rustpython)
    - [`ghcr.io/duyet/docker-images:sccache-server`](#rustsccache-server)
    - [`ghcr.io/duyet/docker-images:cargo-audit`](#rustcargo-audit)
    - [`ghcr.io/duyet/docker-images:sccache-scheduler`](#rustsccache-scheduler)
    - [`ghcr.io/duyet/docker-images:athena`](#rustathena)
- [`clickhouse-server`](#clickhouse-server)
    - [`ghcr.io/duyet/docker-images:clickhouse_testing`](#clickhouse-serverclickhouse_testing)
- [`kubeconform`](#kubeconform)
    - [`ghcr.io/duyet/docker-images:kubeconform_latest`](#kubeconformkubeconform_latest)
- [`debezium`](#debezium)
    - [`ghcr.io/duyet/docker-images:debezium_2.0.0.Beta2`](#debeziumdebezium_200beta2)
    - [`ghcr.io/duyet/docker-images:debezium_2.0.0.Beta1`](#debeziumdebezium_200beta1)
    - [`ghcr.io/duyet/docker-images:debezium_1.9.5.Final`](#debeziumdebezium_195final)
    - [`ghcr.io/duyet/docker-images:debezium_nightly`](#debeziumdebezium_nightly)


## `gcloud`

### [`gcloud/gcloud_debian_python3`](gcloud/gcloud_debian_python3/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:gcloud_debian_python3
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:gcloud_debian_python3
```


### [`gcloud/gcloud_alpine_python39`](gcloud/gcloud_alpine_python39/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:gcloud_alpine_python39
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:gcloud_alpine_python39
```


## `upptime`

### [`upptime/upptime_monitor`](upptime/upptime_monitor/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:upptime_monitor
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:upptime_monitor
```


## `rust`

### [`rust/typos`](rust/typos/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:typos
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:typos
```


### [`rust/sccache`](rust/sccache/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:sccache
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:sccache
```


### [`rust/python`](rust/python/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:python
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:python
```


### [`rust/sccache-server`](rust/sccache-server/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:sccache-server
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:sccache-server
```


### [`rust/cargo-audit`](rust/cargo-audit/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:cargo-audit
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:cargo-audit
```


### [`rust/sccache-scheduler`](rust/sccache-scheduler/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:sccache-scheduler
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:sccache-scheduler
```


### [`rust/athena`](rust/athena/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:athena
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:athena
```


## `clickhouse-server`

### [`clickhouse-server/clickhouse_testing`](clickhouse-server/clickhouse_testing/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:clickhouse_testing
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:clickhouse_testing
```


## `kubeconform`

### [`kubeconform/kubeconform_latest`](kubeconform/kubeconform_latest/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:kubeconform_latest
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:kubeconform_latest
```


## `debezium`

### [`debezium/debezium_2.0.0.Beta2`](debezium/debezium_2.0.0.Beta2/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:debezium_2.0.0.Beta2
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:debezium_2.0.0.Beta2
```


### [`debezium/debezium_2.0.0.Beta1`](debezium/debezium_2.0.0.Beta1/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:debezium_2.0.0.Beta1
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:debezium_2.0.0.Beta1
```


### [`debezium/debezium_1.9.5.Final`](debezium/debezium_1.9.5.Final/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:debezium_1.9.5.Final
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:debezium_1.9.5.Final
```


### [`debezium/debezium_nightly`](debezium/debezium_nightly/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:debezium_nightly
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:debezium_nightly
```

<!-- END IMAGE LIST -->

