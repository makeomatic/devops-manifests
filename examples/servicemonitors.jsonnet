local servicemonitors = import '../jsonnet/servicemonitors.libsonnet';
local manifests = [
  {
    name: 'postgres',
    namespace: 'default',
    port: 'http',
    labels: {
      app: 'prometheus-postgres-exporter'
    }
  }
];

servicemonitors + {
  manifests: manifests
}
