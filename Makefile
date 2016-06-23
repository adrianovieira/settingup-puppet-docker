# Makefile
# Author: Adriano Vieira <adriano.svieira at gmail.com>>

# start the Puppet Server
default:

# start the Puppet Server with your own Puppet code (dir ./code)
devel: down clean
	docker run -d --net puppet --name puppet --hostname puppet -v code:/etc/puppetlabs/code/ -p 8140:8140 puppet/puppetserver
	docker run -d --net puppet --name postgres --hostname postgres -e POSTGRES_PASSWORD=puppetdb -e POSTGRES_USER=puppetdb puppet/puppetdb-postgres
	docker run -d --net puppet --name puppetdb --hostname puppetdb --link postgres:postgres --link puppet:puppet -p 8080-8081:8080-8081 puppet/puppetdb
	docker run -d --net puppet --name puppetboard --hostname puppetboard --link puppetdb:puppetdb --link puppet:puppet -p 8000:8000 puppet/puppetboard
	docker run -d --net puppet --name puppetexplorer --hostname puppetexplorer --link puppetdb:puppetdb --link puppet:puppet -p 80:80 puppet/puppetexplorer

down:
	docker kill puppet puppetdb postgres puppetboard puppetexplorer || true

pull:
	docker pull puppet/puppetserver
	docker pull puppet/puppetdb
	docker pull puppet/puppetdb-postgres
	docker pull puppet/puppetboard
	docker pull puppet/puppetexplorer

setup:
	docker network create puppet

clean:
	docker rm puppet puppetdb postgres puppetboard puppetexplorer || true

clean-all: down clean
	docker network rm puppet
