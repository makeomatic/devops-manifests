[
  {
    name: 'KubePersistentVolumeUsageCritical',
    description: 'The PersistentVolume claimed by {{ $labels.persistentvolumeclaim}} in Namespace {{ $labels.namespace }} is only {{ printf "%0.2f" $value}}% free',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubepersistentvolumeusagecritical',
    expr: '100 * kubelet_volume_stats_available_bytes{job="kubelet"} / kubelet_volume_stats_capacity_bytes{job="kubelet"} < 3',
    wait: '1m',
    severity: 'critical',
  },

  {
    name: 'KubePersistentVolumeFullInFourDays',
    description: 'Based on recent sampling, the PersistentVolume claimed by {{ $labels.persistentvolumeclaim}} in Namespace {{ $labels.namespace }} is expected to fill up within four days. Currently {{ printf "%0.2f" $value }}% is available',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubepersistentvolumefullinfourdays',
    expr: '100 * (kubelet_volume_stats_available_bytes{job="kubelet"} / kubelet_volume_stats_capacity_bytes{job="kubelet"}) < 15 and predict_linear(kubelet_volume_stats_available_bytes{job="kubelet"}[6h], 4 * 24 * 3600) < 0',
    wait: '5m',
    severity: 'critical',
  },

]
