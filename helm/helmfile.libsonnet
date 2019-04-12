###
# Following template generates helmfile spec using default services / values
# plus specifications provided by the user
###
local knownServices = import 'services.libsonnet';
{
  valuesPath:: error 'should specify path for default values',
  services:: error 'should specify array with required services',
  customize:: {},
  local availableServices = std.mergePatch(knownServices, $.customize),

  local this = self,
  // local repository = std.split(services[serviceName].chart, '/')[0];

  // create full release information or throw an error if release is not found
  local createRelease(serviceName) = {
    assert std.objectHas(availableServices, serviceName) : 'release "' + serviceName + '" is not found',

    local hasDefaultValues = std.objectHas(knownServices, serviceName),
    local release = availableServices[serviceName],
    local releaseName = if std.objectHas(release, 'name') then release.name else serviceName,

    // TODO: assert if customization is not provided
    // local customizeRequired = std.objectHas(release, 'customizeRequred'),
    // local hasCustomization = std.objectHas($.customize, serviceName),

    name: releaseName,
    namespace: release.namespace,
    chart: release.chart,
    version: release.version,
    values: (if hasDefaultValues then [$.valuesPath +'/' + serviceName + '.yml'] else []) + (if std.objectHas(release, 'values') then release.values else []),
  },

  // local getRepository(serviceName) = {
  //   local release = createRelease(serviceName),
  //   local repoName = std.split(release.chart, '/')[0],
  //   name: repoName,
  //   url: knownRepositories[repoName],
  // },

  helmDefaults: {
    wait: true,
    force: true,
    atomic: true,
  },
  // TODO: generate repositories based on passed servies
  // repositories: std.map(getRepository, $.services),
  repositories: [
    { name: 'stable', url: 'https://kubernetes-charts.storage.googleapis.com' },
    { name: 'kube-eagle', url: 'https://raw.githubusercontent.com/google-cloud-tools/kube-eagle-helm-chart/master' },
    { name: 'keel', url: 'https://charts.keel.sh' },
    { name: 'makeomatic', url: 'https://cdn.matic.ninja/helm-charts' },
  ],
  releases: std.map(createRelease, $.services),
}
