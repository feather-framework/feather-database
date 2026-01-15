# Use the official MariaDB image
FROM mariadb:12.1

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*


# Set the working directory
WORKDIR /etc/mysql/conf.d/

# Copy certificates
COPY docker/mariadb/certificates/server.pem docker/mariadb/certificates/server.key docker/mariadb/certificates/ca.pem ./

# Change ownership
RUN chown mysql:mysql /etc/mysql/conf.d/ca.pem /etc/mysql/conf.d/server.pem /etc/mysql/conf.d/server.key \
 && chmod 644 /etc/mysql/conf.d/ca.pem /etc/mysql/conf.d/server.pem \
 && chmod 600 /etc/mysql/conf.d/server.key

# Create SSL configuration file
COPY docker/mariadb/scripts/config-ssl.sh ./
RUN chmod +x ./config-ssl.sh
RUN ./config-ssl.sh
