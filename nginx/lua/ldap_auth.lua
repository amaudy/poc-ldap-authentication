-- LDAP connection settings
local ldap_host = "openldap"
local ldap_port = 389
local ldap_base_dn = "dc=example,dc=com"

-- Function to create LDAP bind request
local function create_bind_request(user_dn, password)
    -- Simple LDAP v3 Bind Request
    local bind_request = string.char(
        0x30, -- LDAP message tag
        0x00, -- length (will be calculated)
        0x02, 0x01, 0x01, -- message ID (1)
        0x60, -- bind request
        0x00, -- length (will be calculated)
        0x02, 0x01, 0x03, -- LDAP version 3
        string.len(user_dn)
    ) .. user_dn .. string.char(
        0x80, -- simple authentication
        string.len(password)
    ) .. password

    return bind_request
end

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

-- Create TCP connection using OpenResty's cosocket
local sock = ngx.socket.tcp()
sock:settimeout(5000) -- 5 seconds timeout

-- Connect to LDAP server
local ok, err = sock:connect(ldap_host, ldap_port)
if not ok then
    ngx.log(ngx.ERR, "Failed to connect to LDAP: ", err)
    ngx.exit(500)
end

-- Create user DN
local user_dn = "cn=" .. username .. "," .. ldap_base_dn

-- Send bind request
local bind_request = create_bind_request(user_dn, password)
local bytes, err = sock:send(bind_request)
if not bytes then
    ngx.log(ngx.ERR, "Failed to send bind request: ", err)
    sock:close()
    ngx.exit(500)
end

-- Read response
local response, err = sock:receive(2048)
if not response then
    ngx.log(ngx.ERR, "Failed to receive response: ", err)
    sock:close()
    ngx.exit(500)
end

-- Close connection
sock:close()

-- Check response code (0x0a for success)
if string.byte(response, 9) ~= 0x0a then
    ngx.log(ngx.ERR, "Authentication failed")
    ngx.status = 401
    ngx.exit(401)
end

-- Authentication successful
ngx.log(ngx.INFO, "Authentication successful for user: ", username)