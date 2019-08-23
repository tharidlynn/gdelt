#! /usr/bin/env bash

set -x
set -e

function install_anaconda() {
    sleep 10
    curl -Lko /tmp/anaconda https://repo.continuum.io/archive/Anaconda3-2018.12-Linux-x86_64.sh 
    bash /tmp/anaconda -b -p /home/ubuntu/anaconda3
    rm -f /tmp/anaconda
    export PATH=$PATH:/home/ubuntu/anaconda3/bin
    echo 'export PATH=$PATH:/home/ubuntu/anaconda3/bin' >> ~/.bashrc
    chown -R ubuntu:ubuntu /home/ubuntu/anaconda3
}

function install_dependencies() {
    sleep 10
    sudo apt-get update
    sleep 10
    sudo apt install -y gcc
    sudo apt install -y bzip2
    sudo apt install -y wget
}

function install_pip_dependencies() {
    sleep 10
    pip install -r requirements.txt
}

function install_airflow() {
    sleep 10
    mkdir -p /home/ubuntu/airflow/dags
    mv /home/ubuntu/airflow.cfg /home/ubuntu/airflow/

    export AIRFLOW_HOME=/home/ubuntu/airflow
    export SLUGIFY_USES_TEXT_UNIDECODE=yes
    pip install "apache-airflow[postgres,s3]"
    pip install tenacity==4.12.0 #python3.7 has tenacity dependices error with async, we have to bump up version
    chown -R ubuntu:ubuntu /home/ubuntu/airflow

    sleep 10
}

START_TIME=$(date +%s)

install_dependencies
install_anaconda
install_pip_dependencies
install_airflow

END_TIME=$(date +%s)
ELAPSED=$(($END_TIME - $START_TIME))

echo "Deployment complete. Time elapsed was [$ELAPSED] seconds"