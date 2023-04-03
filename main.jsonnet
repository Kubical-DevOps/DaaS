local kp =
  // Import main 'kube-prometheus' library
  (import 'kube-prometheus/kube-prometheus.libsonnet') +

  // Possible patches:
  // (import 'kube-prometheus/kube-prometheus-anti-affinity.libsonnet') +
  // (import 'kube-prometheus/kube-prometheus-managed-cluster.libsonnet') +
  // (import 'kube-prometheus/kube-prometheus-node-ports.libsonnet') +
  // (import 'kube-prometheus/kube-prometheus-static-etcd.libsonnet') +
  // (import 'kube-prometheus/kube-prometheus-thanos-sidecar.libsonnet') +

  // Import custom dashboards
  (import 'dashboards/index.libsonnet') +

  // Add Ingress
  (import 'ingress.libsonnet') +

  {
    _config+:: {
      namespace: 'monitoring',

      // Configure image versions
      versions+:: {
        grafana: '6.4.1',
      },
      // Configure Grafana
      grafana+:: {
        // Main Grafana config
        // Cf. http://docs.grafana.org/installation/configuration/
        config: {
          sections: {
            server: {
              domain: $.ingress.grafana.spec.rules[0].host,
              root_url: "%(protocol)s://%(domain)s/grafana/",
              serve_from_sub_path: true,
              enable_gzip: true,
            },
            security: {
              admin_password: 'test', // will be removed (cf below)
              // disable_admin_user: true, // Wait for https://github.com/grafana/grafana/pull/19505/files
              cookie_secure: true,
              cookie_samesite: 'strict',
              allow_embedding: false,
              strict_transport_security: true,
            },
            analytics: {
              reporting_enabled: false,
            },
            "auth.ldap": {
              enabled: true,
              allow_sign_up: true,
            },
          },
        },
        // LDAP configuration
        ldap: |||
          [[servers]]
          host = "ldap.identity.svc.cluster.local"
          port = 389
          use_ssl = false
          start_tls = false
          search_filter = "(uid=%s)"
          search_base_dns = ["ou=users,dc=moncef"]
          group_search_filter = "(&(objectClass=groupOfUniqueNames)(uniqueMember=%s))"
          group_search_base_dns = ["ou=groups,dc=moncef"]
          group_search_filter_user_attribute = "dn"

          [servers.attributes]
          name = "givenName"
          surname = "sn"
          username = "uid"
          member_of = "memberOf"
          email =  "mail"

          [[servers.group_mappings]]
          group_dn = "cn=jenkins-users,ou=groups,dc=moncef"
          org_role = "Admin"
          grafana_admin = true
        |||,

        // grafana-image-renderer is pretty large and installing it
        // currently generates an out-of-memory error
        // plugins+: [
        //   'grafana-image-renderer',
        // ],

        // Notifiers configuration
        notifiers+: [{
          name: 'notification-slack',
          type: 'slack',
          uid: 'notifier1',
          org_name: 'Main Org.',
          is_default: true,
          send_reminder: true,
          frequency: '1h',
          disable_resolve_message: false,
          settings: {
            uploadImage: false,

            # TODO: Incoming webhook URL should be kept private
            url: 'test'
          },
        }],
      },
    },
  };

// Generate main JSON object
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
{ ['ingress-' + name]: kp.ingress[name] for name in std.objectFields(kp.ingress) }
