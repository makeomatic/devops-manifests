/*
Generate custom alertmanager rules with custom config and predefined labels. Usage example:

local template = import '../makeomatic-shared/jsonnet/prometheus.libsonnet';
local mixin = import '../makeomatic-shared/vendor/kubernetes-mixin/mixin.libsonnet';
local customMixin = mixin {
  _config+:: {
    // we disable alerts on k8s components presence as they are controlled by GKE itself
    jobs: {}
  }
};

template {
  labels: {
    environment: 'staging',
    project: 'streamlayer',
  },
  rules: [
    customMixin.prometheusAlerts.groups,
    customMixin.prometheusRules.groups,
    import '../makeomatic-shared/jsonnet/rules/alertmanager.libsonnet',
    import '../makeomatic-shared/jsonnet/rules/node-exporter.libsonnet',
    import '../makeomatic-shared/jsonnet/rules/prometheus.libsonnet',
    import '../makeomatic-shared/jsonnet/rules/rabbitmq.libsonnet',
    import '../makeomatic-shared/jsonnet/rules/redis.libsonnet',
    import '../makeomatic-shared/jsonnet/rules/common.libsonnet',
    import '../makeomatic-shared/jsonnet/rules/postgresql.libsonnet',
  ]
}
*/

{
  labels:: error 'specify additional labels for every alerting rule',
  rules:: error 'specify set of rules',
  namespace:: 'monitoring',
  skipAlerts:: {
    // valid behaviour instead: fail on long jobs ("KubeJobFailed" will trigger on fail)
    KubeJobCompletion: true,
  },

  local this = self,

  // customize predefined rules adding own labels
  local labelRules(name, rules) =
    std.map(
      function(rule)
        rule
        + (if std.objectHas(rule, 'labels') then {
             labels: rule.labels + this.labels + {
               component: name,
             },
           } else {}), rules
    ),

  // remove rules from blacklist
  local filterRule(rule) = std.objectHas(rule, 'alert') && !std.objectHas(this.skipAlerts, rule.alert),

  local groupMapper(group) = {
    local labeled = labelRules(group.name, group.rules),
    local skipped = std.filter(filterRule, labeled),
    name: group.name,
    rules: skipped,
  },

  local loadCustomizedRules(items) = std.map(groupMapper, items),

  // generate array of manifests
  local manifests = std.flattenArrays(std.map(loadCustomizedRules, this.rules)),

  // create kubernetes list with modified manifests
  local mapManifests(item) = {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'PrometheusRule',
    metadata: {
      name: item.name,
      namespace: this.namespace,
      labels: {
        app: item.name,
      },
    },
    spec: {
      groups: [{
        name: item.name,
        rules: item.rules,
      }],
    },
  },

  apiVersion: 'v1',
  kind: 'List',
  items: std.map(mapManifests, manifests),
}
