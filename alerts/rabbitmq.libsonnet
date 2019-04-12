[
  {
    name: 'rabbitmq',
    rules: [
      {
        alert: 'RabbitMqMetricIsAbsent',
        annotations: {
          message: 'Looks like rabbitmq-exporter metrics are absent - either install collector or remove corresponding alerts'
        },
        expr: 'absent(rabbitmq_up) or
absent(rabbitmq_node_disk_free_alarm) or
absent(rabbitmq_node_mem_alarm) or
absent(rabbitmq_node_mem_used) or
absent(rabbitmq_partitions) or
absent(rabbitmq_queue_messages_ready) or
absent(rabbitmq_queue_consumers)',
        labels: {
          severity: 'critical',
        }
      },

      {
        alert: 'RabbitMqFewNodes',
        annotations: {
          message: 'Some RabbitMQ Cluster Nodes Are Down in Namespace {{ $labels.namespace }}',
        },
        expr: 'sum(rabbitmq_up) by (namespace) < 3',
        'for': '5m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'RabbitMqDiskSpaceAlarm',
        annotations: {
          message: 'RabbitMQ {{`{{ $labels.namespace }}`}}/{{`{{ $labels.pod}}`}} Disk Space Alarm is going off.  Which means the node hit highwater mark and has cut off network connectivity, see RabbitMQ WebUI',
        },
        expr: 'rabbitmq_node_disk_free_alarm == 1',
        'for': '1m',
        labels: {
          severity: 'critical',
        },
      },

      {
        alert: 'RabbitMqMemoryAlarm',
        annotations: {
          message: 'RabbitMQ {{`{{ $labels.namespace }}`}}/{{`{{ $labels.pod}}`}} High Memory Alarm is going off.  Which means the node hit highwater mark and has cut off network connectivity, see RabbitMQ WebUI',
        },
        expr: 'rabbitmq_node_mem_alarm == 1',
        'for': '1m',
        labels: {
          severity: 'critical',
        },
      },

      {
        alert: 'RabbitMqMemoryUsageHigh',
        annotations: {
          message: 'RabbitMQ {{`{{ $labels.namespace }}`}}/{{`{{ $labels.pod}}`}} Memory Usage > 90%',
        },
        expr: '(rabbitmq_node_mem_used / rabbitmq_node_mem_limit) > .9',
        'for': '1m',
        labels: {
          severity: 'critical',
        },
      },

      {
        alert: 'RabbitMqFileDescriptorsLow',
        annotations: {
          message: 'RabbitMQ {{`{{ $labels.namespace }}`}}/{{`{{ $labels.pod}}`}} File Descriptor Usage > 90%',
        },
        expr: '(rabbitmq_fd_used / rabbitmq_fd_total) > .9',
        'for': '5m',
        labels: {
          severity: 'critical',
        },
      },

      {
        alert: 'RabbitMqDiskSpaceLow',
        annotations: {
          message: 'RabbitMQ {{`{{ $labels.namespace }}`}}/{{`{{ $labels.pod}}`}} will hit disk limit in the next hr based on last 15 mins trend',
        },
        expr: 'predict_linear(rabbitmq_node_disk_free[15m], 1 * 60 * 60) < rabbitmq_node_disk_free_limit',
        'for': '5m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'RabbitMqClusterPartition',
        annotations: {
          message: 'Cluster partition VALUE = {{ $value }} LABELS: {{ $labels }}',
        },
        expr: 'rabbitmq_partitions{} > 0',
        'for': '30m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'RabbitMqTooManyConnections',
        annotations: {
          message: 'RabbitMQ instance has too many connections (> 1000) VALUE = {{ $value }} LABELS: {{ $labels }}',
        },
        expr: 'rabbitmq_connectionsTotal{} > 1000',
        'for': '30m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'RabbitMqTooManyMessagesInQueue',
        annotations: {
          message: 'Queue is filling up (> 1000 msgs) VALUE = {{ $value }} LABELS: {{ $labels }}',
        },
        expr: 'rabbitmq_queue_messages_ready > 1000',
        'for': '30m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'RabbitMqSlowQueueConsuming',
        annotations: {
          message: 'Queue messages are consumed slowly (> 60s) VALUE = {{ $value }} LABELS: {{ $labels }}',
        },
        expr: 'time() - rabbitmq_queue_head_message_timestamp > 60',
        'for': '30m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'RabbitMqTooManyConsumers',
        annotations: {
          message: 'Queue should have < 30 consumers VALUE = {{ $value }} LABELS: {{ $labels }}',
        },
        expr: 'rabbitmq_queue_consumers{} > 30',
        'for': '30m',
        labels: {
          severity: 'warning',
        },
      },

    ]
  }
]
