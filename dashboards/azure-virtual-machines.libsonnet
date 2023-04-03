local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.singlestat;
local prometheus = grafana.prometheus;
local template = grafana.template;


local buildInfo =
        singlestat.new(
          title='Number Of VM',
          datasource='$AZURE_MONITOR',
          format='none',
          valueName='name',
          targets=['{
          "appInsights": {
            "groupBy": "none",
            "metricName": "select",
            "rawQuery": false,
            "rawQueryString": "",
            "spliton": "",
            "timeGrainType": "auto",
            "xaxis": "timestamp",
            "yaxis": ""
          },
          "azureLogAnalytics": {
            "query": "// Computers availability today\r\n// Chart the number of computers sending logs, each hour\r\nHeartbeat \r\n| where $__timeFilter(TimeGenerated)\n| summarize dcount(Computer) by bin(TimeGenerated, 3m)\n| order by TimeGenerated asc \n",
            "resultFormat": "time_series",
            "workspace": "e59c41c9-c824-4052-9de3-265124652bfd"
          },
          "azureMonitor": {
            "dimensionFilter": "*",
            "metricDefinition": "select",
            "metricName": "select",
            "resourceGroup": "select",
            "resourceName": "select",
            "timeGrain": "auto"
          },
          "queryType": "Azure Log Analytics",
          "refId": "A",
          "subscription": "db875562-f539-49a6-9f07-11b0b5206e67"
        }']
        );

dashboard.new(
  '#VM Test',
  schemaVersion=16,
  tags=['Test AAB'],
)
.addTemplate(
  grafana.template.datasource(
    'AZURE_MONITOR',
    'Azure Monitor',
    'Azure Monitor',
    hide='label',
  )
)
.addTemplate(
  template.new(
    'ResourceGroup',
    '$AZURE_MONITOR',
    'ResourceGroups()',
    label='ResourceGroup',
    refresh='time',
  )
)
.addTemplate(
  template.new(
    'instance',
    '$AZURE_MONITOR',
    'ResourceNames($ResourceGroup, Microsoft.Compute/virtualMachines)',
    label='Instance',
    refresh='time',
  )
)
.addPanels(
  [
    buildInfo { gridPos: { h: 4, w: 3, x: 0, y: 0 } }
  ]
)

