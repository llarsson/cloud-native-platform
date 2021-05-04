# Container Registry (Harbor)

 1. `./install_harbor.sh`
 1. Go to `https://harbor.${CLUSTER}.${TOP_LEVEL_DOMAIN}/`, log in using the `admin/Harbor12345` credentials (unless you changed the default password).
 1. Enable [OpenID Connect authentication](https://goharbor.io/docs/2.2.0/administration/configure-authentication/oidc-auth/), and make it look like the screenshot below.

![OpenID Connect settings for Harbor][harbor-oidc.png]
