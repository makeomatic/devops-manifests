local template = import "microfleet-release.libsonnet";
template.v1.Create({
  releaseRepo: 'StreamLayer/sl-betgenius',
  releaseName: 'betgenius-staging',
  notifyChannelId: 'telegram-channel',
})
