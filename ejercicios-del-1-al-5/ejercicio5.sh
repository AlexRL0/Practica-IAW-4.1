#!/bin/bash

# Deshabilitamos la paginación de la salida de los comandos de AWS CLI
export AWS_PAGER=""

# Obtener todas las instancias en ejecución
INSTANCES=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].[InstanceId,Tags[?Key=='Name'].Value|[0],PublicIpAddress]" --output text)

# Imprimir resultados
printf "%-20s %-30s %-20s\n" "ID de la Instancia" "Nombre" "Dirección IP Pública"
printf "%-20s %-30s %-20s\n" "------------------" "------------------------------" "------------------"

echo "$INSTANCES" | while read -r INSTANCE_ID INSTANCE_NAME PUBLIC_IP; do
    printf "%-20s %-30s %-20s\n" "$INSTANCE_ID" "$INSTANCE_NAME" "$PUBLIC_IP"
done