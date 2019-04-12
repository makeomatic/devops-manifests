[
  {
    name: 'node-exporter',
    rules: [
      {
        alert: 'NodeMetricIsAbsent',
        annotations: {
          message: 'Looks like node-exporter metrics are absent - either install collector or remove corresponding alerts'
        },
        expr: 'absent(node_network_receive_bytes_total) or
absent(node_disk_read_bytes_total) or
absent(node_disk_written_bytes_total) or
absent(node:node_filesystem_usage:) or
absent(node:node_filesystem_avail)',
        labels: {
          severity: 'critical',
        }
      },

      {
        alert: 'UnusualNetworkThroughputIn',
        annotations: {
          message: 'Host network interfaces are probably receiving too much data (> 100 MB/s) VALUE = {{ $value }} LABELS: {{ $labels }}',
        },
        expr: 'sum by (instance) (irate(node_network_receive_bytes_total{}[2m])) / 1024 / 1024 > 100',
        'for': '30m',
        labels: {
          severity: 'warning',
        }
      },

      {
        alert: 'UnusualNetworkThroughputOut',
        annotations: {
          message: 'Host network interfaces are probably sending too much data (> 100 MB/s VALUE = {{ $value }} LABELS: {{ $labels }}',
        },
        expr: 'sum by (instance) (irate(node_network_transmit_bytes_total{}[2m])) / 1024 / 1024 > 100',
        'for': '30m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'UnusualDiskReadRate',
        annotations: {
          message: 'Disk is probably reading too much data (> 50 MB/s) VALUE = {{ $value }} LABELS: {{ $labels }}',
        },
        expr: 'sum by (instance) (irate(node_disk_read_bytes_total{}[2m])) / 1024 / 1024 > 50',
        'for': '30m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'UnusualDiskWriteRate',
        annotations: {
          message: 'Disk is probably writing too much data (> 50 MB/s)(> 50 MB/s) VALUE = {{ $value }} LABELS: {{ $labels }}',
        },
        expr: 'sum by (instance) (irate(node_disk_written_bytes_total{}[2m])) / 1024 / 1024 > 50',
        'for': '30m',
        labels: {
          severity: 'warning',
        },
      },


      // disk running full
      {
        expr: 'max by (namespace, pod, device) ((node_filesystem_size_bytes{fstype=~"ext[234]|btrfs|xfs|zfs"} - node_filesystem_avail_bytes{fstype=~"ext[234]|btrfs|xfs|zfs"}) / node_filesystem_size_bytes{fstype=~"ext[234]|btrfs|xfs|zfs"})',
        record: 'node:node_filesystem_usage:',
      },

      {
        expr: 'max by (namespace, pod, device) (node_filesystem_avail_bytes{fstype=~"ext[234]|btrfs|xfs|zfs"} / node_filesystem_size_bytes{fstype=~"ext[234]|btrfs|xfs|zfs"})',
        record: 'node:node_filesystem_avail:',
      },

      {
        alert: 'NodeDiskRunningFull',
        annotations: {
          message: 'Device {{ $labels.device }} of node-exporter {{ $labels.namespace}}/{{ $labels.pod }} will be full within the next 24 hours',
        },
        expr: '(node:node_filesystem_usage: > 0.85) and (predict_linear(node:node_filesystem_avail:[6h], 3600 * 24) < 0)',
        'for': '30m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'NodeDiskRunningFull',
        annotations: {
          message: ' Device {{ $labels.device }} of node-exporter {{ $labels.namespace}}/{{ $labels.pod }} will be full within the next 2 hours',
        },
        expr: '(node:node_filesystem_usage: > 0.85) and (predict_linear(node:node_filesystem_avail:[30m], 3600 * 2) < 0)',
        'for': '10m',
        labels: {
          severity: 'critical',
        },
      },
    ]
  }
]
