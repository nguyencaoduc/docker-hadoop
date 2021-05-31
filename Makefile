DOCKER_NETWORK = hadoop_default
ENV_FILE = hadoop.env
current_branch := 2.0.0-hadoop3.2.1-java8
build:
	docker build -t hadoop_base:$(current_branch) ./base
	docker build -t hadoop_namenode:$(current_branch) ./namenode
	docker build -t hadoop_datanode:$(current_branch) ./datanode
	docker build -t hadoop_resourcemanager:$(current_branch) ./resourcemanager
	docker build -t hadoop_nodemanager:$(current_branch) ./nodemanager
	docker build -t hadoop_historyserver:$(current_branch) ./historyserver
	docker build -t hadoop_submit:$(current_branch) ./submit

wordcount:
	docker build -t hadoop_wordcount ./submit
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop_base:$(current_branch) hdfs dfs -mkdir -p /input/
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop_base:$(current_branch) hdfs dfs -copyFromLocal -f /opt/hadoop-3.2.1/README.txt /input/
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop_wordcount
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop_base:$(current_branch) hdfs dfs -cat /output/*
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop_base:$(current_branch) hdfs dfs -rm -r /output
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop_base:$(current_branch) hdfs dfs -rm -r /input

start:
	docker compose up

stop:
	docker compose down