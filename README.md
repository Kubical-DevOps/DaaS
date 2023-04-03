# Setup

## Requirements

- [Jsonnet](https://jsonnet.org/)
- [jsonnet-bundler](https://github.com/jsonnet-bundler/jsonnet-bundler)
- [gojsontoyaml](https://github.com/brancz/gojsontoyaml)

## Dependencies installation

    jb install

# Update

## Add dashboard

- Add the dashboard (JSON or [Jsonnet](https://jsonnet.org/) file) in directory [`dashboards`](./dashboards);

- Update the index:

      dashboards/update.sh

- Commit the change.

## Generate manifests

You can generate YAML manifests with the following command:

    ./build.sh

Manifest files are saved in the directory `manifests`.
