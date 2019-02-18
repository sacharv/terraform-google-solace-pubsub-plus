#!/usr/bin/env bash
#
# source: https://github.com/SolaceLabs/solace-gcp-quickstart/blob/master/solos-install.sh#L15
#

# VARS
if [ "${type}" == "standard" ]; then
  # standard
  URL="https://products.solace.com/download/PUBSUB_DOCKER_STAND"
  MD5SUM="https://products.solace.com/download/PUBSUB_DOCKER_STAND_MD5"
elif [ "${type}" == "enterprise" ]; then
  # enterprise
  URL="https://products.solace.com/download/PUBSUB_DOCKER_EVAL"
  MD5SUM="https://products.solace.com/download/PUBSUB_DOCKER_EVAL_MD5"
else
  URL="https://products.solace.com/download/PUBSUB_DOCKER_STAND"
  MD5SUM="https://products.solace.com/download/PUBSUB_DOCKER_STAND_MD5"
fi

# VARS related to solace
USERNAME=admin
PASSWORD=${router_password}
LOG_FILE=install.log
SWAP_FILE=swap
SOLACE_HOME=`pwd`
fstype=xfs

echo "`date` INFO:Get repositories up to date" &>> $${LOG_FILE}
# ---------------------------------------

yum -y update &>> $${LOG_FILE}
yum -y install lvm2 wget curl &>> $${LOG_FILE}
# ---------------------------------------

# options for solace HA
redundancy_enable=${redundancy}
redundancy_group_password=${redundacy_group_password}

##General section - no editing required
## This ip-addresses are sourced from terraform if count is set to 3
redundancy_group_node_${baseroutername}0_connectvia=${monitor_ip}
redundancy_group_node_${baseroutername}0_nodetype=monitoring
redundancy_group_node_${baseroutername}1_connectvia=${primary_ip}
redundancy_group_node_${baseroutername}1_nodetype=message_routing
redundancy_group_node_${baseroutername}2_connectvia=${secondary_ip}
redundancy_group_node_${baseroutername}2_nodetype=message_routing

if [ "${router_role}" == "monitor" ]; then
##values for your monitor node
  nodetype=monitoring
  routername=${baseroutername}0
elif [ "${router_role}" == "primary" ]; then
##values for your primary node
  nodetype=message_routing
  routername=${baseroutername}1
  system_scaling_maxconnectioncount=${scaling}
  configsync_enable=yes
  redundancy_activestandbyrole=primary
  redundancy_matelink_connectvia=${secondary_ip}
elif [ "${router_role}" == "backup" ]; then
##values for your backup node
  nodetype=message_routing
  routername=${baseroutername}2
  configsync_enable=yes
  redundancy_activestandbyrole=backup
  system_scaling_maxconnectioncount=${scaling}
  redundancy_matelink_connectvia=${primary_ip}
else
  echo "unknown role or singleton selected, disabling redundancy" | tee -a $${LOG_FILE}
  redundancy_enable=${redundancy}
  configsync_enable=no
  system_scaling_maxconnectioncount=${scaling}
  unset redundancy_group_password
  unset redundancy_group_node_${baseroutername}0_connectvia
  unset redundancy_group_node_${baseroutername}0_nodetype
  unset redundancy_group_node_${baseroutername}1_connectvia
  unset redundancy_group_node_${baseroutername}1_nodetype
  unset redundancy_group_node_${baseroutername}2_connectvia
  unset redundancy_group_node_${baseroutername}2_nodetype
fi

#cloud init vars
#array of all available cloud init variables to attempt to detect and pass to docker image creation
#see http://docs.solace.com/Solace-VMR-Set-Up/Initializing-Config-Keys-With-Cloud-Init.htm
cloud_init_vars=( routername nodetype service_semp_port system_scaling_maxconnectioncount configsync_enable redundancy_activestandbyrole redundancy_enable redundancy_group_password redundancy_matelink_connectvia service_redundancy_firstlistenport )

# check if routernames contain any dashes or underscores and abort execution, if that is the case.
if [[ $${routername} == *"-"* || $${routername} == *"_"* || ${baseroutername} == *"-"* || ${baseroutername} == *"_"* ]]; then
  echo "Dashes and underscores are not allowed in routername(s), aborting..." | tee -a $${LOG_FILE}
  exit -1
fi

if [ ! -z $baseroutername ]; then
  echo "adding cloud_init vars for role ${router_role}" | tee -a $${LOG_FILE}
  echo $$redundancy_group_node_${baseroutername}0_nodetype | tee -a $${LOG_FILE}
  echo $$redundancy_group_node_${baseroutername}0_connectvia | tee -a $${LOG_FILE}
  echo $$redundancy_group_node_${baseroutername}1_nodetype | tee -a $${LOG_FILE}
  echo $$redundancy_group_node_${baseroutername}1_connectvia | tee -a $${LOG_FILE}
  echo $$redundancy_group_node_${baseroutername}2_nodetype | tee -a $${LOG_FILE}
  echo $$redundancy_group_node_${baseroutername}2_connectvia | tee -a $${LOG_FILE}

  cloud_init_vars+=( redundancy_group_node_${baseroutername}0_nodetype )
  cloud_init_vars+=( redundancy_group_node_${baseroutername}0_connectvia )
  cloud_init_vars+=( redundancy_group_node_${baseroutername}1_nodetype )
  cloud_init_vars+=( redundancy_group_node_${baseroutername}1_connectvia )
  cloud_init_vars+=( redundancy_group_node_${baseroutername}2_nodetype )
  cloud_init_vars+=( redundancy_group_node_${baseroutername}2_connectvia )

  echo "array ${router_role}: $${cloud_init_vars[@]}" | tee -a $${LOG_FILE}

fi


while [[ $# -gt 1 ]]
do
  key="$1"
  case $key in
      -i|--url)
        URL="$2"
        shift # past argument
      ;;
      -l|--logfile)
        LOG_FILE="$2"
        shift # past argument
      ;;
      -m|--md5sum)
        MD5SUM="$2"
        shift # past argument
      ;;
      -p|--password)
        PASSWORD="$2"
        shift # past argument
      ;;
      -u|--username)
        USERNAME="$2"
        shift # past argument
      ;;
      *)
            # unknown option
      ;;
  esac
  shift # past argument or value
done

echo "`date` INFO: Validate we have been passed a VMR url" &>> $${LOG_FILE}
# -----------------------------------------------------
if [ -z "$URL" ]
then
      echo "USAGE: vmr-install.sh --url <Solace Docker URL>" &>> $${LOG_FILE}
      exit 1
else
      echo "`date` INFO: VMR URL is $${URL}" &>> $${LOG_FILE}
fi

echo "`date` INFO:Set up Docker Repository" &>> $${LOG_FILE}
# -----------------------------------
tee /etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
echo "`date` INFO:/etc/yum.repos.d/docker.repo =\n `cat /etc/yum.repos.d/docker.repo`"  &>> $${LOG_FILE}

echo "`date` INFO:Intall Docker" &>> $${LOG_FILE}
# -------------------------
yum -y install docker-engine &>> $${LOG_FILE}

echo "`date` INFO:Configure Docker as a service" &>> $${LOG_FILE}
# ----------------------------------------
mkdir /etc/systemd/system/docker.service.d &>> install.log
tee /etc/systemd/system/docker.service.d/docker.conf <<-EOF
[Service]
  ExecStart=
  ExecStart=/usr/bin/dockerd --iptables=false --storage-driver=devicemapper
EOF
echo "`date` INFO:/etc/systemd/system/docker.service.d =\n `cat /etc/systemd/system/docker.service.d`" &>> $${LOG_FILE}

systemctl enable docker &>> $${LOG_FILE}
systemctl start docker &>> $${LOG_FILE}

echo "`date` INFO:Set up swap for < 6GB machines" &>> $${LOG_FILE}
# -----------------------------------------
MEM_SIZE=`cat /proc/meminfo | grep MemTotal | tr -dc '0-9'` &>> $${LOG_FILE}
if [ $${MEM_SIZE} -lt 6087960 ]; then
  echo "`date` WARN: Not enough memory: $${MEM_SIZE} Creating 2GB Swap space" &>> $${LOG_FILE}
  mkdir /var/lib/solace &>> $${LOG_FILE}
  dd if=/dev/zero of=/var/lib/solace/swap count=2048 bs=1MiB &>> $${LOG_FILE}
  mkswap -f /var/lib/solace/swap &>> $${LOG_FILE}
  chmod 0600 /var/lib/solace/swap &>> $${LOG_FILE}
  swapon -f /var/lib/solace/swap &>> $${LOG_FILE}
  grep -q 'solace\/swap' /etc/fstab || sudo sh -c 'echo "/var/lib/solace/swap none swap sw 0 0" >> /etc/fstab' &>> $${LOG_FILE}
else
   echo "`date` INFO: Memory size is $${MEM_SIZE}" &>> $${LOG_FILE}
fi

echo "`date` Format persistent volume" | tee -a $${LOG_FILE}
sudo mkfs.$${fstype} -q /dev/sdb
echo "`date` Pre-Define Solace required infrastructure" | tee -a $${LOG_FILE}

# -----------------------------------------------------
docker volume create --name=jail \
  --opt type=$${fstype} --opt device=/dev/sdb | tee -a $${LOG_FILE}
docker volume create --name=var \
  --opt type=$${fstype} --opt device=/dev/sdb | tee -a $${LOG_FILE}
docker volume create --name=internalSpool \
  --opt type=$${fstype} --opt device=/dev/sdb | tee -a $${LOG_FILE}
docker volume create --name=adbBackup \
  --opt type=$${fstype} --opt device=/dev/sdb | tee -a $${LOG_FILE}
docker volume create --name=softAdb \
  --opt type=$${fstype} --opt device=/dev/sdb | tee -a $${LOG_FILE}

# ------------------------------------------------

echo "`date` INFO:Get the md5sum of the expected solace image" &>> $${LOG_FILE}
# ------------------------------------------------
wget -O /tmp/solos.info -nv  $${MD5SUM}
IFS=' ' read -ra SOLOS_INFO <<< `cat /tmp/solos.info`
MD5_SUM=$${SOLOS_INFO[0]}
SolOS_LOAD=$${SOLOS_INFO[1]}
if [ -z $${MD5_SUM} ]; then
  echo "`date` ERROR: Missing md5sum for the Solace load" | tee /dev/stderr | tee /dev/stderr &>> $${LOG_FILE}
  exit 1
fi
echo "`date` INFO: Reference md5sum is: $${MD5_SUM}" &>> $${LOG_FILE}
echo "`date` INFO:Get the solace image" &>> $${LOG_FILE}
# ------------------------------------------------
wget -q -O  /tmp/$${SolOS_LOAD} $${URL}
LOCAL_OS_INFO=`md5sum /tmp/$${SolOS_LOAD}`
IFS=' ' read -ra SOLOS_INFO <<< $${LOCAL_OS_INFO}
LOCAL_MD5_SUM=$${SOLOS_INFO[0]}
if [ $${LOCAL_MD5_SUM} != $${MD5_SUM} ]; then
  echo "`date` ERROR: Possible corrupt Solace load, md5sum do not match" | tee /dev/stderr &>> $${LOG_FILE}
  exit 1
else
  echo "`date` INFO: Successfully downloaded $${SolOS_LOAD}" &>> $${LOG_FILE}
fi
docker load -i /tmp/$${SolOS_LOAD} &>> $${LOG_FILE}
export SOLOS_VERSION=`docker images | grep solace | awk '{print $3}'` &>> $${LOG_FILE}
echo "`date` INFO: Solace message broker image: $${SOLOS}" &>> $${LOG_FILE}
echo "`date` INFO:Create a Docker instance from Solace Docker image" &>> $${LOG_FILE}
# -------------------------------------------------------------
VMR_VERSION=`docker images | grep solace | awk '{print $2}'`
SOLACE_CLOUD_INIT="--env SERVICE_SSH_PORT=2222"
[ ! -z "$${USERNAME}" ] && SOLACE_CLOUD_INIT=$${SOLACE_CLOUD_INIT}" --env username_admin_globalaccesslevel=$${USERNAME}"
[ ! -z "$${PASSWORD}" ] && SOLACE_CLOUD_INIT=$${SOLACE_CLOUD_INIT}" --env username_admin_password=$${PASSWORD}"
for var_name in "$${cloud_init_vars[@]}"; do
  [ ! -z $${!var_name} ] && SOLACE_CLOUD_INIT=$${SOLACE_CLOUD_INIT}" --env $$var_name=$${!var_name}"
done
echo "SOLACE_CLOUD_INIT set to:" | tee -a $${LOG_FILE}
echo $${SOLACE_CLOUD_INIT} | tee -a $${LOG_FILE}

# Set container limits according to scaling tier requirements
if [ $${scaling} == "100" ]; then
  shm_size="2g"
  ulimit_nofile="2448:6592"
elif [ $${scaling} == "1000" ]; then
  shm_size="2g"
  ulimit_nofile="2448:10192"
elif [ $${scaling} == "10000" ]; then
  shm_size="2g"
  ulimit_nofile="2448:42192"
elif [ $${scaling} == "100000" ]; then
  shm_size="3.3g"
  ulimit_nofile="2448:222192"
elif [ $${scaling} == "200000" ]; then
  shm_size="3.3g"
  ulimit_nofile="2448:422192"
else
  shm_size="2g"
  ulimit_nofile="2448:6592"
fi

docker create \
   --uts=host \
   --shm-size $${shm_size} \
   --ulimit core=-1 \
   --ulimit memlock=-1 \
   --ulimit nofile=$${ulimit_nofile} \
   --publish 80:80 \
   --publish 443:443 \
   --publish 8080:8080 \
   --publish 9443:9443 \
   --publish 55555:55555 \
   --publish 55003:55003 \
   --publish 55443:55443 \
   --publish 8741:8741 \
   --publish 8300:8300 \
   --publish 8301:8301 \
   --publish 8302:8302 \
   --cap-add=IPC_LOCK \
   --cap-add=SYS_NICE \
   --net=host \
   --restart=always \
   -v jail:/usr/sw/jail \
   -v var:/usr/sw/var \
   -v internalSpool:/usr/sw/internalSpool \
   -v adbBackup:/usr/sw/adb \
   -v softAdb:/usr/sw/internalSpool/softAdb \
   $${SOLACE_CLOUD_INIT} \
   --name=solace $${SOLOS_VERSION} &>> $${LOG_FILE}

# save the create command for when we need to upgrade
echo "
docker create \
   --uts=host \
   --shm-size $${shm_size} \
   --ulimit core=-1 \
   --ulimit memlock=-1 \
   --ulimit nofile=$${ulimit_nofile} \
   --publish 80:80 \
   --publish 443:443 \
   --publish 8080:8080 \
   --publish 9443:9443 \
   --publish 55555:55555 \
   --publish 55003:55003 \
   --publish 55443:55443 \
   --publish 8741:8741 \
   --publish 8300:8300 \
   --publish 8301:8301 \
   --publish 8302:8302 \
   --cap-add=IPC_LOCK \
   --cap-add=SYS_NICE \
   --net=host \
   --restart=always \
   -v jail:/usr/sw/jail \
   -v var:/usr/sw/var \
   -v internalSpool:/usr/sw/internalSpool \
   -v adbBackup:/usr/sw/adb \
   -v softAdb:/usr/sw/internalSpool/softAdb \
   $${SOLACE_CLOUD_INIT} \
   --name=solace $${SOLOS_VERSION} &>> $${LOG_FILE}
" >> /root/solace_docker_create

docker ps -a &>> $${LOG_FILE}
echo "`date` INFO:Construct systemd for Solace PubSub+" &>> $${LOG_FILE}
# --------------------------------------
tee /etc/systemd/system/solace-docker.service <<-EOF
[Unit]
  Description=solace-docker
  Requires=docker.service
  After=docker.service
[Service]
  Restart=always
  ExecStart=/usr/bin/docker start -a solace
  ExecStop=/usr/bin/docker stop solace
[Install]
  WantedBy=default.target
EOF
echo "`date` INFO:/etc/systemd/system/solace-docker.service =/n `cat /etc/systemd/system/solace-docker.service`" | tee -a $${LOG_FILE}
echo "`date` INFO: Start the Solace Message Router" | tee -a $${LOG_FILE}
# --------------------------
systemctl daemon-reload &>> $${LOG_FILE}
systemctl enable solace-docker &>> $${LOG_FILE}
systemctl start solace-docker &>> $${LOG_FILE}

echo "done with script" | tee -a $${LOG_FILE}