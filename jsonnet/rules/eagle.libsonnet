[
  {
    name: 'eagle',
    rules: [
      {
        alert: 'EagleNodeCPUHigh',
        annotations: {
          message: 'Amount of CPUs requested on node {{ $labels.node }} is {{ printf "%0.0f" $value }}% of allowed.',
        },
        expr: '(sum(eagle_node_resource_requests_cpu_cores) by (node) / sum(eagle_node_resource_allocatable_cpu_cores) by (node)) * 100 > 90',
        'for': '30m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'EagleNodeMemoryHigh',
        annotations: {
          message: 'Amount of memory requested on node {{ $labels.node }} is {{ printf "%0.0f" $value }}% of allowed.',
        },
        expr: '(sum(eagle_node_resource_requests_memory_bytes) by (node) / sum(eagle_node_resource_allocatable_memory_bytes) by (node)) * 100 > 90',
        'for': '30m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'EaglePodCPUOvercommitted',
        annotations: {
          message: 'Pod {{ $labels.exported_namespace }}/{{ $labels.exported_pod }} uses {{ printf "%0.0f" $value }}% of requested CPU.',
        },
        expr: '(sum(eagle_pod_container_resource_usage_cpu_cores) by (exported_pod, exported_namespace) / sum(eagle_pod_container_resource_requests_cpu_cores > 0) by (exported_pod, exported_namespace)) * 100  > 100',
        'for': '10m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'EaglePodMemoryOvercommitted',
        annotations: {
          message: 'Pod {{ $labels.exported_namespace }}/{{ $labels.exported_pod }} uses {{ printf "%0.0f" $value }}% of requested memory.',
        },
        expr: '(sum(eagle_pod_container_resource_usage_memory_bytes) by (exported_pod, exported_namespace) / sum(eagle_pod_container_resource_requests_memory_bytes > 0) by (exported_pod, exported_namespace)) * 100 > 100',
        'for': '10m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'EaglePodCPUHigh',
        annotations: {
          message: 'Pod {{ $labels.exported_namespace }}/{{ $labels.exported_pod }} uses {{ printf "%0.0f" $value }}% of allowed CPU.',
        },
        expr: '(sum(eagle_pod_container_resource_usage_cpu_cores) by (exported_pod, exported_namespace) / sum(eagle_pod_container_resource_limits_cpu_cores > 0) by (exported_pod, exported_namespace)) * 100 > 90',
        'for': '10m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'EaglePodMemoryHigh',
        annotations: {
          message: 'Pod {{ $labels.exported_namespace }}/{{ $labels.exported_pod }} uses {{ printf "%0.0f" $value }}% of allowed memory.',
        },
        expr: '(sum(eagle_pod_container_resource_usage_memory_bytes) by (exported_pod, exported_namespace) / sum(eagle_pod_container_resource_limits_memory_bytes > 0) by (exported_pod, exported_namespace)) * 100 > 99',
        'for': '10m',
        labels: {
          severity: 'warning',
        },
      },

    ],
  },
]
