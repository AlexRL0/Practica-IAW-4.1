#!/bin/bash
set -x

# Deshabilitamos la paginación de la salida de los comandos de AWS CLI
export AWS_PAGER=""

# Variables de configuración
source .env

# Eliminar instancias frontend, liberar IPs elásticas y esperar a que estén terminadas
for i in 1 2; do
  INSTANCE_ID=$(aws ec2 describe-instances \
                --filters "Name=tag:Name,Values=${INSTANCE_NAME_FRONTEND}-$i" \
                          "Name=instance-state-name,Values=running" \
                --query "Reservations[*].Instances[*].InstanceId" \
                --output text)

  ELASTIC_IP_VAR="ELASTIC_IP_FRONTEND_$i"
  ELASTIC_IP=${!ELASTIC_IP_VAR}

  ALLOCATION_ID=$(aws ec2 describe-addresses \
                 --filters "Name=public-ip,Values=$ELASTIC_IP" \
                 --query 'Addresses[0].AllocationId' \
                 --output text)

  aws ec2 disassociate-address --allocation-id $ALLOCATION_ID
  aws ec2 release-address --allocation-id $ALLOCATION_ID
  aws ec2 terminate-instances --instance-ids $INSTANCE_ID
  aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID
done

# Eliminar instancia backend, liberar IP elástica y esperar a que esté terminada
INSTANCE_ID_BACKEND=$(aws ec2 describe-instances \
                      --filters "Name=tag:Name,Values=$INSTANCE_NAME_BACKEND" \
                                "Name=instance-state-name,Values=running" \
                      --query "Reservations[*].Instances[*].InstanceId" \
                      --output text)

ALLOCATION_ID_BACKEND=$(aws ec2 describe-addresses \
                     --filters "Name=public-ip,Values=$ELASTIC_IP_BACKEND" \
                     --query 'Addresses[0].AllocationId' \
                     --output text)

aws ec2 disassociate-address --allocation-id $ALLOCATION_ID_BACKEND
aws ec2 release-address --allocation-id $ALLOCATION_ID_BACKEND
aws ec2 terminate-instances --instance-ids $INSTANCE_ID_BACKEND
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID_BACKEND

# Eliminar instancia balanceador, liberar IP elástica y esperar a que esté terminada
INSTANCE_ID_BALANCEADOR=$(aws ec2 describe-instances \
                          --filters "Name=tag:Name,Values=$INSTANCE_NAME_BALANCEADOR" \
                                    "Name=instance-state-name,Values=running" \
                          --query "Reservations[*].Instances[*].InstanceId" \
                          --output text)

ALLOCATION_ID_BALANCEADOR=$(aws ec2 describe-addresses \
                         --filters "Name=public-ip,Values=$ELASTIC_IP_BALANCEADOR" \
                         --query 'Addresses[0].AllocationId' \
                         --output text)

aws ec2 disassociate-address --allocation-id $ALLOCATION_ID_BALANCEADOR
aws ec2 release-address --allocation-id $ALLOCATION_ID_BALANCEADOR
aws ec2 terminate-instances --instance-ids $INSTANCE_ID_BALANCEADOR
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID_BALANCEADOR

# Eliminar instancia NFS, liberar IP elástica y esperar a que esté terminada
INSTANCE_ID_NFS=$(aws ec2 describe-instances \
                  --filters "Name=tag:Name,Values=$INSTANCE_NAME_NFS" \
                            "Name=instance-state-name,Values=running" \
                  --query "Reservations[*].Instances[*].InstanceId" \
                  --output text)

ALLOCATION_ID_NFS=$(aws ec2 describe-addresses \
                 --filters "Name=public-ip,Values=$ELASTIC_IP_NFS" \
                 --query 'Addresses[0].AllocationId' \
                 --output text)

aws ec2 disassociate-address --allocation-id $ALLOCATION_ID_NFS
aws ec2 release-address --allocation-id $ALLOCATION_ID_NFS
aws ec2 terminate-instances --instance-ids $INSTANCE_ID_NFS
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID_NFS

# Eliminar grupos de seguridad
aws ec2 delete-security-group --group-name $SECURITY_GROUP_FRONTEND
aws ec2 delete-security-group --group-name $SECURITY_GROUP_BACKEND
aws ec2 delete-security-group --group-name $SECURITY_GROUP_BALANCEADOR
aws ec2 delete-security-group --group-name $SECURITY_GROUP_NFS