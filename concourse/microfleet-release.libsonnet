###
# - watches for microfleet release
# - installs corresponding image
###
{
  v1:: {
    Create(config): {

      resource_types: std.prune([
        if config.notify then
        {
          name: 'telegram',
          type: 'registry-image',
          source: {
            repository: 'w32blaster/concourse-telegram-notifier'
          },
        },
      ]),

      resources: std.prune([
        if config.notify then
        {
          name: 'notify',
          type: 'telegram',
          source: {
            bot_token: '((tg-bot-token))'
          },
        },

        {
          name: 'github-release',
          type: 'github-release',
          source: {
            owner: std.split(config.releaseRepo, '/')[0],
            repository: std.split(config.releaseRepo, '/')[1],
            access_token: '((github-access-token))'
          },
        },
      ]),


      jobs: [
        {
          name: 'upgrade-' + config.releaseName,
          plan: [
            {
              get: 'github-release',
              trigger: true,
            },
            {
              do: std.prune([
                {
                  task: 'deploy-image',
                  config: {
                    platform: 'linux',
                    inputs: [{ name: 'github-release' }],
                    image_resource: {
                      type: 'registry-image',
                      source: {
                        repository: 'makeomatic/k8s-ci',
                        tag: '12102018'
                      },
                    },
                    run: {
                      path: '/bin/sh',
                      args: ['-c', '. configure-gcloud && helm repo add makeomatic https://cdn.matic.ninja/helm-charts && helm upgrade ${DEPLOYMENT_NAME} makeomatic/microfleet --install --wait --set image.tag=`cat ./github-release/version` ${HELM_ARG}'],
                    },
                  },
                  params: {
                    HELM_ARG: '--reuse-values',
                    DEPLOYMENT_NAME: config.releaseName,
                    CLOUDSDK_API_KEY: '((gcp-deployer-key))',
                    CLOUDSDK_COMPUTE_ZONE: '((gcp-zone))',
                    CLOUDSDK_CORE_PROJECT: '((gcp-project))',
                    KUBERNETES_CLUSTER: '((gcp-cluster-name))'
                  }
                },
              ]),
            } + if config.notify then {
              on_failure: {
                put: 'notify',
                params: {
                  chat_id: '((tg-chat-id))',
                  text: 'Job "$BUILD_JOB_NAME" failed ($ATC_EXTERNAL_URL/teams/$BUILD_TEAM_NAME/pipelines/$BUILD_PIPELINE_NAME)'
                },
              },
              on_success: {
                put: 'notify',
                params: {
                  chat_id: '((tg-chat-id))',
                  text: 'Job "$BUILD_JOB_NAME" succeed'
                },
              },
            } else {},
          ],
        },
      ],

    },
  },
}
