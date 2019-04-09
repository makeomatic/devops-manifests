[
  {
    name: 'AlertmanagerConfigInconsistent',
    description: 'The configuration of the instances of the Alertmanager cluster `{{$labels.service}}` are out of sync',
    expr: 'count_values("config_hash", alertmanager_config_hash{job="prometheus-alertmanager",namespace="monitoring"}) BY (service) / ON(service) GROUP_LEFT() label_replace(prometheus_operator_spec_replicas{job="prometheus-operator",namespace="monitoring",controller="alertmanager"}, "service", "$1", "name", "(.*)") != 1',
    wait: '5m',
    severity: 'critical',
  },

  {
    name: 'AlertmanagerFailedReload',
    description: 'Reloading Alertmanager configuration has failed for {{ $labels.namespace}}/{{ $labels.pod}}',
    expr: 'alertmanager_config_last_reload_successful{job="prometheus-alertmanager",namespace="monitoring"} == 0',
    wait: '10m',
    severity: 'warning',
  },

  {
    name: 'AlertmanagerMembersInconsistent',
    description: 'Alertmanager has not found all other members of the cluster',
    expr: 'alertmanager_cluster_members{job="prometheus-alertmanager",namespace="monitoring"} != on (service) GROUP_LEFT() count by (service) (alertmanager_cluster_members{job="prometheus-alertmanager",namespace="monitoring"})',
    wait: '5m',
    severity: 'critical',
  },

  {
    name: 'Watchdog',
    description: 'This is an alert meant to ensure that the entire alerting pipeline is functional. This alert is always firing, therefore it should always be firing in Alertmanager and always fire against a receiver. There are integrations with various notification mechanisms that send a notification when this alert is not firing. For example the "DeadMansSnitch" integration in PagerDuty.',
    expr: 'vector(1)',
    severity: 'none',
  },

]
