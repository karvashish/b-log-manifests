# b-log on Kubernetes (README.txt)

## Overview

* Go app with file upload.
* PostgreSQL for storage.
* NATS with JetStream for events.
* Ingress via NGINX.
* Subject: `b_log.uploaded`.
* JetStream domain: `prod`.

## Deploy

```bash
kubectl create ns b-log
helm upgrade --install b-log . -n b-log -f values.yaml
kubectl -n b-log get pods
```

## Access

```bash
kubectl -n b-log get ingress
# open http://<ingress-host>/upload
```

## Verify NATS events (fast path)

Prereq: `natsBox` enabled.

Set helpers:

```bash
NS=b-log
SVC=$(kubectl -n $NS get svc -l app.kubernetes.io/name=nats -o jsonpath='{.items[0].metadata.name}')
BOX=$(kubectl -n $NS get deploy -o name | grep nats-box | cut -d/ -f2)
```

Live subscribe (new messages only):

```bash
kubectl -n $NS exec -it deploy/$BOX -- nats -s nats://$SVC:4222 sub 'b_log.uploaded'
```

Trigger:

* Upload any file at `/upload`.
* The subscriber prints a JSON event.

## Check persistence (JetStream)

Stream info:

```bash
kubectl -n $NS exec -it deploy/$BOX -- \
  nats -s nats://$SVC:4222 --js-domain prod stream info uploads
```

View stored messages:

```bash
kubectl -n $NS exec -it deploy/$BOX -- \
  nats -s nats://$SVC:4222 --js-domain prod stream view uploads --since 10m
```

## App settings (from values)

* Image: `kartikeyavashishtha/b-log:latest` with `pullPolicy: Always`.
* `app.port=8080`, `app.seedBlog=true`, `app.standaloneStartup=false`.
* PostgreSQL standalone with 5Gi PVC.
* NATS single-server with JetStream file store 8Gi PVC. Domain `prod`.

## Notes

* Core `sub` shows only new messages. No replay.
* JetStream commands require `--js-domain prod`.
* “no responders available” usually means wrong service URL, domain mismatch, or JetStream not ready.
* For single node JetStream, disable clustering. For a cluster, use 3 replicas.

## Teardown

```bash
helm -n b-log uninstall b-log
kubectl delete ns b-log
```

## Reduced one-liners

```bash
NS=b-log; SVC=$(kubectl -n $NS get svc -l app.kubernetes.io/name=nats -o jsonpath='{.items[0].metadata.name}'); BOX=$(kubectl -n $NS get deploy -o name | grep nats-box | cut -d/ -f2)
kubectl -n $NS exec -it deploy/$BOX -- nats -s nats://$SVC:4222 sub 'b_log.uploaded'
kubectl -n $NS exec -it deploy/$BOX -- nats -s nats://$SVC:4222 --js-domain prod stream info uploads
kubectl -n $NS exec -it deploy/$BOX -- nats -s nats://$SVC:4222 --js-domain prod stream view uploads --since 10m
```
