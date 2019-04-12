[
  {
    name: 'postgresql',
    rules: [
      {
        alert: 'PgExporterScrapeError',
        annotations: {
          message: 'Postgres Exporter running on {{ $labels.job }} (instance: {{ $labels.instance }}) is encountering scrape errors processing queries. Error count: ( {{ $value }} )',
        },
        expr: 'pg_exporter_last_scrape_error > 0',
        'for': '60s',
        labels: {
          severity: 'critical',
        },
      },

      {
        alert: 'PgIsUp',
        annotations: {
          message: 'postgres_exporter running on {{ $labels.job }} is unable to communicate with the configured database',
        },
        expr: 'pg_up < 1',
        'for': '60s',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'PgHighConnectionCount',
        annotations: {
          message: 'Postgres total connections have been above 90% of the configured max_connections for the past 5 minutes on {{ $labels.instance }}',
        },
        expr: 'sum(pg_stat_activity_count) > (pg_settings_max_connections * 0.9)',
        'for': '5m',
        labels: {
          severity: 'critical',
        },
      },

      {
        alert: 'PgSlowQueries',
        annotations: {
          message: 'PostgreSQL high number of queries per second on {{ $labels.cluster }} for database {{ $labels.datname }} with a value of {{ $value }}',
        },
        expr: 'avg(rate(pg_stat_activity_max_tx_duration{datname!~"template.*"}[2m])) by (datname) > 100', // just about, change in the real system
        'for': '2m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'PgHighQPS',
        annotations: {
          message: 'PostgreSQL high number of queries per second on {{ $labels.cluster }} for database {{ $labels.datname }} with a value of {{ $value }}',
        },
        expr: 'avg(irate(pg_stat_database_xact_commit{datname!~"template.*"}[5m]) + irate(pg_stat_database_xact_rollback{datname!~"template.*"}[5m])) by (datname) > 1000',
        'for': '5m',
        labels: {
          severity: 'warning',
        },
      },

      {
        alert: 'PgCacheHitRatio',
        annotations: {
          message: 'PostgreSQL low on cache hit rate on {{ $labels.cluster }} for database {{ $labels.datname }} with a value of {{ $value }}',
        },
        expr: 'avg(rate(pg_stat_database_blks_hit{datname!~"template.*"}[5m]) / (rate (pg_stat_database_blks_hit{datname!~"template.*"}[5m]) + rate(pg_stat_database_blks_rea {datname!~"template.*"}[5m]))) by (datname) < 0.98',
        'for': '5m',
        labels: {
          severity: 'warning',
        },
      },
    ]
  }
]
