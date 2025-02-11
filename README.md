# Practica-IAW-4.1- Ejercicios con AWS CLI

## Ejercicio 1. Crear un grupo de seguridad para las máquinas del Backend con el nombre backend-sg con  Añada las reglas Acceso SSH (puerto 22/TCP) desde cualquier dirección IP y Acceso al puerto 3306/TCP desde cualquier dirección IP al grupo de seguridad:

```bash
#!/bin/bash
set -x

# Deshabilitamos la paginación de la salida de los comandos de AWS CLI
export AWS_PAGER=""

# Importamos las variables de entorno
source .env

# Creamos el grupo de seguridad: backend-sg
aws ec2 create-security-group \
    --group-name $SECURITY_GROUP_BACKEND \
    --description "Reglas para el backend"

# Creamos una regla de accesso SSH
aws ec2 authorize-security-group-ingress \
    --group-name $SECURITY_GROUP_BACKEND \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

# Creamos una regla de accesso para MySQL
aws ec2 authorize-security-group-ingress \
    --group-name $SECURITY_GROUP_BACKEND \
    --protocol tcp \
    --port 3306 \
    --cidr 0.0.0.0/0
```

![Ejercicio1](imagenes/ejercicio1-4.1.png)

No se ve toda la ejecución del script porque es demasiado grande, pero para verificar que se ha hecho correctamente, voy a ir al ec2 en amazon para ver que a creado el grupo con las reglas correctamente.

![Ejercicio1-parte-2](imagenes/ejercicio1-parte2-4.1.png)

Como se puede ver, a creado el grupo con el nombre indicado y con las reglas correctamente.

## Ejercicio 2. Crea una instancia EC2 para la máquina del Backend con las siguientes características. Identificador de la AMI: ami-08e637cea2f053dfa. Número de instancias: 1, Tipo de instancia: t2.micro, Clave privada: vockey, Grupo de seguridad: backend-sg, Nombre de la instancia: backend

```bash

```