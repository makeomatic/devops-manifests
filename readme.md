# Setup environment
```
brew install jsonnet
go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb

jb update
```

# Apply alermanager rules for prometheus-operator
```
jsonnet alerts.jsonnet -y | kubectl apply -f -
```
