[
  {
    name: 'RedisDown',
    description: 'Redis instance is down VALUE = {{ $value }} LABELS: {{ $labels }}',
    expr: 'redis_up == 0',
    wait: '30m',
    severity: 'warning',
  },

  {
    name: 'RedisOutOfMemory',
    description: 'Redis is running out of memory (> 90%) VALUE = {{ $value }} LABELS: {{ $labels }}',
    expr: 'redis_memory_used_bytes{} / redis_total_system_memory_bytes{} * 100 > 90',
    wait: '30m',
    severity: 'warning',
  },

  {
    name: 'RedisTooManyConnections',
    description: 'Redis instance has too many connections VALUE = {{ $value }} LABELS: {{ $labels }}',
    expr: 'redis_connected_clients{} > 100',
    wait: '30m',
    severity: 'warning',
  },

  {
    name: 'RedisNotEnoughConnections',
    description: 'Redis instance should have more connections (> 5) VALUE = {{ $value }} LABELS: {{ $labels }}',
    expr: 'redis_connected_clients{} < 5',
    wait: '30m',
    severity: 'warning',
  },

  {
    name: 'RedisRejectedConnections',
    description: 'Some connections to Redis has been rejected VALUE = {{ $value }} LABELS: {{ $labels }}',
    expr: 'increase(redis_rejected_connections_total{}[1m]) > 0',
    wait: '30m',
    severity: 'warning',
  },

]
