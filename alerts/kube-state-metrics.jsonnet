[
  // {
  //   record: 'job_cronjob:kube_job_status_start_time:max',
  //   expr: 'label_replace(
  //       label_replace(
  //         max(
  //           kube_job_status_start_time
  //           * ON(job_name) GROUP_RIGHT()
  //           kube_job_labels{label_cronjob!=""}
  //         ) BY (job_name, label_cronjob)
  //         == ON(label_cronjob) GROUP_LEFT()
  //         max(
  //           kube_job_status_start_time
  //           * ON(job_name) GROUP_RIGHT()
  //           kube_job_labels{label_cronjob!=""}
  //         ) BY (label_cronjob),
  //         "job", "$1", "job", "(.+)"),
  //       "cronjob", "$1", "label_cronjob", "(.+)")'
  // },

  // {
  //   record: 'job_cronjob:kube_job_status_failed:sum',
  //   expr: 'clamp_max(
  //       job_cronjob:kube_job_status_start_time:max,
  //     1)
  //     * ON(job) GROUP_LEFT()
  //     label_replace(
  //       label_replace(
  //         (kube_job_status_failed != 0),
  //         "job", "$1", "job", "(.+)"),
  //       "cronjob", "$1", "label_cronjob", "(.+)")'
  // },

  // // monitors job with label 'cronjob' in it
  // {
  //   name: 'CronJobStatusFailed',
  //   description: '{{ $labels.cronjob }} last run has failed {{ $value }} times',
  //   expr: 'job_cronjob:kube_job_status_failed:sum * ON(cronjob) GROUP_RIGHT() kube_cronjob_labels > 0',
  //   wait: '1m',
  //   url: 'https://medium.com/@tristan_96324/prometheus-k8s-cronjob-alerts-94bee7b90511',
  //   severity: 'warning',
  // },

  // TODO: find how to trigger cronjob fail
  {
    name: 'KubeJobFailed',
    summary: 'Handle failed jobs',
    description: 'Job {{ $labels.namespace }}/{{ $labels.job_name }} failed to complete',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubejobfailed',
    expr: 'kube_job_status_failed{job="kube-state-metrics"}  > 0',
    wait: '1h',
    severity: 'warning',
  },

  {
    name: 'TargetDown',
    description: '{{ $value }}% of the {{ $labels.job }} targets are down',
    expr: '100 * (count(up == 0) BY (job) / count(up) BY (job)) > 10',
    wait: '10m',
    severity: 'warning',
  },

  {
    name: 'KubePodCrashLooping',
    description: 'Pod {{ $labels.namespace }}/{{ $labels.pod }} ({{ $labels.container}}) is restarting {{ printf "%.2f" $value }} times / 5 minutes',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubepodcrashlooping',
    expr: 'rate(kube_pod_container_status_restarts_total{job="kube-state-metrics"}[15m]) * 60 * 5 > 0',
    wait: '1h',
    severity: 'critical',
  },

  {
    name: 'KubePodNotReady',
    description: 'Pod {{ $labels.namespace }}/{{ $labels.pod }} has been in a non-ready state for longer than an hour',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubepodnotready',
    expr: 'sum by (namespace, pod) (kube_pod_status_phase{job="kube-state-metrics", phase=~"Pending|Unknown"}) > 0',
    wait: '1h',
    severity: 'critical',
  },

  {
    name: 'KubeDeploymentGenerationMismatch',
    description: 'Deployment generation for {{ $labels.namespace }}/{{ $labels.deployment}} does not match, this indicates that the Deployment has failed but has not been rolled back.',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubedeploymentgenerationmismatch',
    expr: 'kube_deployment_status_observed_generation{job="kube-state-metrics"} != kube_deployment_metadata_generation{job="kube-state-metrics"}',
    wait: '15m',
    severity: 'critical',
  },

  {
    name: 'KubeDeploymentReplicasMismatch',
    description: 'Deployment {{ $labels.namespace }}/{{ $labels.deployment }} has not matched the expected number of replicas for longer than an hour',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubedeploymentreplicasmismatch',
    expr: 'kube_deployment_spec_replicas{job="kube-state-metrics"} != kube_deployment_status_replicas_available{job="kube-state-metrics"}',
    wait: '1h',
    severity: 'critical',
  },

  {
    name: 'KubeStatefulSetReplicasMismatch',
    description: 'StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} has not matched the expected number of replicas for longer than 15 minutes',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubestatefulsetreplicasmismatch',
    expr: 'kube_statefulset_status_replicas_ready{job="kube-state-metrics"} != kube_statefulset_status_replicas{job="kube-state-metrics"}',
    wait: '15m',
    severity: 'critical',
  },

  {
    name: 'KubeStatefulSetGenerationMismatch',
    description: 'StatefulSet generation for {{ $labels.namespace }}/{{ $labels.statefulset}} does not match, this indicates that the StatefulSet has failed but has not been rolled back',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubestatefulsetgenerationmismatch',
    expr: 'kube_statefulset_status_observed_generation{job="kube-state-metrics"} != kube_statefulset_metadata_generation{job="kube-state-metrics"}',
    wait: '15m',
    severity: 'critical',
  },

  {
    name: 'KubeStatefulSetUpdateNotRolledOut',
    description: 'StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} update has not been rolled out',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubestatefulsetupdatenotrolledout',
    expr: 'max without (revision) (kube_statefulset_status_current_revision{job="kube-state-metrics"} unless kube_statefulset_status_update_revision{job="kube-state-metrics"}) * (kube_statefulset_replicas{job="kube-state-metrics"} != kube_statefulset_status_replicas_updated{job="kube-state-metrics"})',
    wait: '15m',
    severity: 'critical',
  },

  {
    name: 'KubeDaemonSetRolloutStuck',
    description: 'Only {{ $value }}% of the desired Pods of DaemonSet {{ $labels.namespace}}/{{ $labels.daemonset }} are scheduled and ready',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubedaemonsetrolloutstuck',
    expr: 'kube_daemonset_status_number_ready{job="kube-state-metrics"} / kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics"} * 100 < 100',
    wait: '15m',
    severity: 'critical',
  },

  {
    name: 'KubeDaemonSetNotScheduled',
    description: '{{ $value }} Pods of DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset}} are not scheduled',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubedaemonsetnotscheduled',
    expr: 'kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics"} - kube_daemonset_status_current_number_scheduled{job="kube-state-metrics"} > 0',
    wait: '10m',
    severity: 'warning',
  },

  {
    name: 'KubeDaemonSetMisScheduled',
    description: '{{ $value }} Pods of DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset}} are running where they are not supposed to run',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubedaemonsetmisscheduled',
    expr: 'kube_daemonset_status_number_misscheduled{job="kube-state-metrics"} > 0',
    wait: '10m',
    severity: 'warning',
  },

  {
    name: 'KubePersistentVolumeErrors',
    description: 'The persistent volume {{ $labels.persistentvolume }} has status {{ $labels.phase }}',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubepersistentvolumeerrors',
    expr: 'kube_persistentvolume_status_phase{phase=~"Failed|Pending",job="kube-state-metrics"} > 0',
    wait: '5m',
    severity: 'critical',
  },

  {
    name: 'KubePersistentVolumeClaimErrors',
    description: 'The persistent volume claim {{ $labels.persistentvolumeclaim }} has status {{ $labels.phase }}',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubepersistentvolumeerrors',
    expr: 'kube_persistentvolumeclaim_status_phase{phase=~"Failed|Pending",job="kube-state-metrics"} > 0',
    wait: '5m',
    severity: 'critical',
  },

  {
    name: 'KubeNodeNotReady',
    description: '{{ $labels.node }} has been unready for more than an hour',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubenodenotready',
    expr: 'kube_node_status_condition{job="kube-state-metrics",condition="Ready",status="true"} == 0',
    wait: '1h',
    severity: 'warning',
  },

  {
    name: 'KubeVersionMismatch',
    description: 'There are {{ $value }} different semantic versions of Kubernetes components running',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeversionmismatch',
    expr: 'count(count by (gitVersion) (label_replace(kubernetes_build_info{job!="kube-dns"},"gitVersion","$1","gitVersion","(v[0-9]*.[0-9]*.[0-9]*).*"))) > 1',
    wait: '1h',
    severity: 'warning',
  },

  {
    name: 'KubeClientErrors',
    description: 'Kubernetes API server client {{ $labels.job }}/{{ $labels.instance}} is experiencing {{ printf "%0.0f" $value }}% errors',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeclienterrors',
    expr: '(sum(rate(rest_client_requests_total{code=~"5.."}[5m])) by (instance, job) / sum(rate(rest_client_requests_total[5m])) by (instance, job)) * 100 > 1',
    wait: '15m',
    severity: 'warning',
  },

  {
    name: 'KubeletTooManyPods',
    description: 'Kubelet {{ $labels.instance }} is running {{ $value }} Pods, close to the limit of 110',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubelettoomanypods',
    expr: ' kubelet_running_pod_count{job="kubelet"} > 110 * 0.9',
    wait: '15m',
    severity: 'warning',
  },

  {
    name: 'KubeAPIErrorsHigh',
    description: 'API server is returning errors for {{ $value }}% of requests',
    url: 'https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-kubeapierrorshigh',
    expr: 'sum(rate(apiserver_request_count{job="apiserver",code=~"^(?:5..)$"}[5m])) without(instance, pod) / sum(rate(apiserver_request_count{job="apiserver"}[5m])) without(instance, pod) * 100 > 10',
    wait: '10m',
    severity: 'critical',
  },


]
