# ghcr.io/duyet/i 

See all images here: <https://github.com/duyet/image/pkgs/container/i/versions>

Pull image from the command line:

```bash
$ docker pull ghcr.io/duyet/image:<tag>
```

Use as base image in Dockerfile:


```Dockerfile
FROM ghcr.io/duyet/image:<tag>
```

## Adding more images


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
