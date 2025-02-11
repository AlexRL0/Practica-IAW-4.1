#!/bin/bash
set -x

# Deshabilitamos la paginación de la salida de los comandos de AWS CLI
export AWS_PAGER=""

# Variables de configuración
source .env

# Desasociar grupos de seguridad de las instancias EC2
for i in {1..2}; do
  INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=frontend-$i" --query "Reservations[].Instances[].InstanceId" --output text)
  if [ -n "$INSTANCE_ID" ]; then
    aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --groups ""
  fi
done

INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME_BACKEND" --query "Reservations[].Instances[].InstanceId" --output text)
if [ -n "$INSTANCE_ID" ]; then
  aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --groups ""
fi

INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME_BALANCEADOR" --query "Reservations[].Instances[].InstanceId" --output text)
if [ -n "$INSTANCE_ID" ]; then
  aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --groups ""
fi

INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME_NFS" --query "Reservations[].Instances[].InstanceId" --output text)
if [ -n "$INSTANCE_ID" ]; then
  aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --groups ""
fi

# Eliminar instancias EC2
for i in {1..2}; do
  INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=frontend-$i" --query "Reservations[].Instances[].InstanceId" --output text)
  if [ -n "$INSTANCE_ID" ];then
    aws ec2 terminate-instances --instance-ids $INSTANCE_ID
  fi
done

INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME_BACKEND" --query "Reservations[].Instances[].InstanceId" --output text)
if [ -n "$INSTANCE_ID" ];then
  aws ec2 terminate-instances --instance-ids $INSTANCE_ID
fi

INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME_BALANCEADOR" --query "Reservations[].Instances[].InstanceId" --output text)
if [ -n "$INSTANCE_ID" ];then
  aws ec2 terminate-instances --instance-ids $INSTANCE_ID
fi

INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME_NFS" --query "Reservations[].Instances[].InstanceId" --output text)
if [ -n "$INSTANCE_ID" ];then
  aws ec2 terminate-instances --instance-ids $INSTANCE_ID
fi

# Esperar a que todas las instancias se terminen
aws ec2 wait instance-terminated --instance-ids $(aws ec2 describe-instances --filters "Name=instance-state-name,Values=terminated" --query "Reservations[].Instances[].InstanceId" --output text)

# Eliminar grupos de seguridad
aws ec2 delete-security-group --group-name $SECURITY_GROUP_FRONTEND
aws ec2 delete-security-group --group-name $SECURITY_GROUP_BACKEND
aws ec2 delete-security-group --group-name $SECURITY_GROUP_BALANCEADOR
aws ec2 delete-security-group --group-name $SECURITY_GROUP_NFS
