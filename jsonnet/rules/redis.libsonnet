[
  {
    name: 'redis',
    rules: [
      {
        alert: 'RedisDown',
        annotations: {
          message: 'Redis instance is down VALUE = {{ $value }} LABELS: {{ $labels }}',
        },
        expr: 'redis_up == 0',
        'for': '30m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'RedisOutOfMemory',
        annotations: {
          message: 'Redis is running out of memory (> 90%) VALUE = {{ $value }} LABELS: {{ $labels }}',
        },
        expr: 'redis_memory_used_bytes{} / redis_total_system_memory_bytes{} * 100 > 90',
        'for': '30m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'RedisTooManyConnections',
        annotations: {
          message: 'Redis instance has too many connections VALUE = {{ $value }} LABELS: {{ $labels }}',
        },
        expr: 'redis_connected_clients{} > 100',
        'for': '30m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'RedisNotEnoughConnections',
        annotations: {
          message: 'Redis instance should have more connections (> 5) VALUE = {{ $value }} LABELS: {{ $labels }}',
        },
        expr: 'redis_connected_clients{} < 5',
        'for': '30m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'RedisRejectedConnections',
        annotations: {
          message: 'Some connections to Redis has been rejected VALUE = {{ $value }} LABELS: {{ $labels }}',
        },
        expr: 'increase(redis_rejected_connections_total{}[1m]) > 0',
        'for': '30m',
        labels: {
          severity: 'warning',
        },
      },

    ]
  }
]
