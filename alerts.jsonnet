local mixin = import 'vendor/kubernetes-mixin/mixin.libsonnet';
local mixinRules = mixin {
  _config+:: {
    jobs: {
      Kubelet: $._config.kubeletSelector,
    }
  }
}.prometheusAlerts.groups;

local alerts = std.flattenArrays([
  mixinRules,
  import 'alerts/alertmanager.libsonnet',
  import 'alerts/node-exporter.libsonnet',
  import 'alerts/postgresql.libsonnet',
  import 'alerts/prometheus.libsonnet',
  import 'alerts/rabbitmq.libsonnet',
  import 'alerts/redis.libsonnet',
]);


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

std.map(mapper, alerts)
