[
  {
    name: 'kube-eagle',
    rules: [
      {
        alert: 'EagleMemoryRequestExceed',
        annotations: {
          message: 'Pod {{$labels.namespace}}/{{$labels.exported_pod}} exceeded requested memory by {{$value}}%. It may affect resource planning',
        },
        expr: '(sum (eagle_pod_container_resource_usage_memory_bytes) by (exported_pod, namespace) * 100) / ((sum (eagle_pod_container_resource_requests_memory_bytes) by (exported_pod, namespace)) > 0) > 100',
        'for': '5m',
        labels: {
          severity: 'warning',
        }
      },

      {
        alert: 'EagleCpuRequestExceed',
        annotations: {
          message: 'Pod {{$labels.namespace}}/{{$labels.exported_pod}} exceeded requested CPUs by {{$value}}%. It may affect resource planning',
        },
        expr: '(sum (eagle_pod_container_resource_usage_cpu_cores) by (exported_pod, namespace) * 100) / ((sum (eagle_pod_container_resource_requests_cpu_cores) by (exported_pod, namespace)) > 0) > 100',
        'for': '5m',
        labels: {
          severity: 'warning',
        }
      },

      {
        alert: 'EagleMemoryLowUsage',
        annotations: {
          message: 'Pod {{$labels.namespace}}/{{$labels.exported_pod}} uses only {{$value}}% of requested memory. It may affect resource planning',
        },
        expr: '(sum (eagle_pod_container_resource_usage_memory_bytes) by (exported_pod, namespace) * 100) / ((sum (eagle_pod_container_resource_requests_memory_bytes) by (exported_pod, namespace))) < 10',
        'for': '5m',
        labels: {
          severity: 'warning',
        }
      },

      {
        alert: 'EagleCPULowUsage',
        annotations: {
          message: 'Pod {{$labels.namespace}}/{{$labels.exported_pod}} uses only {{$value}}% of requested CPUs. It may affect resource planning',
        },
        expr: '(sum (eagle_pod_container_resource_usage_cpu_cores) by (exported_pod, namespace) * 100) / ((sum (eagle_pod_container_resource_requests_cpu_cores) by (exported_pod, namespace))) < 10',
        'for': '5m',
        labels: {
          severity: 'warning',
        }
      },

      {
        alert: 'EagleMemoryOverUsed',
        annotations: {
          message: 'Pod {{$labels.namespace}}/{{$labels.exported_pod}} uses {{$value}}% of allowed memory limit. It may affect service perormance or instance may be OOMkilled',
        },
        expr: '(sum (eagle_pod_container_resource_usage_memory_bytes) by (exported_pod, namespace) * 100) / ((sum (eagle_pod_container_resource_limits_memory_bytes) by (exported_pod, namespace)) > 0) > 90',
        'for': '5m',
        labels: {
          severity: 'warning',
        }
      },

      {
        alert: 'EagleCPUOverUsed',
        annotations: {
          message: 'Pod {{$labels.namespace}}/{{$labels.exported_pod}} uses {{$value}}% of allowed CPUs limit. It may affect service perormance',
        },
        expr: '(sum (eagle_pod_container_resource_usage_cpu_cores) by (exported_pod, namespace) * 100) / ((sum (eagle_pod_container_resource_limits_cpu_cores) by (exported_pod, namespace)) > 0) > 90',
        'for': '5m',
        labels: {
          severity: 'warning',
        }
      },

    ],
  },
]
