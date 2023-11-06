# Prerequisites
#
- JDK 11 
- Maven 3 
- MySQL 8

# Technologies 
- Spring MVC
- Spring Security
- Spring Data JPA
- Maven
- JSP
- Tomcat
- MySQL
- Memcached
- Rabbitmq
- ElasticSearch
# Database
Here,we used Mysql DB 
sql dump file:
- /src/main/resources/db_backup.sql
- db_backup.sql file is a mysql dump file.we have to import this dump to mysql db server
- > mysql -u <user_name> -p accounts < db_backup.sql


# Virtual Environment

This is the virtualization blueprint to deploy:
* PostgreSQL
* pgBackrest
* Prometheus
* Grafana

## Requirements

* Vagrant (tested on 1.8.6)
* Virtual Box (tested on 5.1.6)
* `vagrant-hostmanager`

To install `vagrant-hostmanager` run the following:

```bash
$ vagrant plugin install vagrant-hostmanager
```

## Deploy

```bash
$ vagrant up
```

## Access Prometheus

First, create an SSH tunnel to prometheus:

```bash
$ ssh -i .vagrant/machines/prometheus/virtualbox/private_key \
      -N -f -L 9090:localhost:9090 vagrant@172.17.8.102
```

Next, create an SSH tunnel to grafana:

```bash
$ ssh -i .vagrant/machines/grafana/virtualbox/private_key \
      -N -f -L 3000:localhost:3000 vagrant@172.17.8.103
```

Next, navigate to the following:

```bash
http://localhost:9090/
http://localhost:3000/
```

## Setup Prometheus Datasource

After logging into Grafana, a datasource will need to be configured.  [Follow these
instructions to setup the datasource.](https://github.com/jasonodonnell/grafana-pgsql-monitoring)

## Setup Dashboard

A sample dashboard is located in `./services/grafana/config/dashboard.json`.  Copy this json
blob and import it as a new dashboard by clicking the Dashboard > Import on the top left menu.

```text
sudo dnf install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo dnf install postgresql11-libs
dnf install postgresql
psql -h postgres.dev -U your_postgres_user -d your_database_name -W

sudo vi /var/lib/pgsql/data/pg_hba.conf
host    all             all             Grafana_IP/32        md5
sudo vi /var/lib/pgsql/data/postgresql.conf
listen_addresses = '*'
sudo systemctl restart postgresql



```