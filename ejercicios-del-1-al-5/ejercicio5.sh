#!/bin/bash

# Deshabilitamos la paginación de la salida de los comandos de AWS CLI
export AWS_PAGER=""

# Obtener todas las instancias en ejecución
INSTANCES=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].[InstanceId,Tags[?Key=='Name'].Value|[0],PublicIpAddress]" --output text)

# Imprimir resultados
echo -e "ID de la Instancia\t\tNombre\t\tDirección IP Pública"
echo -e "----------------------------------------------------------"
echo "$INSTANCES" | while read -r INSTANCE_ID INSTANCE_NAME PUBLIC_IP; do
    echo -e "$INSTANCE_ID\t$INSTANCE_NAME\t$PUBLIC_IP"
done