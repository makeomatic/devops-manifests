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
        tag: '2b50bc4',
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
      task: 'extract-deployment-settings',
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
              // extract node, version and tag from .mdeprc
              'export DIR="./' + releaseOutputName + '"',
              'mkdir /tmp/source',
              'unzip ./' + resourceItems.notifyNewRelease.name + '/source.zip -d /tmp/source',
              'mv /tmp/source/*/.mdeprc .',
              'echo `jq .node ./.mdeprc -r` > $DIR/node',
              'cp ./' + resourceItems.notifyNewRelease.name + '/version $DIR/version',
              'echo `cat $DIR/node`-`cat $DIR/version` > $DIR/tag',
              // move skaffold-specific settings if exist
              'mv /tmp/source/*/skaffold.yml $DIR',
              'mv /tmp/source/*/deploy $DIR',
            ]),
          ],
        },
      },
    },
    updateDeploymentTag: {
      task: 'deploy-service',
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

              'cd ./' + releaseOutputName,
              'export TAG=`cat ./tag`',
              //  deploy using skaffold if file exists
              'if [ -f "./skaffold.yml" ]; then',
              'echo "deplying using skaffold ..."',
              'TAG=$TAG skaffold deploy',
              // otherwise simply update tag of {name} deployment
              'else',
              'echo "deploying only image ..."',
              'helm upgrade $DEPLOYMENT_NAME makeomatic/installer --atomic --recreate-pods --reuse-values --set image.tag=$TAG',
              'fi',
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
      tasks.updateDeploymentTag,
    ],
  }],
}
