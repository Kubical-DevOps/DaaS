local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local prometheus = grafana.prometheus;
local template = grafana.template;
local graph = grafana.graphPanel;


local systemLoad =
  singlestat.new(
    title='Nodes Pod Usage',
    datasource='Prometheus',
    format='percent',
    valueName='current',
    decimals=2,
    sparklineShow=true,
    colorValue=true,
    gaugeShow=true,
    thresholds='4,6',
  ).addTarget(
    prometheus.target(
      'sum(kube_pod_info{node=~".*"}) / sum(kube_node_status_allocatable_pods{node=~".*"})',
    )
  );


dashboard.new(
  'Test Openshift Dashboard',
  schemaVersion=16,
  tags=['AAB TEST'],
)
.addTemplate(
  grafana.template.datasource(
    'PROMETHEUS_DS',
    'prometheus',
    'Prometheus',
    hide='label',
  )
)
.addPanels(
  [
    systemLoad { gridPos: { h: 4, w: 3, x: 0, y: 0 } }
  ]
)
