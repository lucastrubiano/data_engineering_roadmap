#!/bin/bash

# Script para guardar una copia de la imagen original de MinIO
# antes de que sea eliminada del registro

IMAGE_NAME="minio/minio:RELEASE.2025-07-23T15-54-02Z"
BACKUP_TAG="lucastrubiano/minio:original_RELEASE.2025-07-23T15-54-02Z"
BACKUP_FILE="minio_original_RELEASE.2025-07-23T15-54-02Z.tar"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Backup de imagen MinIO original"
echo "=========================================="
echo ""

# Verificar si la imagen existe localmente
if ! docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
    echo "⚠️  La imagen $IMAGE_NAME no existe localmente."
    echo "Descargando la imagen primero..."
    docker pull "$IMAGE_NAME"
    if [ $? -ne 0 ]; then
        echo "❌ Error al descargar la imagen. Abortando."
        exit 1
    fi
    echo "✅ Imagen descargada correctamente."
    echo ""
fi

echo "Opción 1: Guardar como archivo TAR (recomendado para backup local)"
echo "------------------------------------------------------------"
docker save -o "$SCRIPT_DIR/$BACKUP_FILE" "$IMAGE_NAME"
if [ $? -eq 0 ]; then
    echo "✅ Imagen guardada en: $SCRIPT_DIR/$BACKUP_FILE"
    echo "   Tamaño: $(du -h "$SCRIPT_DIR/$BACKUP_FILE" | cut -f1)"
    echo ""
    echo "Para cargar la imagen más tarde, ejecuta:"
    echo "   docker load -i $BACKUP_FILE"
    echo ""
else
    echo "❌ Error al guardar la imagen en archivo TAR"
fi

echo ""
echo "Opción 2: Etiquetar y subir a Docker Hub (opcional)"
echo "------------------------------------------------------------"
read -p "¿Deseas etiquetar y subir la imagen a Docker Hub? (s/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo "Etiquetando imagen..."
    docker tag "$IMAGE_NAME" "$BACKUP_TAG"
    if [ $? -eq 0 ]; then
        echo "✅ Imagen etiquetada como: $BACKUP_TAG"
        echo ""
        echo "Para subir la imagen a Docker Hub, ejecuta:"
        echo "   docker push $BACKUP_TAG"
        echo ""
        read -p "¿Deseas subir ahora? (s/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            docker push "$BACKUP_TAG"
            if [ $? -eq 0 ]; then
                echo "✅ Imagen subida a Docker Hub exitosamente"
            else
                echo "❌ Error al subir la imagen. Verifica que estés autenticado:"
                echo "   docker login"
            fi
        fi
    else
        echo "❌ Error al etiquetar la imagen"
    fi
fi

echo ""
echo "=========================================="
echo "✅ Proceso de backup completado"
echo "=========================================="

