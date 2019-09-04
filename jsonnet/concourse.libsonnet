###
# Following template generates concource CI pipeline which do the following:
# - watches for microfleet release
# - update corresponding helm release
# - notify into telegram channel
###

{
  name:: error 'should specify helm deployment name',
  repo:: error 'should specify source github repository',
  ghToken:: error 'should specify github access token',
  gcpApiKey:: error 'should specify gcloud API key',
  gcpZone:: error 'should specify gcloud zone',
  gcpProject:: error 'should specify gcloud project',
  gcpClusterName::  error 'should specify gcloud cluster name',

  local this = self,
  local releaseOutputName = 'release',

  local kourierNotifyHook = {
    uri: 'http://kourier-rest.ci.svc.cluster.local:8080/concourse',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    json: {
      link: '{ATC_EXTERNAL_URL}/teams/{BUILD_TEAM_NAME}/pipelines/{BUILD_PIPELINE_NAME}',
      job: '{BUILD_JOB_NAME}'
    },
  },

  local resourceTypes = {
    helm: {
      type: 'registry-image',
      source: {
        repository: 'devth/helm',
        tag: 'v2.13.1',
      },
    },
    webhook: {
      name: 'webhook',
      type: 'registry-image',
      source: {
        repository: 'aequitas/http-api-resource',
        tag: 'latest',
      },
    },
  },

  local resourceItems = {
    notifyNewRelease: {
      name: 'github-release',
      type: 'github-release',
      source: {
        owner: std.split(this.repo, '/')[0],
        repository: std.split(this.repo, '/')[1],
        access_token: this.ghToken,
      },
    },
    notifyBuildFailure: {
      name: 'build-failure',
      type: 'webhook',
      source: kourierNotifyHook + {
        json: kourierNotifyHook.json + {
          result: 'failure'
        }
      },
    },
    notifyBuildSuccess: {
      name: 'build-success',
      type: 'webhook',
      source: kourierNotifyHook + {
        json: kourierNotifyHook.json + {
          result: 'success'
        }
      },
    },
  },

  local tasks = {
    waitForRelease: {
      get: resourceItems.notifyNewRelease.name,
      trigger: true,
      params: {
        include_source_zip: true
      },
    },
    extractNodeVersion: {
      task: 'extract-node-version',
      config: {
        platform: 'linux',
        inputs: [{ name: resourceItems.notifyNewRelease.name }],
        outputs: [{ name: releaseOutputName }],
        image_resource: resourceTypes.helm,
        run: {
          path: '/bin/sh',
          args: ['-c', '
            mkdir /tmp/source
            unzip ./'+resourceItems.notifyNewRelease.name+'/source.zip -d /tmp/source
            mv /tmp/source/*/.mdeprc .
            echo `jq .node ./.mdeprc -r` > ./'+releaseOutputName+'/node
            cp ./'+resourceItems.notifyNewRelease.name+'/version ./'+releaseOutputName+'/version
          '],
        },
      }
    },
    deployImage: {
      task: 'deploy-image',
      config: {
        platform: 'linux',
        inputs: [{ name: releaseOutputName }],
        image_resource: resourceTypes.helm,
        run: {
          path: '/bin/bash',
          args: ['-c', '
            echo $CLOUDSDK_API_KEY | base64 -d > ./gcloud-api-key.json
            gcloud auth activate-service-account --key-file gcloud-api-key.json
            gcloud container clusters get-credentials $KUBERNETES_CLUSTER
            helm init --client-only
            helm repo add makeomatic https://cdn.matic.ninja/helm-charts
            helm repo update
            echo "helm upgrade $DEPLOYMENT_NAME makeomatic/installer --atomic --recreate-pods --reuse-values --set image.tag=`cat ./'+releaseOutputName+'/node`-`cat ./'+releaseOutputName+'/version`"
            helm upgrade $DEPLOYMENT_NAME makeomatic/installer --atomic --recreate-pods --reuse-values --set image.tag=`cat ./'+releaseOutputName+'/node`-`cat ./'+releaseOutputName+'/version`
          '],
        },
      },
      params: {
        DEPLOYMENT_NAME: this.name,
        CLOUDSDK_API_KEY: this.gcpApiKey,
        CLOUDSDK_COMPUTE_ZONE: this.gcpZone,
        CLOUDSDK_CORE_PROJECT: this.gcpProject,
        KUBERNETES_CLUSTER: this.gcpClusterName
      }
    }
  },

  // PIPELINE ITSELF
  resource_types: [ resourceTypes.webhook ],
  resources: [
    resourceItems.notifyBuildSuccess,
    resourceItems.notifyBuildFailure,
    resourceItems.notifyNewRelease,
  ],
  jobs: [{
    name: 'upgrade-' + this.name,
    serial: true,
    on_failure: {
      put: resourceItems.notifyBuildFailure.name
    },
    on_success: {
      put: resourceItems.notifyBuildSuccess.name
    },
    plan: [
      tasks.waitForRelease,
      tasks.extractNodeVersion,
      tasks.deployImage,
    ],
  }],
}
