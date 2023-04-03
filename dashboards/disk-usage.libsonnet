local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local prometheus = grafana.prometheus;
local template = grafana.template;

dashboard.new(
  'Disk Usage',
  schemaVersion=16,
  tags=['OLE'],
)
.addTemplate(
  grafana.template.datasource(
    'PROMETHEUS_DS',
    'prometheus',
    'prometheus',
    hide='label',
  )
)
.addTemplate(
  template.new(
    'instance',
    '$PROMETHEUS_DS',
    'label_values(node_filesystem_avail_bytes, instance)',
    label='Instance',
    refresh='time',
  )
)
.addTemplate(
  template.new(
    'mountpoint',
    '$PROMETHEUS_DS',
    'label_values(node_filesystem_avail_bytes{instance="$instance"}, mountpoint)',
    label='Mount Point',
    refresh='time',
  )
)
.addPanel(
  singlestat.new(
    'Disk usage',
    format='percent',
    datasource='$PROMETHEUS_DS',
    valueName='current',
  )
  .addTarget(
    prometheus.target(
      '100 - node_filesystem_avail_bytes{instance="$instance",mountpoint="$mountpoint"} / node_filesystem_size_bytes{instance="$instance"} * 100',
    )
  ), gridPos={
    x: 0,
    y: 0,
    w: 4,
    h: 3,
  }
)