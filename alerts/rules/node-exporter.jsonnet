[
  {
    name: 'UnusualNetworkThroughputIn',
    summary: 'Unusual network throughput in (instance {{ $labels.instance }})',
    description: 'Host network interfaces are probably receiving too much data (> 100 MB/s) VALUE = {{ $value }} LABELS: {{ $labels }}',
    expr: 'sum by (instance) (irate(node_network_receive_bytes_total{}[2m])) / 1024 / 1024 > 100',
    wait: '30m',
    severity: 'warning',
  },

  {
    name: 'UnusualNetworkThroughputOut',
    summary: 'Unusual network throughput out (instance {{ $labels.instance }})',
    description: 'Host network interfaces are probably sending too much data (> 100 MB/s VALUE = {{ $value }} LABELS: {{ $labels }}',
    expr: 'sum by (instance) (irate(node_network_transmit_bytes_total{}[2m])) / 1024 / 1024 > 100',
    wait: '30m',
    severity: 'warning',
  },

  {
    name: 'UnusualDiskReadRate',
    summary: 'Unusual disk read rate (instance {{ $labels.instance }})',
    description: 'Disk is probably reading too much data (> 50 MB/s) VALUE = {{ $value }} LABELS: {{ $labels }}',
    expr: 'sum by (instance) (irate(node_disk_read_bytes_total{}[2m])) / 1024 / 1024 > 50',
    wait: '30m',
    severity: 'warning',
  },

  {
    name: 'UnusualDiskWriteRate',
    summary: 'Unusual disk write rate (instance {{ $labels.instance }})',
    description: 'Disk is probably writing too much data (> 50 MB/s)(> 50 MB/s) VALUE = {{ $value }} LABELS: {{ $labels }}',
    expr: 'sum by (instance) (irate(node_disk_written_bytes_total{}[2m])) / 1024 / 1024 > 50',
    wait: '30m',
    severity: 'warning',
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
    name: 'NodeDiskRunningFull',
    description: 'Device {{ $labels.device }} of node-exporter {{ $labels.namespace}}/{{ $labels.pod }} will be full within the next 24 hours',
    expr: '(node:node_filesystem_usage: > 0.85) and (predict_linear(node:node_filesystem_avail:[6h], 3600 * 24) < 0)',
    wait: '30m',
    severity: 'warning',
  },

  {
    name: 'NodeDiskRunningFull',
    description: ' Device {{ $labels.device }} of node-exporter {{ $labels.namespace}}/{{ $labels.pod }} will be full within the next 2 hours',
    expr: '(node:node_filesystem_usage: > 0.85) and (predict_linear(node:node_filesystem_avail:[30m], 3600 * 2) < 0)',
    wait: '10m',
    severity: 'critical',
  },
]
