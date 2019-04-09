[
  {
    name: 'RabbitMqFewNodes',
    description: 'Some RabbitMQ Cluster Nodes Are Down in Namespace {{ $labels.namespace }}',
    expr: 'sum((rabbitmq_up) by (namespace)) < 3',
    wait: '5m',
    severity: 'warning',
  },

  {
    name: 'RabbitMqDiskSpaceAlarm',
    description: 'RabbitMQ {{`{{ $labels.namespace }}`}}/{{`{{ $labels.pod}}`}} Disk Space Alarm is going off.  Which means the node hit highwater mark and has cut off network connectivity, see RabbitMQ WebUI',
    expr: 'rabbitmq_node_disk_free_alarm == 1',
    wait: '1m',
    severity: 'critical',
  },

  {
    name: 'RabbitMqMemoryAlarm',
    description: 'RabbitMQ {{`{{ $labels.namespace }}`}}/{{`{{ $labels.pod}}`}} High Memory Alarm is going off.  Which means the node hit highwater mark and has cut off network connectivity, see RabbitMQ WebUI',
    expr: 'rabbitmq_node_mem_alarm == 1',
    wait: '1m',
    severity: 'critical',
  },

  {
    name: 'RabbitMqMemoryUsageHigh',
    description: 'RabbitMQ {{`{{ $labels.namespace }}`}}/{{`{{ $labels.pod}}`}} Memory Usage > 90%',
    expr: '(rabbitmq_node_mem_used / rabbitmq_node_mem_limit) > .9',
    wait: '1m',
    severity: 'critical',
  },

  {
    name: 'RabbitMqFileDescriptorsLow',
    description: 'RabbitMQ {{`{{ $labels.namespace }}`}}/{{`{{ $labels.pod}}`}} File Descriptor Usage > 90%',
    expr: '(rabbitmq_fd_used / rabbitmq_fd_total) > .9',
    wait: '5m',
    severity: 'critical',
  },

  {
    name: 'RabbitMqDiskSpaceLow',
    description: 'RabbitMQ {{`{{ $labels.namespace }}`}}/{{`{{ $labels.pod}}`}} will hit disk limit in the next hr based on last 15 mins trend',
    expr: 'predict_linear(rabbitmq_node_disk_free[15m], 1 * 60 * 60) < rabbitmq_node_disk_free_limit',
    wait: '5m',
    severity: 'warning',
  },

  {
    name: 'RabbitMqClusterPartition',
    description: 'Cluster partition VALUE = {{ $value }} LABELS: {{ $labels }}',
    expr: 'rabbitmq_partitions{} > 0',
    wait: '30m',
    severity: 'warning',
  },

  {
    name: 'RabbitMqTooManyConnections',
    description: 'RabbitMQ instance has too many connections (> 1000) VALUE = {{ $value }} LABELS: {{ $labels }}',
    expr: 'rabbitmq_connectionsTotal{} > 1000',
    wait: '30m',
    severity: 'warning',
  },

  {
    name: 'RabbitMqTooManyMessagesInQueue',
    description: 'Queue is filling up (> 1000 msgs) VALUE = {{ $value }} LABELS: {{ $labels }}',
    expr: 'rabbitmq_queue_messages_ready > 1000',
    wait: '30m',
    severity: 'warning',
  },

  {
    name: 'RabbitMqSlowQueueConsuming',
    description: 'Queue messages are consumed slowly (> 60s) VALUE = {{ $value }} LABELS: {{ $labels }}',
    expr: 'time() - rabbitmq_queue_head_message_timestamp > 60',
    wait: '30m',
    severity: 'warning',
  },

  {
    name: 'RabbitMqTooManyConsumers',
    description: 'Queue should have < 30 consumers VALUE = {{ $value }} LABELS: {{ $labels }}',
    expr: 'rabbitmq_queue_consumers{} > 30',
    wait: '30m',
    severity: 'warning',
  },

]
