local helmfile = import "helm/helmfile.libsonnet";

helmfile {

  // directory with default services values
  valuesPath: 'helm/values',

  // set of installed services
  services: [

    // COMMON SERVICES
    // service which generates tls certificates using letsencrypt
    'cert-manager',
    // custom makeomatic chatops bot for notifications
    'chatbot',
    // continitous integration system to watch for and deploy releases
    'concourse-ci',
    // distributed key-value storage to store common configurations
    'consul',
    // ingress controller which handle incoming trafic (except microfleet-based)
    'nginx-ingress',
    // ability to connect to the cluster for debug purposes
    'openvpn',
    // servicemesh which handle incoming requests and sends them to microfleet services
    // also handle stuff like tracing etc
    'istio',
    // utility for automatical tracking and syncing of latest infrastructure releases
    'keel',

    // LOGGING
    // helper which delete old elasticsearch logs
    'elasticsearch-curator',
    // elsasticsearch database to store logs
    'elasticsearch',
    // daemonset which collects logs from docker images and forward them to elasticsearch
    'fluentbit',
    // GUI to display and parse collected logs
    'kibana',
    // alternative all-in-one logs collector
    'loki',

    // MONITORING
    // metrics and alerts collector
    'prometheus',
    // GUI to display dasboard based on metrics
    'grafana',
    // GUI to display currently fired alerts
    'karma',
    // common service stats collector, this data are available in grafana
    'kube-eagle',

    // BUSINESS-RELATED SERVICES
    // storage for tinode chat service
    'rethinkdb',
    // postgresql storage for the business data
    'stolon',
    // prometheus metrics exporter
    'postgres-exporter',
    // key-value storage for the business data
    'redis',
    // common queue for microfleet services interaction
    'amqp',
    // chat service
    'tinode',
  ],
  customize: {
    elasticsearch: {
      name: 'elasticsearch-monitoring',
      namespace: 'monitoring'
    },
    'concourse-ci': {
      values: ['values/concourse-ci.yml'],
    },
    istio: {
      values: ['values/istio.yml'],
    },
    'nginx-ingress': {
      values: ['values/nginx-ingress.yml'],
    },
    rethinkdb: {
      namespace: 'default',
      chart: 'stable/rethinkdb',
      version: '0.2.x',
      values: ['values/rethinkdb.yml'],
    },
    amqp: {
      name: 'amqp-staging',
      namespace: 'staging',
      values: ['values/amqp.yml'],
    },
    redis: {
      name: 'redis-staging',
      namespace: 'staging',
    },
    tinode: {
      name: 'tinode-staging',
      namespace: 'sl-staging',
      chart: 'makeomatic/installer',
      version: '1.x',
      values: ['values/tinode.yml'],
    },
  },
}
