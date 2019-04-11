[
  {
    name: 'PgExporterScrapeError',
    description: 'Postgres Exporter running on {{ $labels.job }} (instance: {{ $labels.instance }}) is encountering scrape errors processing queries. Error count: ( {{ $value }} )',
    expr: 'pg_exporter_last_scrape_error > 0',
    wait: '60s',
    severity: 'critical',
  },

  {
    name: 'PgIsUp',
    description: 'postgres_exporter running on {{ $labels.job }} is unable to communicate with the configured database',
    expr: 'pg_up < 1',
    wait: '60s',
    severity: 'warning',
  },

  {
    name: 'PgHighConnectionCount',
    description: 'Postgres total connections have been above 40% of the configured max_connections for the past 5 minutes on {{ $labels.instance }}',
    expr: 'sum(pg_stat_activity_count) > (pg_settings_max_connections * 0.9)',
    wait: '5m',
    severity: 'critical',
  },

  {
    name: 'PgSlowQueries',
    description: 'PostgreSQL high number of queries per second on {{ $labels.cluster }} for database {{ $labels.datname }} with a value of {{ $value }}',
    expr: 'avg(rate(pg_stat_activity_max_tx_duration{datname!~"template.*"}[2m])) by (datname)',
    wait: '2m',
    severity: 'warning',
  },

  {
    name: '',
    description: '',
    expr: '',
    wait: '',
    severity: 'warning',
  },

  {
    name: 'PgHighQPS',
    description: 'PostgreSQL high number of queries per second on {{ $labels.cluster }} for database {{ $labels.datname }} with a value of {{ $value }}',
    expr: 'avg(irate(pg_stat_database_xact_commit{datname!~"template.*"}[5m]) + irate(pg_stat_database_xact_rollback{datname!~"template.*"}[5m])) by (datname) > 1000',
    wait: '5m',
    severity: 'warning',
  },

  {
    name: 'PgCacheHitRatio',
    description: 'PostgreSQL low on cache hit rate on {{ $labels.cluster }} for database {{ $labels.datname }} with a value of {{ $value }}',
    expr: 'avg(rate(pg_stat_database_blks_hit{datname!~"template.*"}[5m]) / (rat (pg_stat_database_blks_hit{datname!~"template.*"}[5m]) + rate(pg_stat_database_blks_rea {datname!~"template.*"}[5m]))) by (datname) < 0.98',
    wait: '5m',
    severity: 'warning',
  },

]
