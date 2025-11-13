# Lakehouse Architecture - Docker Compose

Arquitectura de tipo Lakehouse completa con herramientas open source, configurada para desarrollo local en modo standalone/single node.

## 🏗️ Arquitectura

Este stack incluye las siguientes herramientas:

- **Airflow**: Orquestación de workflows y pipelines de datos
- **MinIO**: Almacenamiento S3-compatible (Data Lake)
- **Spark**: Procesamiento distribuido en modo standalone
- **Nessie**: Control de versiones para tablas (Git-like para datos)
- **Trino**: Motor de consultas SQL distribuido

## 📋 Requisitos Previos

- Docker Engine 20.10+
- Docker Compose 2.0+
- Al menos 8GB de RAM disponible
- Al menos 20GB de espacio en disco

## ⚡ Inicio Rápido (TL;DR)

```bash
# 1. Navegar al directorio
cd lakehouse_on_docker

# 2. Crear directorios (si no existen)
mkdir -p airflow/{dags,logs,config,plugins} trino/config/catalog pyspark

# 3. Iniciar todos los servicios
docker-compose up -d
# Nota: Los permisos de Jupyter se corrigen automáticamente al iniciar el contenedor

# 4. Crear bucket 'warehouse' en MinIO (REQUERIDO para Trino)
# Puedes elegir una de estas opciones:
#
# OPCIÓN A - Por línea de comandos:
docker exec minio mc alias set local http://localhost:9000 minioadmin minioadmin
docker exec minio mc mb local/warehouse
#
# OPCIÓN B - Por interfaz web:
# 1. Accede a http://localhost:9001 (usuario: minioadmin, password: minioadmin)
# 2. Ve a "Buckets" → "Create Bucket" → nombre: "warehouse" → "Create"
#
# Ver detalles completos en la sección 5 más abajo

# 5. Verificar estado
docker-compose ps

# 6. Verificar que el bucket se creó correctamente (opcional)
docker exec minio mc ls local/

# 7. Ver logs
docker-compose logs -f

# 8. Obtener token de Jupyter
docker-compose logs pyspark-jupyter | grep token
```

**Accesos rápidos:**
- Airflow: http://localhost:8084 (airflow/airflow)
- MinIO Console: http://localhost:9001 (minioadmin/minioadmin)
- Jupyter: http://localhost:8888 (token en logs)
- Trino Web UI: http://localhost:8083/ui
- Nessie API: http://localhost:19120/api/v2/config

**⚠️ Importante:** Trino requiere que el bucket `warehouse` exista en MinIO antes de poder crear tablas. Ver paso 4.

## 🚀 Inicio Rápido

### 1. Navegar al directorio del proyecto

```bash
cd lakehouse_on_docker
```

### 2. Configurar variables de entorno (opcional)

```bash
# Copiar template de variables de entorno
cp env.template .env

# Editar .env si necesitas cambiar configuraciones (puertos, passwords, etc.)
# Por defecto, los valores funcionan sin necesidad de editar
```

### 3. Crear directorios necesarios

```bash
# Crear estructura de directorios
mkdir -p airflow/{dags,logs,config,plugins}
mkdir -p trino/config/catalog
mkdir -p pyspark
```

**Nota:** Los archivos de configuración de Trino ya están creados en `trino/config/`. Si necesitas modificarlos, edita los archivos existentes.

**✅ Permisos de Jupyter - Automático:**

Los permisos de Jupyter se corrigen automáticamente al iniciar el contenedor. El `docker-compose.yml` está configurado para ejecutar `chown` en los directorios necesarios antes de iniciar Jupyter, por lo que **no necesitas ejecutar comandos manuales**.

### 4. Iniciar todos los servicios

```bash
# Iniciar todos los servicios en segundo plano
docker-compose up -d
```

Este comando iniciará todos los servicios:
- `airflow-standalone` - Airflow en modo standalone
- `minio` - Almacenamiento S3-compatible
- `pyspark-jupyter` - Spark + Jupyter Notebooks
- `nessie` - Control de versiones
- `trino-coordinator` - Motor de consultas SQL

### 5. Crear bucket en MinIO (Requerido para Trino)

**⚠️ IMPORTANTE:** Trino necesita que el bucket `warehouse` exista en MinIO antes de poder crear tablas Iceberg. Si intentas crear una tabla sin este bucket, obtendrás un error `ICEBERG_FILESYSTEM_ERROR`.

**Opción 1: Usando la línea de comandos (Recomendado)**

```bash
# Configurar alias de MinIO Client
docker exec minio mc alias set local http://localhost:9000 minioadmin minioadmin

# Crear el bucket 'warehouse'
docker exec minio mc mb local/warehouse

# Verificar que el bucket se creó
docker exec minio mc ls local/
```

**Opción 2: Usando la consola web de MinIO**

1. Accede a MinIO Console: http://localhost:9001
2. Usuario: `minioadmin`, Password: `minioadmin`
3. Haz clic en "Buckets" en el menú lateral
4. Haz clic en "Create Bucket"
5. Nombre del bucket: `warehouse`
6. Haz clic en "Create Bucket"

**Opción 3: Usando Python desde Airflow**

```python
from airflow.providers.amazon.aws.hooks.s3 import S3Hook

s3_hook = S3Hook(aws_conn_id='aws_default')
s3_hook.create_bucket(bucket_name='warehouse')
```

### 6. Verificar el estado de los servicios

```bash
# Ver estado de todos los contenedores
docker-compose ps

# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f airflow-standalone
docker-compose logs -f minio
docker-compose logs -f pyspark-jupyter
docker-compose logs -f nessie
docker-compose logs -f trino-coordinator
```

### 7. Acceder a los servicios

Espera 1-2 minutos para que todos los servicios inicien completamente, luego accede a:

#### Airflow
- **URL**: http://localhost:8084
- **Usuario**: `airflow`
- **Password**: `airflow`

#### MinIO Console
- **URL**: http://localhost:9001
- **Usuario**: `minioadmin`
- **Password**: `minioadmin`

#### Jupyter Lab (Spark + PySpark)
- **URL**: http://localhost:8888
- **Token**: Obtener con el siguiente comando:
```bash
docker-compose logs pyspark-jupyter | grep -i token
# O buscar en los logs la línea que contiene "http://127.0.0.1:8888/lab?token=..."
```

#### Nessie API
- **URL**: http://localhost:19120/api/v2/config
- Verificar estado: `curl http://localhost:19120/api/v2/config`

#### Trino
- **Web UI**: http://localhost:8083/ui
- **Puerto SQL**: `8083` (para clientes SQL como DBeaver, DataGrip, etc.)
- **Catálogo disponible**: `iceberg` (conectado a Nessie + MinIO)
- **Usuario**: No requiere autenticación en desarrollo

**Probar Trino desde línea de comandos:**
```bash
# Conectar al CLI de Trino
docker-compose exec trino-coordinator trino --server http://localhost:8080

# Ejecutar consultas SQL
SHOW CATALOGS;
SHOW SCHEMAS IN iceberg;

# Crear una tabla de prueba
CREATE SCHEMA IF NOT EXISTS iceberg.test_schema;
CREATE TABLE iceberg.test_schema.mi_tabla AS SELECT 1 as id, 'test' as nombre;
SELECT * FROM iceberg.test_schema.mi_tabla;
```

## 🛠️ Comandos Útiles

### Iniciar servicios

```bash
# Iniciar todos los servicios
docker-compose up -d

# Iniciar un servicio específico
docker-compose up -d airflow-standalone
docker-compose up -d minio
docker-compose up -d pyspark-jupyter
```

### Detener servicios

```bash
# Detener todos los servicios (mantiene contenedores)
docker-compose stop

# Detener y eliminar contenedores (mantiene volúmenes)
docker-compose down

# Detener, eliminar contenedores y volúmenes (⚠️ elimina datos)
docker-compose down -v
```

### Reiniciar servicios

```bash
# Reiniciar todos los servicios
docker-compose restart

# Reiniciar un servicio específico
docker-compose restart airflow-standalone
```

### Ver logs

```bash
# Logs de todos los servicios en tiempo real
docker-compose logs -f

# Logs de un servicio específico
docker-compose logs -f airflow-standalone

# Últimas 100 líneas de logs
docker-compose logs --tail=100 pyspark-jupyter
```

### Ejecutar comandos en contenedores

```bash
# Ejecutar comando en contenedor de Airflow
docker-compose exec airflow-standalone airflow version

# Acceder a shell interactivo
docker-compose exec pyspark-jupyter bash
docker-compose exec minio sh

# Ejecutar script Python en contenedor
docker-compose exec pyspark-jupyter python /home/jovyan/work/script.py

# Los notebooks se guardan en ./pyspark/ y se montan en /home/jovyan/work
```

### Obtener token de Jupyter

```bash
# Método 1: Buscar en logs
docker-compose logs pyspark-jupyter | grep -i token

# Método 2: Ejecutar comando en el contenedor
docker-compose exec pyspark-jupyter jupyter server list
```

## 🔧 Configuración de Servicios

### Airflow

Airflow está configurado en **modo standalone** (un solo contenedor que ejecuta webserver, scheduler y triggerer). Usa `SequentialExecutor` con SQLite para desarrollo local. Los DAGs deben colocarse en `airflow/dags/`.

**Conexiones pre-configuradas:**
- Conexión S3 (MinIO): `aws_default`
  - Endpoint: `http://minio:9000`
  - Access Key: `minioadmin`
  - Secret Key: `minioadmin`

### MinIO

MinIO actúa como almacenamiento S3-compatible. Puedes crear buckets desde la consola web o usando la API.

**Ejemplo de creación de bucket desde Python:**
```python
from airflow.providers.amazon.aws.hooks.s3 import S3Hook

s3_hook = S3Hook(aws_conn_id='aws_default')
s3_hook.create_bucket(bucket_name='warehouse')
```

### Spark + Jupyter Notebooks

Spark está integrado con Jupyter Notebooks en un solo contenedor usando la imagen `jupyter/pyspark-notebook`. Esto permite desarrollar y ejecutar código Spark directamente desde notebooks.

**Características:**
- Jupyter Lab habilitado
- PySpark pre-instalado y configurado
- Spark en modo local (standalone)
- Notebooks montados en `./pyspark`

**Acceso a Jupyter:**
1. Inicia el contenedor: `docker-compose up -d pyspark-jupyter`
2. Obtén el token: `docker-compose logs pyspark-jupyter | grep token`
3. Accede a: http://localhost:8888

**Ejemplo de uso en Jupyter Notebook:**
```python
from pyspark.sql import SparkSession

# Crear sesión de Spark
spark = SparkSession.builder \
    .appName("LakehouseExample") \
    .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
    .config("spark.hadoop.fs.s3a.access.key", "minioadmin") \
    .config("spark.hadoop.fs.s3a.secret.key", "minioadmin") \
    .config("spark.hadoop.fs.s3a.path.style.access", "true") \
    .getOrCreate()

# Leer datos desde MinIO
df = spark.read.parquet("s3a://warehouse/data/")
df.show()
```

### Nessie

Nessie proporciona control de versiones Git-like para tus tablas. Puedes crear branches, commits, y merges.

**Ejemplo de uso con PyIceberg:**
```python
from pyiceberg.catalog import load_catalog

catalog = load_catalog(
    name="nessie",
    uri="http://nessie:19120/api/v2",
    warehouse="s3://warehouse/",
    s3_endpoint="http://minio:9000"
)
```

### Trino

Trino permite consultar datos desde múltiples fuentes usando SQL estándar. Está configurado con el catálogo Iceberg que utiliza Nessie como metastore y MinIO como almacenamiento de datos.

**Configuración actual:**
- Catálogo: `iceberg`
- Metastore: Nessie (http://nessie:19120/api/v2)
- Almacenamiento: MinIO S3-compatible (bucket: `warehouse`)
- Formato de tablas: Apache Iceberg con versionado Git-like

**⚠️ Requisito importante:** Debes crear el bucket `warehouse` en MinIO antes de usar Trino. Ver sección [5. Crear bucket en MinIO](#5-crear-bucket-en-minio-requerido-para-trino).

**Ejemplo de conexión desde cliente SQL:**
```
Host: localhost
Port: 8083
Catalog: iceberg
Schema: (cualquier schema que crees)
Usuario: (cualquier nombre, no requiere autenticación)
```

**Ejemplo de uso con CLI de Trino:**
```bash
# Conectar al CLI de Trino
docker-compose exec trino-coordinator trino --server http://localhost:8080

# Ver catálogos disponibles
SHOW CATALOGS;

# Crear schema
CREATE SCHEMA IF NOT EXISTS iceberg.analytics;

# Crear tabla
CREATE TABLE iceberg.analytics.ventas (
    id INTEGER,
    producto VARCHAR,
    cantidad INTEGER,
    fecha DATE
) WITH (
    format = 'PARQUET',
    location = 's3a://warehouse/analytics/ventas'
);

# Insertar datos
INSERT INTO iceberg.analytics.ventas VALUES 
    (1, 'Laptop', 5, DATE '2024-01-15'),
    (2, 'Mouse', 10, DATE '2024-01-16');

# Consultar datos
SELECT * FROM iceberg.analytics.ventas;
```

**Conectar desde DBeaver/DataGrip:**
1. Agregar nueva conexión → Trino/Presto
2. Host: `localhost`, Puerto: `8083`
3. Database/Catalog: `iceberg`
4. Usuario: cualquier nombre (ej: `admin`)
5. Sin contraseña
6. Probar conexión y ejecutar: `SHOW SCHEMAS;`

**Archivos de datos en MinIO:**
Los datos de las tablas Iceberg se almacenan en formato Parquet en MinIO y puedes verlos en:
- MinIO Console: http://localhost:9001 → Bucket `warehouse`
- Los metadatos Iceberg (snapshots, manifiestos) también se guardan allí

## 📁 Estructura de Directorios

```
lakehouse_on_docker/
├── docker-compose.yml      # Configuración principal
├── env.template           # Template de variables de entorno
├── .env                    # Variables de entorno (no commiteado)
├── airflow/
│   ├── dags/              # DAGs de Airflow
│   ├── logs/              # Logs de Airflow
│   ├── config/            # Configuración de Airflow
│   └── plugins/           # Plugins de Airflow
├── pyspark/               # Jupyter Notebooks con PySpark
└── trino/
    └── config/            # Configuración de Trino
        ├── config.properties
        ├── jvm.config
        ├── node.properties
        └── catalog/
            ├── iceberg.properties
            └── nessie.properties
```


## 🔗 Integración entre Servicios

### Flujo de datos típico

1. **Ingesta**: Airflow orquesta la ingesta de datos a MinIO
2. **Procesamiento**: Spark procesa datos desde MinIO
3. **Versionado**: Nessie versiona las tablas procesadas
4. **Consulta**: Trino permite consultar datos versionados con SQL

### Ejemplo de pipeline completo

```python
# airflow/dags/example_pipeline.py
from airflow import DAG
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator
from airflow.providers.amazon.aws.operators.s3 import S3CreateBucketOperator
from datetime import datetime

with DAG('lakehouse_pipeline', start_date=datetime(2024, 1, 1)) as dag:
    create_bucket = S3CreateBucketOperator(
        task_id='create_bucket',
        bucket_name='warehouse',
        aws_conn_id='aws_default'
    )
    
    spark_job = SparkSubmitOperator(
        task_id='process_data',
        application='/opt/airflow/dags/spark_job.py',
        conf={
            'spark.master': 'spark://spark-master:7077',
            'spark.hadoop.fs.s3a.endpoint': 'http://minio:9000',
        }
    )
    
    create_bucket >> spark_job
```

## ⚠️ Notas Importantes

1. **Puertos**: Asegúrate de que los puertos configurados no estén en uso por otros servicios
2. **Recursos**: Este stack requiere recursos considerables. Ajusta la configuración según tu hardware
3. **Persistencia**: Los datos se almacenan en volúmenes de Docker. Usa `docker-compose down -v` con precaución
4. **Desarrollo**: Esta configuración es para desarrollo local. No usar en producción sin ajustes de seguridad
5. **Permisos de Jupyter**: Los permisos se corrigen automáticamente al iniciar el contenedor. Si encuentras problemas, simplemente reinicia el servicio con `docker-compose restart pyspark-jupyter`

## 🐛 Troubleshooting

### Trino: Error al crear tablas - "ICEBERG_FILESYSTEM_ERROR"

**Síntoma:**
```
Query failed: Failed checking new table's location: s3a://warehouse/...
```

**Causa:** El bucket `warehouse` no existe en MinIO.

**Solución:**
```bash
# Crear el bucket
docker exec minio mc alias set local http://localhost:9000 minioadmin minioadmin
docker exec minio mc mb local/warehouse

# Verificar
docker exec minio mc ls local/
```

Alternativamente, créalo desde la consola web de MinIO (http://localhost:9001).

### Trino: Contenedor reiniciando constantemente

**Síntoma:**
```bash
docker ps  # Muestra "Restarting (100)"
```

**Causa:** Error de configuración en los archivos de catálogo.

**Solución:**
```bash
# Ver logs para identificar el error
docker logs trino-coordinator --tail 100

# Verificar que la configuración sea correcta
cat trino/config/catalog/iceberg.properties
```

El archivo debe contener:
```properties
connector.name=iceberg
iceberg.catalog.type=nessie
iceberg.nessie-catalog.uri=http://nessie:19120/api/v2
iceberg.nessie-catalog.ref=main
iceberg.nessie-catalog.default-warehouse-dir=s3a://warehouse/

# S3/MinIO configuration for data storage
fs.native-s3.enabled=true
s3.endpoint=http://minio:9000
s3.path-style-access=true
s3.aws-access-key=minioadmin
s3.aws-secret-key=minioadmin
s3.region=us-east-1
```

### Airflow no inicia

```bash
# Verificar logs
docker-compose logs airflow-standalone

# Verificar permisos
ls -la airflow/

# Reiniciar servicio
docker-compose restart airflow-standalone
```

### MinIO no accesible

```bash
# Verificar que el servicio está corriendo
docker-compose ps minio

# Verificar logs
docker-compose logs minio

# Probar conexión desde contenedor
docker-compose exec airflow-standalone curl http://minio:9000/minio/health/live
```

### Jupyter no inicia o no accesible

#### Error de permisos: `PermissionError: [Errno 13] Permission denied: '/home/jovyan/.local/share'`

**✅ Solución automática integrada:** El `docker-compose.yml` está configurado para corregir automáticamente los permisos al iniciar el contenedor. Si aún encuentras este error:

**Solución: Reiniciar el contenedor**
```bash
# Reiniciar el servicio (los permisos se corregirán automáticamente)
docker-compose restart pyspark-jupyter
```

Si el problema persiste después de reiniciar:

**Solución alternativa: Eliminar y recrear el volumen**
```bash
# Detener el servicio
docker-compose stop pyspark-jupyter

# Eliminar el volumen (⚠️ esto eliminará datos guardados en .local)
docker volume rm lakehouse_on_docker_spark-jupyter-data

# Reiniciar el servicio (creará un nuevo volumen y corregirá permisos automáticamente)
docker-compose up -d pyspark-jupyter
```

#### Otros problemas comunes

```bash
# Verificar logs
docker-compose logs pyspark-jupyter

# Obtener token de acceso
docker-compose logs pyspark-jupyter | grep -i token

# Reiniciar servicio
docker-compose restart pyspark-jupyter

# Verificar que el contenedor está corriendo
docker-compose ps pyspark-jupyter

# Acceder al contenedor para debugging
docker-compose exec pyspark-jupyter bash
```

## 📚 Recursos Adicionales

- [Airflow Documentation](https://airflow.apache.org/docs/)
- [MinIO Documentation](https://min.io/docs/)
- [Spark Documentation](https://spark.apache.org/docs/)
- [Nessie Documentation](https://projectnessie.org/)
- [Trino Documentation](https://trino.io/docs/)

## 📝 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

