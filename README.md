# `ghcr.io/duyet/image`

[![Build and Push](https://github.com/duyet/image/actions/workflows/ci.yaml/badge.svg)](https://github.com/duyet/image/actions/workflows/ci.yaml)

**See all images here: <https://github.com/duyet/image/pkgs/container/image/versions>**

Pull image from the command line:

```bash
$ docker pull ghcr.io/duyet/image:<tag>
```

Use as base image in Dockerfile:


```Dockerfile
FROM ghcr.io/duyet/image:<tag>
```

# Adding images


Github Workflows will build and publish images to `ghrc.io/duyet/image/<tag>`.

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
    - [`ghcr.io/duyet/image:gcloud_python3.11`](#gcloudgcloud_python311)
- [`upptime`](#upptime)
    - [`ghcr.io/duyet/image:upptime_monitor`](#upptimeupptime_monitor)
- [`rust`](#rust)
    - [`ghcr.io/duyet/image:typos`](#rusttypos)
    - [`ghcr.io/duyet/image:sccache`](#rustsccache)
    - [`ghcr.io/duyet/image:python`](#rustpython)
    - [`ghcr.io/duyet/image:sccache-server`](#rustsccache-server)
    - [`ghcr.io/duyet/image:cargo-audit`](#rustcargo-audit)
    - [`ghcr.io/duyet/image:sccache-scheduler`](#rustsccache-scheduler)
    - [`ghcr.io/duyet/image:athena`](#rustathena)
- [`kubeconform`](#kubeconform)
    - [`ghcr.io/duyet/image:kubeconform_latest`](#kubeconformkubeconform_latest)
- [`debezium`](#debezium)
    - [`ghcr.io/duyet/image:debezium_2.0.0.Beta2`](#debeziumdebezium_200beta2)
    - [`ghcr.io/duyet/image:debezium_2.0.0.Beta1`](#debeziumdebezium_200beta1)
    - [`ghcr.io/duyet/image:debezium_1.9.5.Final`](#debeziumdebezium_195final)
    - [`ghcr.io/duyet/image:debezium_nightly`](#debeziumdebezium_nightly)


## `gcloud`

### [`gcloud/gcloud_python3.11`](gcloud/gcloud_python3.11/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/image:gcloud_python3.11
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/image:gcloud_python3.11
```


## `upptime`

### [`upptime/upptime_monitor`](upptime/upptime_monitor/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/image:upptime_monitor
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/image:upptime_monitor
```


## `rust`

### [`rust/typos`](rust/typos/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/image:typos
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/image:typos
```


### [`rust/sccache`](rust/sccache/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/image:sccache
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/image:sccache
```


### [`rust/python`](rust/python/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/image:python
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/image:python
```


### [`rust/sccache-server`](rust/sccache-server/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/image:sccache-server
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/image:sccache-server
```


### [`rust/cargo-audit`](rust/cargo-audit/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/image:cargo-audit
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/image:cargo-audit
```


### [`rust/sccache-scheduler`](rust/sccache-scheduler/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/image:sccache-scheduler
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/image:sccache-scheduler
```


### [`rust/athena`](rust/athena/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/image:athena
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/image:athena
```


## `kubeconform`

### [`kubeconform/kubeconform_latest`](kubeconform/kubeconform_latest/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/image:kubeconform_latest
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/image:kubeconform_latest
```


## `debezium`

### [`debezium/debezium_2.0.0.Beta2`](debezium/debezium_2.0.0.Beta2/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/image:debezium_2.0.0.Beta2
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/image:debezium_2.0.0.Beta2
```


### [`debezium/debezium_2.0.0.Beta1`](debezium/debezium_2.0.0.Beta1/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/image:debezium_2.0.0.Beta1
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/image:debezium_2.0.0.Beta1
```


### [`debezium/debezium_1.9.5.Final`](debezium/debezium_1.9.5.Final/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/image:debezium_1.9.5.Final
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/image:debezium_1.9.5.Final
```


### [`debezium/debezium_nightly`](debezium/debezium_nightly/Dockerfile)

Install from the command line

```bash
docker pull ghcr.io/duyet/image:debezium_nightly
```

Use as base image in Dockerfile:

```Dockerfile
FROM ghcr.io/duyet/image:debezium_nightly
```

<!-- END IMAGE LIST -->

