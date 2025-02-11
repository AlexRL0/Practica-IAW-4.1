#!/bin/bash
set -x

# Deshabilitamos la paginación de la salida de los comandos de AWS CLI
export AWS_PAGER=""

# Variables de configuración
source .env

# Eliminar instancias EC2 para el frontend
for i in {1..2}; do
  INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=frontend-$i" --query "Reservations[].Instances[].InstanceId" --output text)
  aws ec2 terminate-instances --instance-ids $INSTANCE_ID
done

# Eliminar instancia EC2 para el backend
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME_BACKEND" --query "Reservations[].Instances[].InstanceId" --output text)
aws ec2 terminate-instances --instance-ids $INSTANCE_ID

# Eliminar instancia EC2 para el balanceador de carga
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME_BALANCEADOR" --query "Reservations[].Instances[].InstanceId" --output text)
aws ec2 terminate-instances --instance-ids $INSTANCE_ID

# Eliminar instancia EC2 para el NFS
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME_NFS" --query "Reservations[].Instances[].InstanceId" --output text)
aws ec2 terminate-instances --instance-ids $INSTANCE_ID

# Esperar a que todas las instancias se terminen
aws ec2 wait instance-terminated --instance-ids $(aws ec2 describe-instances --filters "Name=instance-state-name,Values=terminated" --query "Reservations[].Instances[].InstanceId" --output text)

# Disociar grupos de seguridad de las interfaces de red
for SG in $SECURITY_GROUP_FRONTEND $SECURITY_GROUP_BACKEND $SECURITY_GROUP_BALANCEADOR $SECURITY_GROUP_NFS; do
  NETWORK_INTERFACES=$(aws ec2 describe-network-interfaces --filters "Name=group-name,Values=$SG" --query "NetworkInterfaces[].NetworkInterfaceId" --output text)
  for NI in $NETWORK_INTERFACES; do
    aws ec2 modify-network-interface-attribute --network-interface-id $NI --groups ""
  done
done

# Eliminar grupos de seguridad
aws ec2 delete-security-group --group-name $SECURITY_GROUP_FRONTEND
aws ec2 delete-security-group --group-name $SECURITY_GROUP_BACKEND
aws ec2 delete-security-group --group-name $SECURITY_GROUP_BALANCEADOR
aws ec2 delete-security-group --group-name $SECURITY_GROUP_NFS