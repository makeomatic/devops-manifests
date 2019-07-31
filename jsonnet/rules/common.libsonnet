[
  {
    name: 'common',
    rules: [
      {
        alert: 'InstancesDown',
        annotations: {
          message: 'At least 50% instances of {{ $labels.job }} are down',
        },
        expr: 'avg(up) BY (job) < 0.5',
        'for': '10m',
        labels: {
          severity: 'warning',
        },
      },
      {
        alert: 'ProcessNearFDLimits',
        annotations: {
          message: 'Open file limits is about to end = {{ $value }} LABELS: {{ $labels }}'
        },
        expr: 'process_open_fds / process_max_fds > 0.9',
        'for': '10m',
        labels: {
          severity: 'warning',
        },
      },
    ]
  }
]
