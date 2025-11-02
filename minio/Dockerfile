FROM minio/minio:RELEASE.2025-07-23T15-54-02Z

# Labels matching original image
LABEL name=MinIO
LABEL vendor="MinIO by Trubi Data"

# Environment variables from original image
ENV MINIO_ACCESS_KEY_FILE=access_key \
    MINIO_SECRET_KEY_FILE=secret_key \
    MINIO_ROOT_USER_FILE=access_key \
    MINIO_ROOT_PASSWORD_FILE=secret_key

# Expose MinIO port (matching original - only 9000)
EXPOSE 9000

# Volume declaration (matching original)
VOLUME ["/data"]

# Entrypoint and command matching original image
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["minio"]

# Build and push to Docker Hub command
# docker build -t lucastrubiano/minio:minio_2025_07_23 ./minio && docker push lucastrubiano/minio:minio_2025_07_23