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

For detailed information on using SRS, please refer to [https://ossrs.io](https://ossrs.io).

> Note: If you are in China, please refer to [https://ossrs.net](https://ossrs.net).

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

