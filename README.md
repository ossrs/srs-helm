[![](https://badgen.net/discord/members/CrQNVSC6M3)](https://discord.gg/CrQNVSC6M3)

Helm Charts for the [SRS](https://github.com/ossrs/srs) media server.

## Usage

First, you need to install [helm](https://helm.sh/docs/intro/install/). For example, on MacOS:

```bash
brew install helm
helm version --short
#v3.12.0+gc9f554d
```

Next, add the helm repository:

```bash
helm repo add srs http://helm.ossrs.io/stable
```

> Note: If you are in China, use the mirror repository [http://helm.ossrs.net/stable](http://helm.ossrs.net/stable) instead.

To install the SRS origin server, run:

```bash
helm install srs srs/srs-server
```

Visit [http://localhost:8080](http://localhost:8080) to access the SRS console.

Important config for both srs-server and Oryx:

* If enable WebRTC, please setup the [CANDIDATE](https://ossrs.io/lts/en-us/docs/v5/doc/webrtc#config-candidate) by `helm install srs srs/srs-server --set candidate=your-internal-public-ip`

Important config for Oryx only:

* By default, use `/data` of host as storage directory, if want to change, please use `--set persistence.path=$HOME/data` for example.

For detailed information on using SRS, please refer to [https://ossrs.io](https://ossrs.io).

> Note: If you are in China, please refer to [https://ossrs.net](https://ossrs.net).

## Features: srs-server

Note all features of SRS and Oryx are supported by the HELM charts, however, we're working to 
migrate them to HELM.

- [x] v1.0.5: Update docs and tags for charts.
- [x] v1.0.4: Support WebRTC stream server, listen at 8000/udp.
- [x] v1.0.3: Support SRT stream server, listen at 10080/udp.
- [x] v1.0.2: Upgrade SRS to SRS v5.0-b2, 5.0 beta2, v5.0.166.
- [x] v1.0.2: Support config SRS by env, enable HTTP-API, listen at 1985/tcp.
- [x] v1.0.1: Support HTTP origin server, for HTTP-FLV, listen at 8080/tcp.
- [x] v1.0.1: Support HTTP static server, for HLS and players, listen at 8080/tcp.
- [x] v1.0.0: Support RTMP origin server, listen at 1935/tcp.
- [ ] Support HTTPS server and API for WebRTC publisher.
- [ ] Integrate Prometheus and grafana dashboard.

## Features: Oryx

- [x] v1.0.7: Upgrade Oryx to 5.14.19 in Chart.yaml.
- [x] v1.0.6: Rename SRS Stack to Oryx.
- [x] v1.0.0: Support RTMP, HTTP, HTTPS, SRT, and WebRTC in Oryx.

## Local Repository

You can also set up the local HELM repository by executing the following command:

```bash
docker run --rm -it -p 3000:80 ossrs/helm:latest
```

Next, add the local repository with this command:

```bash
helm repo add srs http://localhost:3000/stable
```

Now, you can utilize SRS HELM. For more information, refer to the [Usage](#usage) section.

## Test Repository

You can build a test HELM repository by executing the following command:

```bash
docker build -t test -f Dockerfile .
```

Start the local test docker image:

```bash
docker run --rm -it -p 3000:80 test
```

Next, add the local repository with this command:

```bash
helm repo add srs http://localhost:3000/stable
```

Now, you can utilize SRS HELM. For more information, refer to the [Usage](#usage) section.

## Develop Repository

The simplest way to develop is to build a new chart by:

```bash
helm package srs-server
```

Then install the local chart by:

```bash
helm install srs srs-server-1.0.0.tgz
```

Or, to test the repo, serve current directory in Nginx or other HTTP server, for example:

```bash
docker run --rm -it -p 3000:80 -v $(pwd):/usr/share/nginx/html \
  -v $(pwd)/conf/nginx.conf:/etc/nginx/nginx.conf \
  -v $(pwd)/conf/conf.d/default.conf:/etc/nginx/conf.d/default.conf \
  nginx:stable
```

Next, add the local repository with this command:

```bash
helm repo add srs http://localhost:3000/stable
```

Now, you can utilize SRS HELM. For more information, refer to the [Usage](#usage) section.

## Release Chart Release

To release chart new release, for example, release srs-server v1.0.6, firstly create new chart resource 
file by following command:

```bash
./auto/srs-server.sh -target v1.0.6
```

And, maybe also release a new version of Oryx v1.0.7, run:

```bash
./auto/oryx.sh -target v1.0.7
```

Then, release the chart web server image and refresh official website by:

```bash
./auto/pub.sh
```
