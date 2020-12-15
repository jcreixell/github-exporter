local common = import 'common.libsonnet';
local grafana = import 'github.com/grafana/grafonnet-lib/grafonnet/grafana.libsonnet';

grafana.dashboard.new('GitHub API Usage', uid='github-api-usage', editable=true)
.addTemplate(
  grafana.template.datasource(
    'datasource',
    'prometheus',
    'Prometheus'
  )
)
.addPanels(
  [
    grafana.text.new('GitHub Request Limits', content=|||
      GitHub metrics are generated by calling the GitHub API, which will throttle if too many requests are made in an 
      hour. When this happens, gaps will appear for the metrics.

      This dashboard monitors the API usage, so you can tell if you are running out of requests. If this does 
      become a problem, consider reducing the set of repositories being monitored or the number of metrics being 
      generated, in order to reduce the request rate.
    |||) +
    { gridPos: { x: 0, y: 0, w: 24, h: 4 } },

    grafana.graphPanel.new(
      'API Usage',
      min=0,
    )
    .addTarget(grafana.prometheus.target('github_rate_remaining', legendFormat='Remaining Requests'))
    .addTarget(grafana.prometheus.target('github_rate_limit', legendFormat='Max Requests')) +
    { gridPos: { x: 8, y: 4, w: 16, h: 10 } },

    common.latestSingleStatPanel('Current Remaining Requests in Time Window')
    .addTarget(grafana.prometheus.target('github_rate_remaining')) +
    { gridPos: { x: 0, y: 4, w: 8, h: 5 } },

    common.latestSingleStatPanel('Current Max Requests Per Hour')
    .addTarget(grafana.prometheus.target('github_rate_limit')) +
    { gridPos: { x: 0, y: 9, w: 8, h: 5 } },

  ]
)
