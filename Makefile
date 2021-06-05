DOCKER_NETWORK = hadoop_default
ENV_FILE = hadoop.env
HADOOP_VERSION = 2.7.4
TAG = 2.0.0-hadoop2.7.4-java8
ARCH = amd64

build:
	docker build -t hadoop-base:${TAG} --build-arg ARCH=${ARCH} --build-arg HADOOP_VERSION=${HADOOP_VERSION} ./base
	docker build -t hadoop-namenode:${TAG} --build-arg TAG=${TAG} ./namenode
	docker build -t hadoop-datanode:${TAG} --build-arg TAG=${TAG} ./datanode
	docker build -t hadoop-resourcemanager:${TAG} --build-arg TAG=${TAG} ./resourcemanager
	docker build -t hadoop-nodemanager:${TAG} --build-arg TAG=${TAG} ./nodemanager
	docker build -t hadoop-historyserver:${TAG} --build-arg TAG=${TAG} ./historyserver
	docker build -t hadoop-submit:${TAG} --build-arg TAG=${TAG} ./submit

wordcount:
	docker build -t hadoop-wordcount:${TAG} --build-arg TAG=${TAG} ./submit
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-base:${TAG} hdfs dfs -mkdir -p /input/
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-base:${TAG} hdfs dfs -copyFromLocal /opt/hadoop-2.7.4/README.txt /input/
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-wordcount
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-base:${TAG} hdfs dfs -cat /output/*
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-base:${TAG} hdfs dfs -rm -r /output
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-base:${TAG} hdfs dfs -rm -r /input

start:
	TAG=${TAG} docker compose up

stop:
	TAG=${TAG} docker compose down