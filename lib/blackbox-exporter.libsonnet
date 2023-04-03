local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';

{
  _config+:: {
    namespace: 'default',

    imageRepos+:: {
      blackboxExporter: 'prom/blackbox-exporter',
    },

    versions+:: {
      blackboxExporter: 'v0.15.0',
    },

    blackboxExporter+:: {
      targets+:: [],
    },
  },

  blackboxExporter: {
    deployment:
      local deployment = k.apps.v1.deployment;
      local container = k.apps.v1.deployment.mixin.spec.template.spec.containersType;

      local targetPort = 9115;

      local c =
        container.new('blackbox-exporter', $._config.imageRepos.blackboxExporter + ':' + $._config.versions.blackboxExporter) +
        container.withPorts(container.portsType.newNamed(targetPort, 'http'));

      local podLabels = { app: 'prometheus-blackbox-exporter' };

      deployment.new('prometheus-blackbox-exporter', 1, c, podLabels) +
        deployment.mixin.spec.selector.withMatchLabels(podLabels) +
        deployment.mixin.metadata.withNamespace($._config.namespace),
    
    service:
      local service = k.core.v1.service;
      local servicePort = k.core.v1.service.mixin.spec.portsType;

      local port = servicePort.newNamed('http', 9115, 'http');

      service.new('prometheus-blackbox-exporter', $.blackboxExporter.deployment.spec.selector.matchLabels, [port]) +
        service.mixin.metadata.withLabels({ app: 'prometheus-blackbox-exporter' }) +
        service.mixin.metadata.withNamespace($._config.namespace),
    
    scrapeConfig:: [
      {
        job_name: 'external-services',
        metrics_path: '/probe',
        static_configs: [{
          labels: {
            module: 'http_2xx',
          },
          targets: $._config.blackboxExporter.targets,
        }],
        relabel_configs: [
          {
            source_labels: ['__address__'],
            target_label: '__param_target',
          },
          {
            source_labels: ['__param_target'],
            target_label: 'instance',
          },
          {
            target_label: '__address__',
            replacement: $.blackboxExporter.service.metadata.name + ':9115',
          },
        ],
      },
    ],
  },

  prometheus+: {
    'additional-scrape-configs'+:
      local secret = k.core.v1.secret;
      local additionalScrapeConfigs = {
        'prometheus-additional.yaml': std.base64(std.manifestYamlDoc($.blackboxExporter.scrapeConfig)),
      };

      secret.new('prometheus-additional-scrape-configs', additionalScrapeConfigs) +
      secret.mixin.metadata.withNamespace($._config.namespace),
    
    prometheus+: {
      spec+: {
        additionalScrapeConfigs: {
          name: 'prometheus-additional-scrape-configs',
          key: 'prometheus-additional.yaml',
        },
      },
    },
  },
}
