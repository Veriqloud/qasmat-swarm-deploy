# qasmat-swarm-deploy
Deploy qasmat with docker-swarm and ansible

**Qasmat** is a secure distributed storage system based on Shamir's Secret Sharing to split files into pieces and store them on a network of storage servers. It ensures data availability even when some servers are offline, without compromising security as in traditional redundancy. The system prevents an attacker having access to some servers from gaining information on the protected files. More about qasmat: 🔗https://qasmat.veriqloud.fr.

The aim of this repository is to provide a way to deploy and test qasmat quickly in your environment. For kubernetes based solutions, please kindly 🔗[contact us](https://veriqloud.com/contact/).

## Components of the application

- Webapp is based on [Caddy webserver](https://caddyserver.com/). Public docker image is available on 🔗[Docker Hub](https://hub.docker.com/r/veriqloud/qasmat-web).
- Authentication with your own ID provider, OIDC-compatible, or a Keycloak instance
- Proxy server for data dispatch. Public docker image is available on 🔗[Docker Hub](https://hub.docker.com/r/veriqloud/qasmat-proxy-lite).
- Storage servers who store the shares of the data. Public docker image is available on 🔗[Docker Hub](https://hub.docker.com/r/veriqloud/qasmat-storage-lite).
- Databases are set to default SQLite. PostgreSQL is coming soon.

## Prerequisites

Control  node:
- **Ansible** (ansible-core 2.17+)

Managed nodes in the inventory:
- Distinct nodes to webapp/authentication, proxy (server that dispatches data) and storages are recommended.
- Passwordless ssh access to all nodes.
- Root access to all nodes.
- The scripts are optimised to Ubuntu/Debian OS, we kindly recommend to use Ubuntu.

DNS:
- a domain name
- two subdomains

Authentication:
- Either you have an identity provider setup as [described here](./authentication.md).
- Or a keycloak instance is deployed along with the application. In this case you must provide a additionnal subdomain.
See the inventory.


## Setup

**Note**: All the following steps are performed from the installation (control) machine, which may — and often does — differ from the managed nodes themselves. 

### Install Ansible on the control machine

Follow the official Ansible installation guide for your operating system:
🔗 [Ansible Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/index.html)

E.g. Ubuntu/Debian
```shell
sudo apt install ansible
```

E.g. Fedora
```shell
sudo dnf install ansible
```

### Clone the repository and create an inventory file

```shell
git clone git@github.com:Veriqloud/qasmat-swarm-deploy.git
cd qasmat-swarm-deploy
cp inventory_template.yaml inventory.yaml
```
Fill the values in `inventory.yaml`.

### Install dependencies
```
ansible-galaxy install -r requirements.yaml
```

### Generate secret templates and run the playbook

```shell
./generate_secrets.sh
# run ansible playbook with default inventory.yaml (set in ansible.cfg) 
ansible-playbook playbooks/setup.yaml
```

---
### Note on ssl certificates

If self signed certificates are necessary instead of Let's encrypt certificates, that can be indicated in the [Caddyfile](roles/add_web_config/templates/Caddyfile.j2) adding the following lines using the `tls` directive:

```bash
# self-signed certificates for HTTPS
*{{ web_dns }} {
    tls /caddy/data/certs/{{web_dns}}/fullchain.pem /caddy/data/certs/data/certs/{{web_dns}}/privkey.pem
}
```
for example, given that certificates are copied to the server hosting the web service to the folder `/caddy/data/certs/{{web_dns}}`; as `/caddy/data` folder is mounted to the container of the web service. It is possible to mount certificates elsewhere; the mount should be added to [docker compose template](roles/docker_swarm_deploy/templates/docker-compose.yml.j2).

### Note on usage

If you enable keycloak the default admin user is `qasmatadmin` password is `password`.

### Note on usage

The web interface will be accessible at `<web_dns>` provided in the customized `inventory.yaml`.

To explore the logs ssh into the manager node (proxy) and hit `docker service logs qasmat_<service_name>` or `docker service inspect qasmat_<service_name>`.
