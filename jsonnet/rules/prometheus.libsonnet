[
  {
    name: 'prometheus',
    rules: [
      {
        alert: 'PrometheusOperatorReconcileErrors',
        annotations: {
          message: 'Errors while reconciling {{ $labels.controller }} in {{ $labels.namespace}} Namespace',
        },
        expr: 'rate(prometheus_operator_reconcile_errors_total{job="prometheus-operator",namespace="monitoring"}[5m]) > 0.1',
        'for': '10m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'PrometheusOperatorNodeLookupErrors',
        annotations: {
          message: 'Errors while reconciling Prometheus in {{ $labels.namespace }} Namespace',
        },
        expr: 'rate(prometheus_operator_node_address_lookup_errors_total{job="prometheus-operator",namespace="monitoring"}[5m]) > 0.1',
        'for': '10m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'PrometheusConfigReloadFailed',
        annotations: {
          message: 'Reloading Prometheus configuration has failed for {{$labels.namespace}}/{{$labels.pod}}',
        },
        expr: 'prometheus_config_last_reload_successful{job="prometheus-prometheus",namespace="monitoring"} == 0',
        'for': '10m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'PrometheusNotificationQueueRunningFull',
        annotations: {
          message: 'Prometheus alert notification queue is running full for {{$labels.namespace}}/{{$labels.pod}}',
        },
        expr: 'predict_linear(prometheus_notifications_queue_length{job="prometheus-prometheus",namespace="monitoring"}[5m], 60 * 30) > prometheus_notifications_queue_capacity{job="prometheus-prometheus",namespace="monitoring"}',
        'for': '10m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'PrometheusErrorSendingAlerts',
        annotations: {
          message: 'Errors while sending alerts from Prometheus {{$labels.namespace}}/{{$labels.pod}} to Alertmanager {{$labels.Alertmanager}}',
        },
        expr: 'rate(prometheus_notifications_errors_total{job="prometheus-prometheus",namespace="monitoring"}[5m]) / rate(prometheus_notifications_sent_total{job="prometheus-prometheus",namespace="monitoring"}[5m]) > 0.01',
        'for': '10m',
        labels: {
          severity: 'critical',
        },
      },

      {
        alert: 'PrometheusNotConnectedToAlertmanagers',
        annotations: {
          message: 'Prometheus {{ $labels.namespace }}/{{ $labels.pod}} is not connected to any Alertmanagers',
        },
        expr: 'prometheus_notifications_alertmanagers_discovered{job="prometheus-prometheus",namespace="monitoring"} < 1',
        'for': '10m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'PrometheusNotIngestingSamples',
        annotations: {
          message: 'Prometheus {{ $labels.namespace }}/{{ $labels.pod}} isnt ingesting samples',
        },
        expr: 'rate(prometheus_tsdb_head_samples_appended_total{job="prometheus-prometheus",namespace="monitoring"}[5m]) <= 0',
        'for': '10m',
        labels: {
          severity:  'warning',
        },
      },

      {
        alert: 'PrometheusTargetScrapesDuplicate',
        annotations: {
          message: '{{$labels.namespace}}/{{$labels.pod}} has many samples rejected due to duplicate timestamps but different values',
        },
        expr: 'increase(prometheus_target_scrapes_sample_duplicate_timestamp_total{job="prometheus-prometheus",namespace="monitoring"}[5m]) > 0',
        'for': '10m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'PrometheusRuleEvalFailures',
        annotations: {
          message: '{{$labels.job}} at {{$labels.instance}} has failing rule evaluations, please check logs',
        },
        expr: 'increase(prometheus_rule_evaluation_failures_total[5m]) > 0',
        labels: {
          severity: 'warning',
        },
      },

    ]
  }
]
