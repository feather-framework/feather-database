#!/bin/sh

# Generate CA (Certificate Authority) private key
openssl genpkey -algorithm RSA -out ca.key

# Generate CA certificate (PEM format)
openssl req -new -x509 -key ca.key -out ca.pem -days 365 -subj "/CN=PostgreSQL-CA"

# Generate server private key
openssl genpkey -algorithm RSA -out server.key

# Create a CSR with correct CN (Common Name) & SAN (Subject Alternative Name)
openssl req -new -key server.key -out server.csr -subj "/CN=localhost"

# SAN for localhost, db, and 127.0.0.1
echo "subjectAltName=DNS:localhost,DNS:db,IP:127.0.0.1" > san.cnf

# Sign the server certificate with CA & SAN
openssl x509 -req -in server.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out server.pem -days 365 -extfile san.cnf
