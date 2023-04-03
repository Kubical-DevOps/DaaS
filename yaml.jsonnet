local main = (import 'main.jsonnet');

[ main[name] for name in std.objectFields(main) ]
