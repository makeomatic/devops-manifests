{
  name:: error 'should specify cronjob name',
  namespace:: error 'should specify cronjob namespae',
  args:: error 'should specify image args',

  schedule:: '@hourly',
  image:: 'gcr.io/peak-orbit-214114/testsuite:debug',

  apiVersion: 'batch/v1beta1',
  kind: 'CronJob',
  metadata: {
    name: $.name,
    namespace: $.namespace
  },
  spec: {
    successfulJobsHistoryLimit: 0,
    failedJobsHistoryLimit: 1,
    concurrencyPolicy: 'Forbid',
    schedule: $.schedule,
    jobTemplate: {
      metadata: {
        labels: {
          cronjob: $.name
        }
      },
      spec: {
        activeDeadlineSeconds: 60,
        backoffLimit: 0,
        template: {
          metadata: {
            annotations: {
              'sidecar.istio.io/inject': 'false'
            }
          },
          spec: {
            restartPolicy: 'Never',
            containers: [{
              args: $.args,
              image: $.image,
              name: 'test'
            }],
          },
        }
      }
    }
  }
}
