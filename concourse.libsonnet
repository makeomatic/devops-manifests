###
# - watches for microfleet release
# - installs corresponding image
###

// TODO:
// - fail on unsucessfull notify (or rewrite to custom bot)
{
  name:: error 'should specify helm deployment name',
  repo:: error 'should specify source github repository',
  notifyChannel:: null,

  local notify = std.type($.notifyChannel) != 'null',
  local this = self,

  resource_types: std.prune([
    if notify then
    {
      name: 'telegram',
      type: 'registry-image',
      source: {
        repository: 'w32blaster/concourse-telegram-notifier'
      },
    },
  ]),

  resources: std.prune([
    if notify then
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
        owner: std.split(this.repo, '/')[0],
        repository: std.split(this.repo, '/')[1],
        access_token: '((github-access-token))'
      },
    },
  ]),

  jobs: [{
    name: 'upgrade-' + this.name,
    plan: [
      {
        get: 'github-release',
        trigger: true,
        params: {
          include_source_zip: true
        },
      },
      {
        do: [
          {
            task: 'extract-node-version',
            config: {
              platform: 'linux',
              inputs: [{ name: 'github-release' }],
              outputs: [{ name: 'release' }],
              image_resource: {
                type: 'registry-image',
                source: {
                  repository: 'endeveit/docker-jq'
                },
              },
              run: {
                path: '/bin/sh',
                args: ['-c', '
                  mkdir /tmp/source
                  unzip ./github-release/source.zip -d /tmp/source
                  mv /tmp/source/*/.mdeprc .
                  echo `jq .node ./.mdeprc -r` > ./release/node
                  cp ./github-release/version ./release/version
                '],
              },
            }
          },
          {
            task: 'deploy-image',
            config: {
              platform: 'linux',
              inputs: [{ name: 'release' }],
              image_resource: {
                type: 'registry-image',
                source: {
                  repository: 'vkfont/gcloud-kubectl',
                },
              },
              run: {
                path: '/bin/bash',
                args: ['-c', '
                  echo $CLOUDSDK_API_KEY | base64 -d > ./gcloud-api-key.json
                  gcloud auth activate-service-account --key-file gcloud-api-key.json
                  gcloud container clusters get-credentials $KUBERNETES_CLUSTER
                  helm init --client-only
                  helm repo add makeomatic https://cdn.matic.ninja/helm-charts
                  helm upgrade $DEPLOYMENT_NAME makeomatic/installer --atomic --recreate-pods --reuse-values --set image.tag=`cat ./release/node`-`cat ./release/version`
                '],
              },
            },
            params: {
              DEPLOYMENT_NAME: this.name,
              CLOUDSDK_API_KEY: '((gcp-deployer-key))',
              CLOUDSDK_COMPUTE_ZONE: '((gcp-zone))',
              CLOUDSDK_CORE_PROJECT: '((gcp-project))',
              KUBERNETES_CLUSTER: '((gcp-cluster-name))'
            }
          },
        ],
      } + if notify then {
        on_failure: {
          put: 'notify',
          params: {
            chat_id: this.notifyChannel,
            text: 'Job "$BUILD_JOB_NAME" failed ($ATC_EXTERNAL_URL/teams/$BUILD_TEAM_NAME/pipelines/$BUILD_PIPELINE_NAME)'
          },
        },
        on_success: {
          put: 'notify',
          params: {
            chat_id: this.notifyChannel,
            text: 'Job "$BUILD_JOB_NAME" succeed'
          },
        },
      } else {},
    ],
  }],

}
