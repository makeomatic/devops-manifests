// Set of default prometheus rules / alerts plus custom additional ones
//

// configure default kubernetes mixin
local mixin = import '../vendor/kubernetes-mixin/mixin.libsonnet';
local customMixin = mixin {
  _config+:: {
    // we disable alerts on k8s components presence as they are controlled by GKE itself
    jobs: {}
  }
};

// add own rules
local manifests = std.flattenArrays([
  customMixin.prometheusAlerts.groups,
  customMixin.prometheusRules.groups,
  import 'rules/alertmanager.libsonnet',
  import 'rules/node-exporter.libsonnet',
  import 'rules/postgresql.libsonnet',
  import 'rules/prometheus.libsonnet',
  import 'rules/rabbitmq.libsonnet',
  import 'rules/redis.libsonnet',
  import 'rules/common.libsonnet',
]);

// map all manifests to prometheus rule CRD
local mapper(item) = {
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'PrometheusRule',
  metadata: {
    name: item.name,
    namespace: 'monitoring',
    labels: {
      app: item.name
    },
  },
  spec: {
    groups: [{
      name: item.name,
      rules: item.rules,
    }],
  },
};

{
  apiVersion: 'v1',
  kind: 'List',
  items: std.map(mapper, manifests),
}
