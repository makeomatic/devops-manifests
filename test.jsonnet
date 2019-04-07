local template = import "helmfile.libsonnet";
template {
  services: [
    // 'cert-manager',
    'chatbot',
    // 'concourse-ci',
    // 'consul',
    // 'curator-monitoring',
    // 'elasticsearch-monitoring',
    // 'fluentbit',
    // 'grafana',
    // 'istio',
    // 'karma',
    // 'keel',
    // 'kibana',
    // 'kube-eagle',
    // 'loki',
    // 'nginx-ingress',
    // 'openvpn',
    // 'prometheus',
  ],
  customize: {
    chatbot: {
      version: '1.x',
      values: ['test/somevalues.yml'],
    },
  },
}
