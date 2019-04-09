{
  'prometheus': {
    namespace: 'monitoring',
    chart: 'stable/prometheus-operator',
    version: '5.x'
  },

  'karma': {
    namespace: 'test',
    chart: 'stable/karma',
    version: '1.x'
  },

  'elasticsearch': {
    namespace: 'monitoring',
    chart: 'stable/elasticsearch',
    version: '1.x'
  },

  'fluentbit': {
    namespace: 'monitoring',
    chart: 'stable/fluent-bit',
    version: '1.x'
  },

  'kibana': {
    namespace: 'monitoring',
    chart: 'stable/kibana',
    version: '2.x'
  },

  'kube-eagle': {
    namespace: 'monitoring',
    chart: 'kube-eagle/kube-eagle',
    version: '1.x'
  },

  'elasticsearch-curator': {
    namespace: 'monitoring',
    chart: 'stable/elasticsearch-curator',
    version: '1.x'
  },

  'grafana': {
    namespace: 'monitoring',
    chart: 'stable/grafana',
    version: '3.x'
  },

  'istio': {
    namespace: 'istio-system',
    chart: 'makeomatic/istio',
    version: '1.1.0',
    customizeRequred: true
  },

  'openvpn': {
    namespace: 'default',
    chart: 'stable/openvpn',
    version: '3.x'
  },

  'nginx-ingress': {
    namespace: 'default',
    chart: 'stable/nginx-ingress',
    version: '1.x',
    customizeRequred: true
  },

  'cert-manager': {
    namespace: 'default',
    chart: 'stable/cert-manager',
    version: '0.x'
  },

  'concourse-ci': {
    namespace: 'default',
    chart: 'stable/concourse',
    version: '5.x',
    customizeRequred: true
  },

  'keel': {
    namespace: 'default',
    chart: 'keel/keel',
    version: '0.x',
    customizeRequred: true
  },

  'chatbot': {
    namespace: 'default',
    chart: 'makeomatic/installer',
    version: '1.x',
    customizeRequred: true
  },

  'consul': {
    namespace: 'default',
    chart: 'makeomatic/consul',
    version: '0.x.0'
  },

  'loki': {
    namespace: 'default',
    chart: 'makeomatic/loki',
    version: '0.x'
  },

  'stolon': {
    namespace: 'default',
    chart: 'stable/stolon',
    version: '1.x'
  },

  'amqp': {
    namespace: 'default',
    chart: 'stable/rabbitmq-ha',
    version: '1.x'
  },

  'redis': {
    namespace: 'default',
    chart: 'stable/redis-ha',
    version: '3.x'
  },
}
