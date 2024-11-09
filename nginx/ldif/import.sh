#!/bin/bash

# Wait for LDAP to be ready
sleep 5

# Try to import multiple times
for i in {1..5}; do
    echo "Attempting to import LDIF (attempt $i)"
    ldapadd -x -D "cn=admin,dc=example,dc=com" -w admin123 -f /ldif/bootstrap.ldif -H ldap://localhost:389
    if [ $? -eq 0 ]; then
        echo "LDIF import successful"
        exit 0
    fi
    sleep 5
done

echo "Failed to import LDIF after 5 attempts"
exit 1