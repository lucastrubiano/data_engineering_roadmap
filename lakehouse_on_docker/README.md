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

# 4. Verificar estado
docker-compose ps

# 5. Ver logs
docker-compose logs -f

# 6. Obtener token de Jupyter
docker-compose logs pyspark-jupyter | grep token
```

**Accesos rápidos:**
- Airflow: http://localhost:8084 (airflow/airflow)
- MinIO: http://localhost:9001 (minioadmin/minioadmin)
- Jupyter: http://localhost:8888 (token en logs)
- Trino: http://localhost:8083/ui
- Nessie: http://localhost:19120/api/v2/config

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

### 5. Verificar el estado de los servicios

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

### 6. Acceder a los servicios

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
- **URL**: http://localhost:8083/ui
- **Puerto SQL**: `8083` (para clientes SQL como DBeaver, etc.)

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

Trino permite consultar datos desde múltiples fuentes usando SQL estándar.

**Ejemplo de conexión:**
```sql
-- Conectar a Trino desde cualquier cliente SQL
-- Host: localhost
-- Port: 8083
-- Catalog: iceberg o nessie
-- Schema: default

SHOW CATALOGS;
USE iceberg.default;
SHOW TABLES;
```

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

