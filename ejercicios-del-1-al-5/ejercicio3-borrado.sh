#!/bin/bash
set -x

# Deshabilitamos la paginación de la salida de los comandos de AWS CLI
export AWS_PAGER=""

# Variables de configuración
source .env

# Función para eliminar una instancia, liberar la IP elástica y eliminar grupos de seguridad
borrado() {
  local INSTANCE_NAME=$1
  local ALLOCATION_ID=$2
  local SECURITY_GROUP=$3

  # Obtenemos el ID de la instancia a partir de su nombre
  INSTANCE_ID=$(aws ec2 describe-instances \
                --filters "Name=tag:Name,Values=$INSTANCE_NAME" \
                          "Name=instance-state-name,Values=running" \
                --query "Reservations[*].Instances[*].InstanceId" \
                --output text)

  # Disociar la IP elástica de la instancia
  aws ec2 disassociate-address --instance-id $INSTANCE_ID

  # Liberar la IP elástica
  aws ec2 release-address --allocation-id $ALLOCATION_ID

  # Terminar la instancia EC2
  aws ec2 terminate-instances --instance-ids $INSTANCE_ID

  # Esperar a que la instancia se termine
  aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID

  # Eliminar el grupo de seguridad
  aws ec2 delete-security-group --group-name $SECURITY_GROUP
}

# Eliminar instancias frontend, liberar IPs elásticas y eliminar grupos de seguridad
for i in {1..2}; do
  borrado "frontend-$i" ${ELASTIC_IP_FRONTEND[i]} $SECURITY_GROUP_FRONTEND
done

# Eliminar instancia backend, liberar IP elástica y eliminar grupo de seguridad
borrado $INSTANCE_NAME_BACKEND $ELASTIC_IP_BACKEND $SECURITY_GROUP_BACKEND

# Eliminar instancia balanceador, liberar IP elástica y eliminar grupo de seguridad
borrado $INSTANCE_NAME_BALANCEADOR $ELASTIC_IP_BALANCEADOR $SECURITY_GROUP_BALANCEADOR

# Eliminar instancia NFS, liberar IP elástica y eliminar grupo de seguridad
borrado $INSTANCE_NAME_NFS $ELASTIC_IP_NFS $SECURITY_GROUP_NFS
