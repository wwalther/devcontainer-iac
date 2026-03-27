# Alpine Dev Container for IaC projects
![Static Badge](https://img.shields.io/badge/python-3.11.15-orange) ![Static Badge](https://img.shields.io/badge/alpine-3.23-blue)

![Static Badge](https://img.shields.io/badge/uv-0.11.2-blue)
![Static Badge](https://img.shields.io/badge/pre--commit-4.5.1-blue)

![Static Badge](https://img.shields.io/badge/tofu-1.11.5-blue)
![Static Badge](https://img.shields.io/badge/terragrunt-0.99.5-blue)

![Static Badge](https://img.shields.io/badge/az-2.84.0-blue)
![Static Badge](https://img.shields.io/badge/aws-2.34.18-blue)

## Motivation
The features for devcontainers where taking longer than I would like on startup, so this image was born.



## Dive output
```
Total Image size: 868 MB

53 MB  COPY /uv /uvx /bin/ # buildkit
113 MB  COPY /usr/local/bin/tofu /usr/local/bin/tofu # buildkit
78 MB  COPY /usr/local/bin/terragrunt /usr/local/bin/terragrunt # buildkit
355 MB  COPY /opt/az /opt/az # buildkit
175 MB  COPY /opt/aws-cli/ /opt/aws-cli/ # buildkit

drwxr-xr-x         0:0     531 MB  ├─⊕ opt
```

### Why the older python version
The project is using python 3.11.15 as a base because it is the only one that azure-cli wouldn't spit out garbage for.
Example:
```
/opt/az/lib/python3.13/site-packages/azure/batch/models/_models.py:9067: SyntaxWarning: invalid escape sequence '\ '
  """The source port ranges to match for the rule. Valid values are '\ *' (for all ports 0 - 65535),
/opt/az/lib/python3.13/site-packages/azure/batch/models/_models.py:9235: SyntaxWarning: invalid escape sequence '\ '
  using brackets (for example abc[\ *] would match a file named abc*\ ). Note that both and / are
{
  "azure-cli": "2.84.0",
  "azure-cli-core": "2.84.0",
  "azure-cli-telemetry": "1.1.0",
  "extensions": {}
}
```
