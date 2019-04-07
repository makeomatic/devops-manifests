{
  prometheus: {
    namespace: 'monitoring',
    chart: 'stable/prometheus-operator',
    version: '5.x',
    values: ['values/prometheus.yml'],
  },

  karma: {
    namespace: 'test',
    chart: 'stable/karma',
    version: '1.x',
    values: ['values/karma.yml'],
  },

  'elasticsearch-monitoring': {
    namespace: 'monitoring',
    chart: 'stable/elasticsearch',
    version: '1.x'
  },

  'fluent-bit': {
    namespace: 'monitoring',
    chart: 'stable/fluent-bit',
    version: '1.x',
    values: ['values/fluent-bit.yml']
  },

  kibana: {
    namespace: 'monitoring',
    chart: 'stable/kibana',
    version: '2.x',
    values: ['values/kibana.yml']
  },

  'kube-eagle': {
    namespace: 'monitoring',
    chart: 'kube-eagle/kube-eagle',
    version: '1.x',
    values: ['values/kube-eagle.yml']
  },

  'elasticsearch-curator': {
    namespace: 'monitoring',
    chart: 'stable/elasticsearch-curator',
    version: '1.x',
    values: ['values/elasticsearch-curator.yml']
  },

  'grafana': {
    namespace: 'monitoring',
    chart: 'stable/grafana',
    version: '3.x',
    values: ['values/grafana.yml']
  },

  'istio': {
    namespace: 'istio-system',
    chart: 'makeomatic/istio',
    version: '1.1.0',
    values: ['values/istio.yml']
  },

  'openvpn': {
    namespace: 'default',
    chart: 'stable/openvpn',
    version: '3.x',
    values: ['values/openvpn.yml']
  },

  'nginx-ingress': {
    namespace: 'default',
    chart: 'stable/nginx-ingress',
    version: '1.x',
    values: ['values/nginx-ingress.yml']
  },

  'cert-manager': {
    namespace: 'default',
    chart: 'stable/cert-manager',
    version: '0.x',
    values: ['values/cert-manager.yml']
  },

  'concourse-ci': {
    namespace: 'default',
    chart: 'stable/concourse',
    version: '5.x',
    values: ['values/concourse.yml']
  },

  'keel': {
    namespace: 'default',
    chart: 'keel/keel',
    version: '0.x',
    values: ['values/keel.yml'],
    customizeRequred: true
  },

  'chatbot': {
    namespace: 'default',
    chart: 'makeomatic/bishop',
    version: '1.x',
    values: ['values/chatbot.yml'],
    customizeRequred: true
  }
}
