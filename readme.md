# Initial config
```
brew install jsonnet
brew install kubecfg
go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
```

# Tasks
## Sync prometheus rules
```
jb update
kubecfg update jsonnet/prometheus.jsonnet
```
## Update grafana dashboards
```
jb update
jsonnet -J vendor -m dashboards vendor/kubernetes-mixin/lib/dashboards.jsonnet
```
