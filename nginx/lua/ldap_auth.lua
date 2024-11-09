local ldap = require "resty.ldap"

-- LDAP connection settings
local ldap_host = "openldap"
local ldap_port = 389
local ldap_base_dn = "dc=example,dc=com"

-- Get Authorization header
local auth_header = ngx.req.get_headers()["Authorization"]
if not auth_header then
    ngx.header["WWW-Authenticate"] = 'Basic realm="LDAP Authentication"'
    ngx.status = 401
    ngx.exit(401)
end

-- Decode base64 credentials
local encoded_creds = string.match(auth_header, "^Basic%s+(.+)$")
local decoded_creds = ngx.decode_base64(encoded_creds)
local username, password = string.match(decoded_creds, "^(.+):(.+)$")

if not username or not password then
    ngx.status = 401
    ngx.exit(401)
end

-- Create LDAP connection
local ldapconn, err = ldap:new()
if not ldapconn then
    ngx.log(ngx.ERR, "Failed to create LDAP instance: ", err)
    ngx.exit(500)
end

ldapconn:set_timeout(10000)  -- 10 seconds

-- Connect to LDAP server
local ok, err = ldapconn:connect(ldap_host, ldap_port)
if not ok then
    ngx.log(ngx.ERR, "Failed to connect to LDAP server: ", err)
    ngx.exit(500)
end

-- Create user DN
local user_dn = "uid=" .. username .. ",ou=Users," .. ldap_base_dn

-- Bind with user credentials
local ok, err = ldapconn:bind_request(user_dn, password)
if not ok then
    ngx.log(ngx.ERR, "Failed to bind: ", err)
    ngx.status = 401
    ngx.exit(401)
end

-- Close connection
ldapconn:unbind()
ldapconn:close()

-- Authentication successful
ngx.log(ngx.INFO, "Authentication successful for user: ", username)