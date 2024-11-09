from flask import Flask, request, Response
import ldap
import os
import base64

app = Flask(__name__)

LDAP_HOST = 'openldap'
LDAP_PORT = 389
LDAP_BASE_DN = 'dc=example,dc=com'

def authenticate_ldap(username, password):
    user_dn = f"uid={username},ou=Users,{LDAP_BASE_DN}"
    
    try:
        conn = ldap.initialize(f'ldap://{LDAP_HOST}:{LDAP_PORT}')
        conn.protocol_version = ldap.VERSION3
        conn.simple_bind_s(user_dn, password)
        conn.unbind_s()
        return True
    except ldap.INVALID_CREDENTIALS:
        return False
    except Exception as e:
        print(f"LDAP Error: {str(e)}")
        return False

@app.route('/auth')
def auth():
    auth_header = request.headers.get('Authorization')
    if not auth_header:
        return Response(
            'Authentication required',
            401,
            {'WWW-Authenticate': 'Basic realm="LDAP Authentication"'}
        )

    try:
        credentials = base64.b64decode(auth_header.split(' ')[1]).decode('utf-8')
        username, password = credentials.split(':')
        
        if authenticate_ldap(username, password):
            return Response('OK', 200, {'X-User': username})
        else:
            return Response('Invalid credentials', 401)
    except Exception as e:
        return Response(f'Authentication error: {str(e)}', 500)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)