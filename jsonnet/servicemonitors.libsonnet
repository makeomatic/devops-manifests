// Set of default prometheus rules / alerts plus custom additional ones
// https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#servicemonitorspec

// map all manifests to prometheus rule CRD
local mapper(item) = {
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: item.name,
    namespace: 'monitoring',
    labels: {
      app: item.name,
    },
  },
  spec: {
    selector: {
      matchLabels: item.labels,
    },
    namespaceSelector: {
      matchNames: [item.namespace],
    },
    endpoints: [
      {
        interval: '10s',
      } + if std.isString(item.port) then { port: item.port } else { targetPort: item.port },
    ],
  },
};

{
  manifests:: error 'should specify .items field',

  apiVersion: 'v1',
  kind: 'List',
  items: std.map(mapper, $.manifests),
}
