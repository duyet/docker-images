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
- [`clickhouse-server`](#clickhouse-server)
    - [`ghcr.io/duyet/docker-images:clickhouse_24.10`](#clickhouse-serverclickhouse_2410)
    - [`ghcr.io/duyet/docker-images:clickhouse_24.11`](#clickhouse-serverclickhouse_2411)
    - [`ghcr.io/duyet/docker-images:clickhouse_24.12`](#clickhouse-serverclickhouse_2412)
    - [`ghcr.io/duyet/docker-images:clickhouse_24.3`](#clickhouse-serverclickhouse_243)
    - [`ghcr.io/duyet/docker-images:clickhouse_24.5`](#clickhouse-serverclickhouse_245)
    - [`ghcr.io/duyet/docker-images:clickhouse_24.6`](#clickhouse-serverclickhouse_246)
    - [`ghcr.io/duyet/docker-images:clickhouse_24.7`](#clickhouse-serverclickhouse_247)
    - [`ghcr.io/duyet/docker-images:clickhouse_24.8`](#clickhouse-serverclickhouse_248)
    - [`ghcr.io/duyet/docker-images:clickhouse_24.9`](#clickhouse-serverclickhouse_249)
    - [`ghcr.io/duyet/docker-images:clickhouse_25.1`](#clickhouse-serverclickhouse_251)
    - [`ghcr.io/duyet/docker-images:clickhouse_25.2`](#clickhouse-serverclickhouse_252)
    - [`ghcr.io/duyet/docker-images:clickhouse_25.3`](#clickhouse-serverclickhouse_253)
    - [`ghcr.io/duyet/docker-images:clickhouse_25.4`](#clickhouse-serverclickhouse_254)
    - [`ghcr.io/duyet/docker-images:clickhouse_25.5`](#clickhouse-serverclickhouse_255)
    - [`ghcr.io/duyet/docker-images:clickhouse_25.6`](#clickhouse-serverclickhouse_256)
- [`debezium`](#debezium)
    - [`ghcr.io/duyet/docker-images:debezium_1.9.5.Final`](#debeziumdebezium_195final)
    - [`ghcr.io/duyet/docker-images:debezium_2.0.0.Beta1`](#debeziumdebezium_200beta1)
    - [`ghcr.io/duyet/docker-images:debezium_2.0.0.Beta2`](#debeziumdebezium_200beta2)
    - [`ghcr.io/duyet/docker-images:debezium_3.0.0.Final`](#debeziumdebezium_300final)
- [`gcloud`](#gcloud)
    - [`ghcr.io/duyet/docker-images:gcloud_alpine_python39`](#gcloudgcloud_alpine_python39)
    - [`ghcr.io/duyet/docker-images:gcloud_debian_python3`](#gcloudgcloud_debian_python3)
- [`kubeconform`](#kubeconform)
    - [`ghcr.io/duyet/docker-images:kubeconform_latest`](#kubeconformkubeconform_latest)
- [`rust`](#rust)
    - [`ghcr.io/duyet/docker-images:athena`](#rustathena)
    - [`ghcr.io/duyet/docker-images:cargo-audit`](#rustcargo-audit)
    - [`ghcr.io/duyet/docker-images:python`](#rustpython)
    - [`ghcr.io/duyet/docker-images:sccache`](#rustsccache)
    - [`ghcr.io/duyet/docker-images:sccache-scheduler`](#rustsccache-scheduler)
    - [`ghcr.io/duyet/docker-images:sccache-server`](#rustsccache-server)
    - [`ghcr.io/duyet/docker-images:typos`](#rusttypos)
- [`upptime`](#upptime)
    - [`ghcr.io/duyet/docker-images:upptime_monitor`](#upptimeupptime_monitor)


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

### [`clickhouse-server/clickhouse_24.11`](clickhouse-server/clickhouse_24.11/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:clickhouse_24.11
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:clickhouse_24.11
```


### [`clickhouse-server/clickhouse_25.3`](clickhouse-server/clickhouse_25.3/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:clickhouse_25.3
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:clickhouse_25.3
```


### [`clickhouse-server/clickhouse_25.4`](clickhouse-server/clickhouse_25.4/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:clickhouse_25.4
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:clickhouse_25.4
```


### [`clickhouse-server/clickhouse_25.5`](clickhouse-server/clickhouse_25.5/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:clickhouse_25.5
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:clickhouse_25.5
```


### [`clickhouse-server/clickhouse_24.10`](clickhouse-server/clickhouse_24.10/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:clickhouse_24.10
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:clickhouse_24.10
```


### [`clickhouse-server/clickhouse_25.2`](clickhouse-server/clickhouse_25.2/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:clickhouse_25.2
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:clickhouse_25.2
```


### [`clickhouse-server/clickhouse_24.9`](clickhouse-server/clickhouse_24.9/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:clickhouse_24.9
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:clickhouse_24.9
```


### [`clickhouse-server/clickhouse_24.7`](clickhouse-server/clickhouse_24.7/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:clickhouse_24.7
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:clickhouse_24.7
```


### [`clickhouse-server/clickhouse_24.6`](clickhouse-server/clickhouse_24.6/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:clickhouse_24.6
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:clickhouse_24.6
```


### [`clickhouse-server/clickhouse_24.8`](clickhouse-server/clickhouse_24.8/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:clickhouse_24.8
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:clickhouse_24.8
```


### [`clickhouse-server/clickhouse_24.12`](clickhouse-server/clickhouse_24.12/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:clickhouse_24.12
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:clickhouse_24.12
```


### [`clickhouse-server/clickhouse_25.1`](clickhouse-server/clickhouse_25.1/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:clickhouse_25.1
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:clickhouse_25.1
```


### [`clickhouse-server/clickhouse_25.6`](clickhouse-server/clickhouse_25.6/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:clickhouse_25.6
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:clickhouse_25.6
```


### [`clickhouse-server/clickhouse_24.3`](clickhouse-server/clickhouse_24.3/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:clickhouse_24.3
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:clickhouse_24.3
```


### [`clickhouse-server/clickhouse_24.5`](clickhouse-server/clickhouse_24.5/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:clickhouse_24.5
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:clickhouse_24.5
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


### [`debezium/debezium_3.0.0.Final`](debezium/debezium_3.0.0.Final/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/docker-images:debezium_3.0.0.Final
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/docker-images:debezium_3.0.0.Final
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

<!-- END IMAGE LIST -->

