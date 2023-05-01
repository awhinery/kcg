# Docker Compose demos
I will get to making this an example Docker Compose group to spin up GoFlow as a demo. 

Both cloudflare/flow-pipeline (a sidebar from cloudflare/goflow) and netsampler/goflow2 
have Docker Compose demos, neither of which works as I write this in April 2023.

Docker Compose notes:

I use "docker compose" (a plugin to docker) instead of "docker-compose" (a separate[ish] package). I believe that "docker compose" 
is more 'modern'. 

Change directory to the compose folder under cloudflare/flow-pipeline or the compose/kcg folder under netsampler/goflow2, to start compose
groups. Note that this will not work in 2023 without fixing the configs.

Docker compose is a way to start of groups of containers and make them work together. You start the compose group by 
(having installed "docker compose) running: 

    docker compose up 
    # if the name of the yaml file in the local directory is "docker-compose.yml"
    docker compose -f docker-compose-clickhouse-collect.yml up 
    # as an example if the yaml file has a non-default name. 

The examples above will print plentiful logging to your screen, which may be what you want if you're starting it for the
first time. To start the compose container group in the background with no attachment to the current terminal, add " -d" after "up".

If you start the compose group attached to the current terminal, you can stop all of the group containers by typing CTRL-c in the terminal. 

If you have CTRL-c'd the terminal-attached version, or started the group with " -d", then doing:

     docker compose down
     or
     docker compose -f docker-compose-clickhouse-collect.yml down

will stop and delete all containers. 


In order to make the cloudflare/flow-pipeline/compose/docker-compose-clickhouse-collect.yml demo work:

###one
In the Kafka engine table "flows", the schema is referred to as:

kafka_schema = './flow.proto:FlowMessage';

but the .proto reader in Clickhouse Kafka Engine doesn't like relative paths (which I found by running a bash in the compose-db-1 container (clickhouse) in the /var/log/clickhouse/ logs

It also does not like fully-qualified paths, so the correct answer is:
 
kafka_schema = 'flow.proto:FlowMessage';

(without the './' before the filename )

###two
Delete the Grafana section from the docker-compose-clickhouse-collect.yml file. It's set up to use provisioning to launch dashboards
and data sources, and even if you get it running, it will not allow you to alter dashboards. The example dashboards for Clickouse are 
worthless placeholders, and the Clickhouse Grafana plugin that it's trying to use is the old Altinity version, which could be made to
work, but spending energy on that would be less useful than using the newer Clickhouse datasource plugin, which is what you'll use in
"real life" anyways. I would plan to launch a separate container for Grafana, and you can build dashboards as you see fit. (I will make some 
examples in the ../Grafana folder. ) You could simply put a "blank" grafana into the compose file and work with that. If you start 
to develop/play with it, you will want persistence across restarts, so maybe plan to mount a volume on the Grafana container.

###three
Delete the Prometheus section of docker-compose-clickhouse-collect.yml. There's nothing wrong with it, as far as I know, but it's 
beside-the-point until you get kafka/clickhouse/goflow working. Prometheus is only there to monitor kafka/clickhouse/goflow, so you 
can add it back when you have a working thing. Plus, if you never go beyond trying out the demo, it's irrelevant. 


