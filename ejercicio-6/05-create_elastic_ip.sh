#!/bin/bash
set -x

# Deshabilitamos la paginación de la salida de los comandos de AWS CLI
export AWS_PAGER=""

# Importamos las variables de entorno para obtener el nombre
# de la instancia a la que le vamos a asignar la IP elástica
source .env

# Crear IPs elásticas y guardar en el archivo .env
for i in {1..2}; do
  ELASTIC_IP_FRONTEND[i]=$(aws ec2 allocate-address --query 'PublicIp' --output text)
  echo "ELASTIC_IP_FRONTEND_$i=${ELASTIC_IP_FRONTEND[i]}" >> .env
done
ELASTIC_IP_BACKEND=$(aws ec2 allocate-address --query 'PublicIp' --output text)
echo "ELASTIC_IP_BACKEND=$ELASTIC_IP_BACKEND" >> .env
ELASTIC_IP_BALANCEADOR=$(aws ec2 allocate-address --query 'PublicIp' --output text)
echo "ELASTIC_IP_BALANCEADOR=$ELASTIC_IP_BALANCEADOR" >> .env
ELASTIC_IP_NFS=$(aws ec2 allocate-address --query 'PublicIp' --output text)
echo "ELASTIC_IP_NFS=$ELASTIC_IP_NFS" >> .env