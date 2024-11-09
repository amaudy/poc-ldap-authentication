#!/bin/bash

# Start OpenLDAP directly (not in background)
/container/tool/run --copy-service &

# Wait for LDAP to be ready
for i in {1..30}; do
    # Test if LDAP is responding
    ldapsearch -x -H ldap://localhost:389 -D "cn=admin,dc=example,dc=com" -w admin123 -b "dc=example,dc=com" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "LDAP server is ready"
        break
    fi
    echo "Waiting for LDAP server... (attempt $i)"
    sleep 2
done

# Run the import script
/container/service/slapd/assets/config/bootstrap/import.sh

# Wait for any remaining processes
wait 