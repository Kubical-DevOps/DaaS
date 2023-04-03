local k = import 'ksonnet/ksonnet.beta.3/k.libsonnet';
local ingress = k.extensions.v1beta1.ingress;
local ingressTls = ingress.mixin.spec.tlsType;
local ingressRule = ingress.mixin.spec.rulesType;
local httpIngressPath = ingressRule.mixin.http.pathsType;

local ingressHost = 'testol.hopto.org';

{
  ingress+:: {
    grafana:
      ingress.new() +
      ingress.mixin.metadata.withName('grafana-ingress') +
      ingress.mixin.metadata.withNamespace($._config.namespace) +
      ingress.mixin.metadata.withAnnotations({
        'certmanager.k8s.io/cluster-issuer': 'letsencrypt-prod',
      }) +
      ingress.mixin.spec.withTls(
        ingressTls.new() +
        ingressTls.withHosts([ingressHost]) +
        ingressTls.withSecretName('letsencrypt-secret')
      ) +
      ingress.mixin.spec.withRules(
        ingressRule.new() +
        ingressRule.withHost(ingressHost) +
        ingressRule.mixin.http.withPaths(
          httpIngressPath.new() +
          httpIngressPath.withPath('/grafana/') +
          httpIngressPath.mixin.backend.withServiceName('grafana') +
          httpIngressPath.mixin.backend.withServicePort('http')
        ),
      ),
  },
}
