{
  grafanaDashboards+:: {
    'argocd.json': (import './argocd.json'),
    'azure-virtual-machines.json': (import './azure-virtual-machines.libsonnet'),
    'disk-usage.json': (import './disk-usage.libsonnet'),
    'openshift-cluster.json': (import './openshift-cluster.libsonnet'),
    'websites.json': (import './websites.json'),
  },
}
