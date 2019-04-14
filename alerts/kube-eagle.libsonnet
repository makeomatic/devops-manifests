// NOTE: some alerts have been disabled as they spams lots of warnings, better to watch it in kube-eagle dashboard

[
  {
    name: 'kube-eagle',
    rules: [
      {
        alert: 'EagleMetricIsAbsent',
        annotations: {
          message: 'Looks like kube-eagle metrics are absent - either install collector or remove corresponding alerts'
        },
        expr: 'absent(eagle_pod_container_resource_usage_memory_bytes) or
absent(eagle_pod_container_resource_requests_memory_bytes) or
absent(eagle_pod_container_resource_limits_memory_bytes) or
absent(eagle_pod_container_resource_usage_cpu_cores) or
absent(eagle_pod_container_resource_requests_cpu_cores) or
absent(eagle_pod_container_resource_limits_cpu_cores)',
        labels: {
          severity: 'critical',
        }
      },

      {
        alert: 'EagleMemoryRequestExceed',
        annotations: {
          message: 'Container {{$labels.namespace}}/{{$labels.exported_pod}}/{{$labels.container}}, exceeded requested memory by {{printf "%.2f" $value}}%. It may affect resource planning',
        },
        expr: '(sum (eagle_pod_container_resource_usage_memory_bytes) by (exported_pod, namespace, container) * 100) / ((sum (eagle_pod_container_resource_requests_memory_bytes) by (exported_pod, namespace, container)) > 0) > 100',
        'for': '5m',
        labels: {
          severity: 'warning',
        }
      },

      {
        alert: 'EagleCpuRequestExceed',
        annotations: {
          message: 'Container {{$labels.namespace}}/{{$labels.exported_pod}}/{{$labels.container}} exceeded requested CPUs by {{printf "%.2f" $value}}%. It may affect resource planning',
        },
        expr: '(sum (eagle_pod_container_resource_usage_cpu_cores) by (exported_pod, namespace, container) * 100) / ((sum (eagle_pod_container_resource_requests_cpu_cores) by (exported_pod, namespace, container)) > 0) > 100',
        'for': '5m',
        labels: {
          severity: 'warning',
        }
      },

      // {
      //   alert: 'EagleMemoryLowUsage',
      //   annotations: {
      //     message: 'Container {{$labels.namespace}}/{{$labels.exported_pod}}/{{$labels.container}} uses only {{printf "%.2f" $value}}% of requested memory. It may affect resource planning',
      //   },
      //   expr: '(sum (eagle_pod_container_resource_usage_memory_bytes) by (exported_pod, namespace, container) * 100) / ((sum (eagle_pod_container_resource_requests_memory_bytes) by (exported_pod, namespace, container))) < 10',
      //   'for': '5m',
      //   labels: {
      //     severity: 'warning',
      //   }
      // },

      // {
      //   alert: 'EagleCPULowUsage',
      //   annotations: {
      //     message: 'Container {{$labels.namespace}}/{{$labels.exported_pod}}/{{$labels.container}} uses only {{printf "%.2f" $value}}% of requested CPUs. It may affect resource planning',
      //   },
      //   expr: '(sum (eagle_pod_container_resource_usage_cpu_cores) by (exported_pod, namespace, container) * 100) / ((sum (eagle_pod_container_resource_requests_cpu_cores) by (exported_pod, namespace, container))) < 10',
      //   'for': '5m',
      //   labels: {
      //     severity: 'warning',
      //   }
      // },

      {
        alert: 'EagleMemoryOverUsed',
        annotations: {
          message: 'Container {{$labels.namespace}}/{{$labels.exported_pod}}/{{$labels.container}}, uses {{printf "%.2f" $value}}% of allowed memory limit. It may affect service perormance or instance may be OOMkilled',
        },
        expr: '(sum (eagle_pod_container_resource_usage_memory_bytes) by (exported_pod, namespace, container) * 100) / ((sum (eagle_pod_container_resource_limits_memory_bytes) by (exported_pod, namespace, container)) > 0) > 90',
        'for': '5m',
        labels: {
          severity: 'warning',
        }
      },

      {
        alert: 'EagleCPUOverUsed',
        annotations: {
          message: 'Container {{$labels.namespace}}/{{$labels.exported_pod}}/{{$labels.container}} uses {{printf "%.2f" $value}}% of allowed CPUs limit. It may affect service perormance',
        },
        expr: '(sum (eagle_pod_container_resource_usage_cpu_cores) by (exported_pod, namespace, container) * 100) / ((sum (eagle_pod_container_resource_limits_cpu_cores) by (exported_pod, namespace, container)) > 0) > 90',
        'for': '5m',
        labels: {
          severity: 'warning',
        }
      },

    ],
  },
]
