local createRule(item) = {
  alert: item.name,
  annotations: {
    descrition: item.description,
  },
  expr: item.expr,
  'for': item.wait,
  lavels: {
    severity: item.severity,
  },
};

local createRecord(item) = {
  record: item.record,
  expr: item.expr,
};

// parse passed item and return either alertmanager record or rule
local create(item) = if std.objectHas(item, 'name') then createRule(item) else createRecord(item);

{
  name:: error 'should specify ruleset name',
  rules:: error 'should specify rules',
  namespace:: 'monitoring',
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'PrometheusRule',
  metadata: {
    name: $.name,
    namespace: $.namespace,
    labels: {
      app: $.name, // will find rule using this label
    },
  },
  spec: {
    groups: [
      {
        name: $.name + '.rules',
        rules: std.map(create, $.rules),
      },
    ],
  },
}
