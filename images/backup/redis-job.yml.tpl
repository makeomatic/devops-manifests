apiVersion: batch/v1beta1
kind: CronJob
metadata:
  labels:
    app: backup
    type: {type}
    name: {name}
    namespace: default
  name: backup-redis-{name}
spec:
  concurrencyPolicy: Forbid
  failedJobsHistoryLimit: 1
  jobTemplate:
    metadata:
      labels:
        app: backup
        type: redis
        name: {name}
    spec:
      activeDeadlineSeconds: 600
      backoffLimit: 1
      template:
        spec:
          containers:
            - env:
                - name: CLOUDSDK_API_KEY
                  valueFrom:
                    secretKeyRef:
                      key: private_key
                      name: backup-bucket-credentials
                - name: BUCKET_NAME
                  valueFrom:
                    secretKeyRef:
                      key: bucket_name
                      name: backup-bucket-credentials
                - name: BACKUP_PATH
                  value: /backup/dump.tar.gz
                - name: BUCKET_PATH
                  value: redis/{name}
              image: gcr.io/peak-orbit-214114/backup/bucket-store:debug
              imagePullPolicy: IfNotPresent
              name: store
              volumeMounts:
                - mountPath: /backup
                  name: backup-volume
          dnsPolicy: ClusterFirst
          initContainers:
            - env:
                - name: REDIS_HOST
                  value: { host }
                - name: REDIS_GROUP
                  value: master
                - name: BACKUP_PATH
                  value: /backup/dump.tar.gz
              image: gcr.io/peak-orbit-214114/backup/redis:debug.3
              imagePullPolicy: IfNotPresent
              name: backup
              volumeMounts:
                - mountPath: /backup
                  name: backup-volume
          restartPolicy: Never
          volumes:
            - emptyDir: {}
              name: backup-volume
  schedule: "{schedule}"
  successfulJobsHistoryLimit: 0
