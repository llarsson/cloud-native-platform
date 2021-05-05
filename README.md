# cloud-native-platform

Repo for "How to build your own cloud-native platform on IaaS clouds in 2021"

This repo uses Exoscale as if it were just an IaaS cloud provider, that is, it does not leverage their Kubernetes service, but rather, just virtual machines. It is therefore almost exactly what you would use if you were deploying on bare metal, bare VMs (what we are doing), or some cloud provider that lacks all kinds of fancy load balancing or storage services. Truly bare-bones!

But the goal is that we get a cluster that supports:

 - ✅ Network security (Calico, cert-manager, Network Policies)
 - ✅ Authentication (Dex IdP)
 - ✅ Storage service (Rook and Ceph)
 - ✅ Database services (Zalando Postgres Operator)
 - ✅ Log handling and analysis (Elasticsearch and Filebeat)
 - ✅ Application-aware detailed monitoring (Prometheus and Grafana)
 - ✅ Container image registry (Harbor)
 - ✅ Continuous delivery (ArgoCD)

...so we're fine with just bare VMs. :)

## Prerequisites

You will need a good local stack with bash, kubectl (with `krew` to manage plugins and the `oidc-login` plugin installed), terraform, the `exo` command line tool for working with Exoscale, and Python 3 on your laptop. And a web browser, of course.

Get yourself an Exoscale account, and set up API access. You should also make your Exoscale API access credentials available in the `~/.cloudstack.ini` file if you want the Terraform provider to Just Work.

You will also need a Google account and administrative permissions so you can give privileges to a service account for single-sign on (SSO) purposes. Follow the guide [here](https://elastisys.com/elastisys-engineering-how-to-use-dex-with-google-accounts-to-manage-access-in-kubernetes/).

Finally, do note that this repo has git submodules, so go fetch them as part of cloning this repo. You can easily add `--recurse-submodules` as part of your `git clone` command. Or just go `git submodule update --init --recursive` to fetch them after the fact.

## Usage

### Configuration

First, `export` some environment variables:

 - `TOP_LEVEL_DOMAIN`, the TLD under which your cluster should register itself and the services that it will expose. For instance, if you want to deploy a cluster called `my-demo-cluster` and it should register itself under `example.com`, `TOP_LEVEL_DOMAIN` should be `example.com`. You will then be able to access e.g. ArgoCD under `arg.my-demo-cluster.example.com` once you've installed it.
 - `ADMIN_GROUP`, the group in your Google account that administrators belongs to. Will typically look like `admins@yourcompany.com`.
 - `EMAIL`, your email address, used for Let's Encrypt certificates.
 - `ADMIN_EMAIL`, the email address of an administrator in your Google account. Could be yours?
 - `DEX_CLIENT_ID`, the client ID that your Google SSO account integration gives you (see guide above).
 - `DEX_CLIENT_SECRET`, the secret associated to the Google SSO client ID.
 - `SA_FILE`, the service account JSON file that you downloaded from Google as part of following the SSO guide above.

Optionally, if you don't want your cluster to be called `xxx-demo-cluster`, where `xxx` is your local username (determined via `whoami`), you can export `CLUSTER` to be whatever you want it to be called. Regular DNS name rules apply, so no spaces or similar.

### Installation

Now, you can set up your cluster. Do that via:

 1. `cd cluster/`
 1. `./setup.sh` to render the initial configuration files to deploy the cluster.
 1. `./install_ansible.sh` to install Ansible and its dependencies in a virtualenv, so don't worry, it won't explode Python dependencies all over your system.
 1. `./apply.sh` to run Terraform and get your cluster's VMs up and running. This step costs money.
 1. `./run_ansible.sh` to install Kubernetes.
 1. `./install_nginx_ingress_controller.sh` to install the NGINX Ingress Controller, so we can get traffic into the cluster.
 1. `./configure_dns.sh` to set up a DNS wildcard record for `*.${CLUSTER}.${TOP_LEVEL_DOMAIN}`, so that any service we expose under that wildcard will be accessible via the NGINX Ingress Controller.
 1. `source export_kubeconfig.sh` to make your `kubectl` know where the cluster is.

If you at this point issue a `kubectl get nodes` command, you should see your cluster present itself. Success!

Install network security features (cert-manager) next:

 1. `cd ../network-security/`
 1. `./install_cert-manager.sh`

Install authentication via SSO capabilities:

 1. `cd ../authentication/`
 1. `./install_dex.sh`

Try a `kubectl get nodes` command, and it'll now make you log in via your Google account!

Install persistent storage support so you can provision Persistent Volumes:

 1. `cd ../persistent-storage/`
 1. `./install_rook_ceph.sh`

Install a database service, namely, the Zalando Postgres Operator:

 1. `cd ../database/`
 1. `./install_postgres.sh`

You can now easily request PostgreSQL databases as per the [Postgres Operator Quickstart](https://github.com/zalando/postgres-operator/blob/master/docs/quickstart.md#create-a-postgres-cluster) documentation.

Install logging support, with your very own Elasticsearch and Filebeat:

 1. `cd ../logging/`
 1. `./install_elasticsearch.sh` (you might want to wait a bit here at this stage)
 1. `./install_filebeat.sh`

You can go to your very own Kibana instance by following the instructions that appear in your terminal. We are not exposing it to the Internet, because we can't do OIDC integration without paying for the Enterprise licence. 🙄

Install monitoring support with Prometheus and Grafana, supporting OIDC logins via Dex:

 1. `cd ../monitoring/`
 1. `./install_monitoring.sh`

You can go to `grafana.${CLUSTER}.${TOP_LEVEL_DOMAIN}` to interact with it.

Install container image registry via Harbor, also supporting OIDC logins via Dex:

 1. `cd ../container-registry/`
 1. `./install_harbor.sh`

Read the [container registry README](container-registry/README.md) to find out how to integrate OIDC with Dex.

You can go to `harbor.${CLUSTER}.${TOP_LEVEL_DOMAIN}` to interact with it.

Install continuous delivery tooling (ArgoCD), that also supports OIDC logins via Dex:

 1. `cd ../continuous-delivery/`
 1. `./install_argocd.sh`

You can go to `argo.${CLUSTER}.${TOP_LEVEL_DOMAIN}` to interact with it.

# Questions?

Don't hesitate to send questions either via GitHub Issues in this repo or to me directly at [lars.larsson@elastisys.com](mailto:lars.larsson@elastisys.com)!
