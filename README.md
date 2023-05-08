# Unbound Statistics

<p align="center">
    <img src="https://github.com/madnuttah/unbound-docker-stats/blob/main/unbound-stats/screenshots/Screenshot1.jpg" alt="Logo">
</p>

I wanted to have the statistics of Unbound in my Grafana and I didn't want to modify my [`Unbound Docker Image`](https://github.com/madnuttah/unbound-docker) to use any third party tools like `Zabbix sender` so I was searching for a way to get them into Zabbix and ship the stats to Grafana. 

Zabbix active agents can ingest files, so Unbound-Control creates a file with the statistics using a modified healthcheck script and an active Zabbix agent reads and processes the log and saves the values into the Zabbix database. 

***

### Instructions:

Adapt the `unbound.conf` to enable extended statistics:

```
server:	
	extended-statistics: yes
        statistics-cumulative: no
	statistics-interval: 0	
```

Download the modified [`healthcheck.sh`](https://github.com/madnuttah/unbound-docker-stats/blob/main/unbound-stats/healthcheck.sh) script and place it in your persistent Unbound volume.

You also need to modify your unbound `docker-compose` and add the following lines to the `volumes` section. 

```
 ...
 
 unbound:
    container_name: unbound
    image: madnuttah/unbound:latest

    ...

    volumes:
    
      ...

      - ./unbound/healthcheck.sh:/usr/local/sbin/healthcheck.sh:rw
      - ./unbound/log.d/unbound-stats.log:/usr/local/unbound/log.d/unbound-stats.log:rw

      ...
    
    healthcheck:
      test: /usr/local/sbin/healthcheck.sh
      interval: 60s
      retries: 5
      start_period: 15s
      timeout: 30s  
      
    ...
```

Create an Active Zabbix agent on the docker host where Unbound runs on.

Map the `unbound-stats.log` to the agent's volumes in it's `docker-compose` like so:

```
  ...
  
  zabbix-agent2:
    image: zabbix/zabbix-agent2:alpine-6.4-latest
    
	...
    
	volumes:
      
	  ...
	  
          - ./unbound/log.d/unbound-stats.log:/var/log/unbound-stats.log:ro
          - /var/run/docker.sock:/var/run/docker.sock:ro
	  
        ...
```

Download my Zabbix [`template`](https://github.com/madnuttah/unbound-docker-stats/blob/main/unbound-stats/Zabbix%20Template%20Unbound%20Statistics.yaml) and import it into your host in Zabbix.

Zabbix should display values in `Latest Data` after a little while and you can now begin to configure your Grafana panels as you like.

If you run in trouble, please verify that the permissions are correct, otherwise fix them accordingly. You can always access the running image with `sudo docker exec -ti CONTAINERNAME /bin/sh`.

As this is my first template for Zabbix I guess there are many things to optimize or to make better. It's working for me and if you like to contribute, you're most welcome.

**This was tested only with Zabbix 6.4.**
