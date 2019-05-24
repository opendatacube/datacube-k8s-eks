# Addons

## Flux

ensure flux is enabled in the config, and has been deployed with `make apply`

```bash
fluxctl identity --k8s-fwd-ns flux
```

copy this and put it in a service account that can write to your flux repo
