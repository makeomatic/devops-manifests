//##
// Following template generates concource CI pipeline which do the following:
// - watches for microfleet release
// - update corresponding helm release
// - notify into telegram channel
//##

{
  name:: error 'should specify release name',
  repo:: error 'should specify source github repository',
  ghToken:: error 'should specify github access token',
  gcpApiKey:: error 'should specify gcloud API key',
  gcpZone:: error 'should specify gcloud zone',
  gcpProject:: error 'should specify gcloud project',
  gcpClusterName:: error 'should specify gcloud cluster name',
  skaffold:: false,

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
      job: '{BUILD_JOB_NAME}',
    },
  },

  local resourceTypes = {
    helm: {
      type: 'registry-image',
      source: {
        repository: 'makeomatic/k8s-ci',
        tag: '15d88fb-dirty',
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
      source: kourierNotifyHook {
        json: kourierNotifyHook.json {
          result: 'failure',
        },
      },
    },
    notifyBuildSuccess: {
      name: 'build-success',
      type: 'webhook',
      source: kourierNotifyHook {
        json: kourierNotifyHook.json {
          result: 'success',
        },
      },
    },
  },

  local tasks = {
    waitForRelease: {
      get: resourceItems.notifyNewRelease.name,
      trigger: true,
      params: {
        include_source_zip: true,
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
          args: [
            '-c',
            std.lines([
              'mkdir /tmp/source',
              'unzip ./' + resourceItems.notifyNewRelease.name + '/source.zip -d /tmp/source',
              'mv /tmp/source/*/.mdeprc .',
              'echo `jq .node ./.mdeprc -r` > ./' + releaseOutputName + '/node',
              'cp ./' + resourceItems.notifyNewRelease.name + '/version ./' + releaseOutputName + '/version',
            ]),
          ],
        },
      },
    },
    updateDeploymentTag: {
      task: 'update-service-version',
      config: {
        platform: 'linux',
        inputs: [{ name: releaseOutputName }],
        image_resource: resourceTypes.helm,
        run: {
          path: '/bin/bash',
          args: [
            '-c',
            std.lines([
              // setup kubernetes access
              'echo $CLOUDSDK_API_KEY | base64 -d > ./gcloud-api-key.json',
              'gcloud auth activate-service-account --key-file gcloud-api-key.json',
              'gcloud container clusters get-credentials $KUBERNETES_CLUSTER',
              'helm repo add makeomatic https://cdn.matic.ninja/helm-charts',
              // update tag
              'export TAG=`cat ./' + releaseOutputName + '/node`-`cat ./' + releaseOutputName + '/version`',
              'helm upgrade $DEPLOYMENT_NAME makeomatic/installer --atomic --recreate-pods --reuse-values --set image.tag=$TAG',
            ]),
          ],
        },
      },
      params: {
        DEPLOYMENT_NAME: this.name,
        CLOUDSDK_API_KEY: this.gcpApiKey,
        CLOUDSDK_COMPUTE_ZONE: this.gcpZone,
        CLOUDSDK_CORE_PROJECT: this.gcpProject,
        KUBERNETES_CLUSTER: this.gcpClusterName,
      },
    },
    deployUsingSkaffold: {
      task: 'skaffold-deploy',
      config: {
        platform: 'linux',
        inputs: [
          { name: releaseOutputName },
          { name: resourceItems.notifyNewRelease.name },
        ],
        image_resource: resourceTypes.helm,
        run: {
          path: '/bin/bash',
          args: [
            '-c',
            std.lines([
              // setup kubernetes access
              'echo $CLOUDSDK_API_KEY | base64 -d > ./gcloud-api-key.json',
              'gcloud auth activate-service-account --key-file gcloud-api-key.json',
              'gcloud container clusters get-credentials $KUBERNETES_CLUSTER',
              'helm repo add makeomatic https://cdn.matic.ninja/helm-charts',
              // extract sources
              'mkdir /tmp/source',
              'unzip ./' + resourceItems.notifyNewRelease.name + '/source.zip -d /tmp/source',
              'mv /tmp/source/*/skaffold.yml .',
              'mv /tmp/source/*/deploy .',
              // update service using skaffold
              'export TAG=`cat ./' + releaseOutputName + '/node`-`cat ./' + releaseOutputName + '/version`',
              'TAG=$TAG skaffold deploy',
            ]),
          ],
        },
      },
      params: {
        CLOUDSDK_API_KEY: this.gcpApiKey,
        CLOUDSDK_COMPUTE_ZONE: this.gcpZone,
        CLOUDSDK_CORE_PROJECT: this.gcpProject,
        KUBERNETES_CLUSTER: this.gcpClusterName,
      },
    },
  },

  // PIPELINE ITSELF
  resource_types: [resourceTypes.webhook],
  resources: [
    resourceItems.notifyBuildSuccess,
    resourceItems.notifyBuildFailure,
    resourceItems.notifyNewRelease,
  ],
  jobs: [{
    name: 'upgrade-' + this.name,
    serial: true,
    on_failure: {
      put: resourceItems.notifyBuildFailure.name,
    },
    on_success: {
      put: resourceItems.notifyBuildSuccess.name,
    },
    plan: [
      tasks.waitForRelease,
      tasks.extractNodeVersion,
      if this.skaffold then tasks.deployUsingSkaffold else tasks.updateDeploymentTag,
    ],
  }],
}
