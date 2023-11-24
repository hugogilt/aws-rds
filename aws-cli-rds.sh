#!/bin/bash

# Variables
DB_INSTANCE_IDENTIFIER="dataBaseHugo_Script"
DB_ENGINE="mysql"
DB_MASTER_USERNAME="root"
DB_MASTER_PASSWORD="root1234"
DB_NAME="dataBaseHugo_Script"
DB_INSTANCE_CLASS="db.t3.micro"
DB_ALLOCATED_STORAGE=20
DB_PORT=3306

# Crear un grupo de seguridad para permitir la conexión desde MySQL Workbench
aws ec2 create-security-group \
    --group-name mysql-workbench-sg \
    --description "Grupo de seguridad para MySQL Workbench a través de un script"

# Obtener el ID del grupo de seguridad que acabamos de crear
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --group-names mysql-workbench-sg --query "SecurityGroups[0].GroupId" --output text)

# Autorizar el tráfico en el puerto de la base de datos desde MySQL Workbench
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port $DB_PORT \
    --cidr 0.0.0.0/0

# Crear instancia de base de datos RDS
aws rds create-db-instance \
    --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
    --db-instance-class $DB_INSTANCE_CLASS \
    --engine $DB_ENGINE \
    --master-username $DB_MASTER_USERNAME \
    --master-user-password $DB_MASTER_PASSWORD \
    --allocated-storage $DB_ALLOCATED_STORAGE \
    --vpc-security-group-ids $SECURITY_GROUP_ID \
    --db-name $DB_NAME \
    --port $DB_PORT

# Esperar hasta que la instancia esté disponible
echo "Esperando a que la instancia de la base de datos esté disponible..."
aws rds wait db-instance-available --db-instance-identifier $DB_INSTANCE_IDENTIFIER
echo "La instancia de la base de datos está disponible."

# Obtener el endpoint de la instancia de la base de datos
echo "Obteniendo el endpoint de la instancia de la base de datos..."
DB_ENDPOINT=$(aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE_IDENTIFIER --query "DBInstances[0].Endpoint.Address" --output text)
echo "Endpoint obtenido con éxito"



echo "El grupo de seguridad para MySQL Workbench ha sido configurado y la instancia de la base de datos ha sido creada."
echo "Endpoint de la base de datos: $DB_ENDPOINT"
echo "ID del grupo de seguridad: $SECURITY_GROUP_ID"
