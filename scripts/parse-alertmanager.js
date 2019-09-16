const [, , manifestPath, ...labelsStrings] = process.argv

const labels = labelsStrings.reduce((acc, item) => {
  const [key, value] = item.split('=')
  acc[key] = value
  return acc
}, {})

const metricPattern = '[a-zA-Z_:][a-zA-Z0-9_:]+'

const reservedWords = new Set(['unless', 'and', 'or', 'ignoring', 'on', 'abs', 'absent', 'ceil', 'changes', 'clamp_max', 'clamp_min', 'day_of_month', 'day_of_week', 'days_in_month', 'delta', 'deriv', 'exp', 'floor', 'histogram_quantile', 'holt_winters', 'hour', 'idelta', 'increase', 'irate', 'label_join', 'label_replace', 'ln', 'log2', 'log10', 'minute', 'month', 'predict_linear', 'rate', 'resets', 'round', 'scalar', 'sort', 'sort_desc', 'sqrt', 'time', 'timestamp', 'vector', 'year', 'avg_over_time', 'min_over_time', 'max_over_time', 'sum_over_time', 'count_over_time', 'quantile_over_time', 'stddev_over_time', 'stdvar_over_time', 'sum', 'min', 'max', 'avg', 'count', 'stddev', 'stdvar', 'count_values', 'bottomk', 'topk', 'quantile', 'without', 'by'])

const startKeywords = ['abs', 'absent', 'ceil', 'changes', 'clamp_max', 'clamp_min', 'delta', 'deriv', 'exp', 'floor', 'holt_winters', 'idelta', 'increase', 'irate', 'label_join', 'label_replace', 'ln', 'log2', 'log10', 'predict_linear', 'rate', 'resets', 'round', 'scalar', 'sort', 'sort_desc', 'sqrt', 'timestamp', 'vector', 'avg_over_time', 'min_over_time', 'max_over_time', 'sum_over_time', 'count_over_time', 'quantile_over_time', 'stddev_over_time', 'stdvar_over_time', 'sum', 'min', 'max', 'avg', 'count']

const expressions = [
  // before any "{"
  RegExp(`(${metricPattern}){`, 'g'),
  // before mathematical and comparisons if in beginning
  RegExp(`^\\(*(${metricPattern})\\s*[<>+--/=]`, 'g'),
  // starting from keywords and does not containing "(" after it
  RegExp(`[${startKeywords.join('|')}]\\((${metricPattern})`, 'g'),
]

function extractTokens(str) {
  const items = new Set()
  expressions.forEach(expr => {
    const matches = str.matchAll(expr)
    for (const match of matches) {
      items.add(match[1])
    }
  })
  // remove reserved words
  const intersection = [...items].filter(item => !reservedWords.has(item))
  return intersection
}

const data = require(manifestPath)

const metrics = new Set()
data.items.forEach(({ spec }) => {
  spec.groups.forEach(group => {
    group.rules.forEach(rule => {
      if (!rule.expr) { return }
      metrics.add(...extractTokens(rule.expr))
    })
  })
})

const rules = {
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'PrometheusRule',
  metadata: {
    labels: {},
    name: 'metrics-absence',
    namespace: 'monitoring',
  },
  spec: {
    groups: [
      {
        name: 'metrics-absence',
        rules: []
      }
    ]
  }
}

metrics.forEach(name => {
  if (!name) { return }

  rules.spec.groups[0].rules.push({
    alert: 'MetricMissed:' + name,
    annotations: {
      message: `Metric "${name}" is used in alerting but does not exists in prometheus`
    },
    expr: `absent(${name})`,
    for: '60s',
    labels: labels,
  })
})

console.log(JSON.stringify(rules, null, ' '))
