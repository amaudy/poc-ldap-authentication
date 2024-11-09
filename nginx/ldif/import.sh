#!/bin/bash
set -e

# Wait for LDAP to be ready
sleep 5

# Create base structure only if it doesn't exist
ldapadd -x -H ldap://localhost:389 \
    -D "cn=admin,dc=example,dc=com" \
    -w admin123 \
    -f /ldif/base.ldif 2>/dev/null || true

# Add users
ldapadd -x -H ldap://localhost:389 \
    -D "cn=admin,dc=example,dc=com" \
    -w admin123 \
    -f /ldif/users.ldif 2>/dev/null || true

# Add groups
ldapadd -x -H ldap://localhost:389 \
    -D "cn=admin,dc=example,dc=com" \
    -w admin123 \
    -f /ldif/groups.ldif 2>/dev/null || true

echo "LDIF import completed"