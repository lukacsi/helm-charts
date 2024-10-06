# n.eko with STUNner example configuration

This Helm chart deploys the n.eko remote browser application along **STUNner**, a WebRTC media relay server, to help manage the deployment of n.eko.
**THIS IS NOT A DEMO AND SHOULD NOT BE USED IN A PRODUCTION ENVIRONMENT**

## Prerequisites

- Helm 3.x
- Kubernetes cluster (tested with minikube)
  
## Installation

To install the chart with the release name `my-release`, run:

```bash
helm repo add lukacsi https://lukacsi.github.io/helm-charts/charts
helm repo update
helm install my lukacsi/neko
```

This will install the application into your Kubernetes cluster, with the default values.

## Configuration

The following table lists the configurable parameters of the chart and their default values.

| Parameter                       | Description                                                             | Default                             | Kubeapps Clickable |
|---------------------------------|-------------------------------------------------------------------------|-------------------------------------|--------------------|
| `stunnerInstall`                | Install STUNner as a dependecy                                          | `true`                              | `✅`               |
| `image.repository`              | n.eko image repository                                                  | `docker.io/m1k1o/neko`              | `✅`               |
| `image.tag`                     | n.eko image tag                                                         | `firefox`                           | `✅`               |
| `image.pullPolicy`              | Image pull policy                                                       | `IfNotPresent`                      | `❌`               |
| `neko.screen`                   | Screen resolution and refresh rate                                      | `1280x720@30`                       | `✅`               |
| `neko.password`                 | Password for n.eko access                                               | `neko`                              | `✅`               |
| `neko.adminPassword`            | Admin password for n.eko                                                | `admin`                             | `✅`               |
| `neko.epr`                      | Range of ports for WebRTC                                               | `62001-62002`                       | `❌`               |
| `neko.icelite`                  | Enable or disable ICE Lite for WebRTC                                   | `false`                             | `❌`               |
| `configMapName`                 | Name of the ConfigMap for the n.eko ICE server                          | `neko-iceserver`                    | `❌`               |
| `initScriptConfigMap`           | ConfigMap name for initializing scripts                                 | `init-script`                       | `❌`               |
| `service.type`                  | Type of Kubernetes service to expose n.eko                              | `LoadBalancer`                      | `✅`               |
| `service.port`                  | Service port for n.eko                                                  | `8080`                              | `✅`               |
| `service.udpPorts`              | UDP ports for WebRTC                                                    | `[62001, 62002]`                    | `❌`               |
| `ingress.enabled`               | Enable Ingress resource                                                 | `false`                             | `✅`               |
| `ingress.ingressClassName`      | Ingress class to use                                                    | `nginx`                             | `✅`               |
| `ingress.annotations`           | Annotations for the Ingress resource                                    | `{kubernetes.io/ingress.class: nginx}` | `✅`               |
| `ingress.hosts`                 | List of hosts for the Ingress resource                                  | `neko.192.168.49.2.nip.io`          | `✅`               |
| `ingress.hosts.paths`           | Paths for the Ingress resource                                          | `/` (pathType: Prefix)              | `✅`               |
| `ipset`                         | Enable automatic ICE server ip aquisition                               | `true`                              | `✅`               |
| `serviceAccount.name`           | Name of the ServiceAccount to use                                       | `neko-iceserver-sa`                 | `❌`               |
| `roles.configMapUpdater.name`   | Role name for updating ConfigMap                                        | `neko-cm`                           | `❌`               |
| `roles.serviceViewer.name`      | Role name for viewing services                                          | `neko-svc-viewer`                   | `❌`               |
| `roles.deploymentViewer.name`   | Role name for viewing deployments                                       | `neko-dep-viewer`                   | `❌`               |


You can modify the default values by specifying them in the `values.yaml` file or by using the `--set` flag when installing/upgrading the chart:

```bash
helm install my-release lukacsi/neko --set image.tag=kde
# OR
helm install my-release lukacsi/neko -f values.yaml
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment, run:

```bash
helm delete my-release
```

This removes all Kubernetes components associated with the chart.

## Upgrading the Chart

To upgrade the release to a new version, run:

```bash
helm upgrade my-release lukacsi/neko
```

## Automatic ICE server ip aquisition

If ipset is set to true, the chart will automatically pass the ICE servers ip to the neko pod, but this will deploy additional RBAC configurations.

If you would like to set the IP yourself run the following script:

```bash
STUNNERIP=""; while [ -z "$STUNNERIP" ]; do STUNNERIP=$(kubectl get service my-release-neko-udp-gateway  -o jsonpath='{.status.loadBalancer.ingress[0].ip}'); if [ -z "$STUNNERIP" ]; then echo "Waiting for external IP..."; sleep 10; fi; done; kubectl set env  deployment/my-release-neko NEKO_ICESERVERS="[{\"urls\": [\"turn:${STUNNERIP}:3478?transport=udp\"], \"username\": \"user-1\", \"credential\": \"pass-1\", \"iceTransportPolicy\": \"all\"}]"; kubectl rollout restart deployment my-release-neko
```

### What it does:

Waits for the ip of the udp gateway.
Sets up the NEKO_ICESERVERS environvent variable with the ip.
Restart the deployment with the new environvent variable.

## Todo

`❌` rename tag to app and add enums to scheme.

`❌` Comment template

`❌` more info for ipset