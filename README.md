# qasmat-swarm-deploy
Deploy qasmat with docker-swarm and ansible

**Qasmat** is a secure distributed storage system based on Shamir's Secret Sharing to split files into pieces and store them on a network of storage servers. It ensures data availability even when some servers are offline, without compromising security as in traditional redundancy. The system prevents an attacker having access to some servers from gaining information on the protected files. More about qasmat: https://qasmat.veriqloud.fr.

The aim of this repository is to provide a way to deploy and test qasmat quickly in your environment. For kubernetes based solutions, please kindly [contact us](https://veriqloud.com/contact/).

## Components of the application

- Webapp is based on [Caddy webserver](https://caddyserver.com/)
- Authentication with [Authelia](https://www.authelia.com/)
- [Proxy](https://qasmat.veriqloud.fr/discovering/overview.html) server for data dispatch. Public docker image is comming soon.
- [Storage](https://qasmat.veriqloud.fr/discovering/overview.html) servers who store the shares of the data. Public docker image is comming soon.
- Databases are set to default Sqlite. PSQL is coming soon.

## Prerequisites

Control  node:
- **Ansible** (ansible-core 2.17+)

Managed nodes in the inventory:
- Distiguished nodes to webapp/aithentication, proxy(server that dispatches data) and storages are recommended.
- Passwordless ssh access to all nodes.
- Root access to all nodes.

The scripts are optimised for Ubuntu/Debian.

## Setup

### Install Ansible on the control machine

Follow the official Ansible installation guide for your operating system:
🔗 [Ansible Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/index.html)

For example, on Ubuntu/Debian:
```shell
sudo apt update
sudo apt install ansible
```
### Clone the repository and create an inventory file

```shell
git clone git@github.com:Veriqloud/qasmat-swarm-deploy.git
cd qasmat-swarm-deploy
cp inventory_template.yaml invetory.yaml
```
Fill the values in the `vars` section of `inventory.yaml`.

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
# self-signed cerificates for HTTPS
*{{ web_dns }} {
    tls /caddy/data/certs/{{web_dns}}/fullchain.pem /caddy/data/certs/data/certs/{{web_dns}}/privkey.pem
}
```
for example, given that certficates are copied to the server hosting the web service to the folder `/caddy/data/certs/{{web_dns}}`; as `/caddy/data` folder is mounted to the container of the web service. It is possible to mount certificates elsewhere; the mount should be added to [docker compose template](roles/docker_swarm_deploy/templates/docker-compose.yml.j2).

### Note on authentication

Users are configured in [users template](roles/add_web_config/templates/users.yml.j2). The deafult admin user is `qasmatadmin` password is `password`.
