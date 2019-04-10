// jsonnet alerts.jsonnet -y | kubectl apply -f -
local template = import './alerts/alert.libsonnet';
local rules = {
  'alertmanager': import './alerts/alertmanager.jsonnet',
  'kube-state-metrics': import './alerts/kube-state-metrics.jsonnet',
  'kubelet': import './alerts/kubelet.jsonnet',
  'node-exporter': import './alerts/node-exporter.jsonnet',
  'prometheus': import './alerts/prometheus.jsonnet',
  'rabbitmq': import './alerts/rabbitmq.jsonnet',
  'redis': import './alerts/redis.jsonnet',
};

local mapper(name) = template {
  name: name,
  rules: rules[name],
};

local alertNames = std.objectFields(rules);
std.map(mapper, alertNames)
