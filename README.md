# qasmat-swarm-deploy
Deploy qasmat with docker-swarm and ansible

**Qasmat** is a secure distributed storage system based on Shamir's Secret Sharing to split files into pieces and store them on a network of storage servers. It ensures data availability even when some servers are offline, without compromising security as in traditional redundancy. The system prevents an attacker having access to some servers from gaining information on the protected files. More about qasmat: https://qasmat.veriqloud.fr.

The aim of this repository is to provide a way to deploy and test qasmat quickly in your environment. For kubernetes based solutions, please kindly [contact us](https://veriqloud.com/contact/).

## Components of the application

- Webapp is based on [Caddy webserver](https://caddyserver.com/)
- Authentication with [Authelia](https://www.authelia.com/)
- [Proxy](https://qasmat.veriqloud.fr/discovering/overview.html) server for data dispatch. Public docker image is coming soon.
- [Storage](https://qasmat.veriqloud.fr/discovering/overview.html) servers who store the shares of the data. Public docker image is comming soon.
- Databases are set to default SQLite. PostgreSQL is coming soon.

## Prerequisites

Control  node:
- **Ansible** (ansible-core 2.17+)

Managed nodes in the inventory:
- Distinct nodes to webapp/authentication, proxy (server that dispatches data) and storages are recommended.
- Passwordless ssh access to all nodes.
- Root access to all nodes.
- Ubuntu OS for all nodes

DNS:
Have a domain name and 3 subdomains linked to the corresponding services (see the inventory).

## Setup

**Note**: All the following steps are performed from the installation (control) machine, which may — and often does — differ from the managed nodes themselves. 

### Install Ansible on the control machine

Follow the official Ansible installation guide for your operating system:
🔗 [Ansible Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/index.html)

E.g. Ubuntu
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
cp inventory_template.yaml inventory.yml
```
Fill the `# TODO` values in `inventory.yml`.

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

Storage servers may take some time to connect to the proxy due to DNS issue. We are currently working on this.


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

### Note on authentication

Users are configured in [users template](roles/add_web_config/templates/users.yml.j2). The default admin user is `qasmatadmin` password is `password`.

## Usage

The web interface is now accessible at `<web_dns>` (value in your inventory).

To explore the logs you can ssh one of the nodes and use docker commands like `docker logs <id of the container>` or `docker inspect <id of the container>`.

Don't hesitate to explore the [documentation](https://qasmat.veriqloud.fr/) for more information and reach out if anything is missing or if you have any suggestion.

Note : We will very soon be OAuth/OIDC compatible which means that Qasmat will be able to use identity providers such as Keycloak instead of our default Authelia instance. 
