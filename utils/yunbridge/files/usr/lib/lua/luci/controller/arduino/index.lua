--[[
This file is part of YunWebUI.

YunWebUI is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

As a special exception, you may use this file as part of a free software
library without restriction.  Specifically, if other files instantiate
templates or use macros or inline functions from this file, or you compile
this file and link it with other files to produce an executable, this
file does not by itself cause the resulting executable to be covered by
the GNU General Public License.  This exception does not however
invalidate any other reasons why the executable file might be covered by
the GNU General Public License.

Copyright 2013 Arduino LLC (http://www.arduino.cc/)
]]

module("luci.controller.arduino.index", package.seeall)

local function not_nil_or_empty(value)
  return value and value ~= ""
end

local function get_first(cursor, config, type, option)
  return cursor:get_first(config, type, option)
end

local function set_first(cursor, config, type, option, value)
  cursor:foreach(config, type, function(s)
    if s[".type"] == type then
      cursor:set(config, s[".name"], option, value)
    end
  end)
end


local function to_key_value(s)
  local parts = luci.util.split(s, ":")
  parts[1] = luci.util.trim(parts[1])
  parts[2] = luci.util.trim(parts[2])
  return parts[1], parts[2]
end

function http_error(code, text)
  luci.http.prepare_content("text/plain")
  luci.http.status(code)
  if text then
    luci.http.write(text)
  end
end

function index()
  function luci.dispatcher.authenticator.arduinoauth(validator, accs, default)
    require("luci.controller.arduino.index")

    local user = luci.http.formvalue("username")
    local pass = luci.http.formvalue("password")
    local basic_auth = luci.http.getenv("HTTP_AUTHORIZATION")

    if user and validator(user, pass) then
      return user
    end

    if basic_auth and basic_auth ~= "" then
      local decoded_basic_auth = nixio.bin.b64decode(string.sub(basic_auth, 7))
      user = string.sub(decoded_basic_auth, 0, string.find(decoded_basic_auth, ":") - 1)
      pass = string.sub(decoded_basic_auth, string.find(decoded_basic_auth, ":") + 1)
    end

    if user then
      if #pass ~= 64 and validator(user, pass) then
        return user
      elseif #pass == 64 then
        local uci = luci.model.uci.cursor()
        uci:load("yunbridge")
        local stored_encrypted_pass = uci:get_first("yunbridge", "bridge", "password")
        if pass == stored_encrypted_pass then
          return user
        end
      end
    end

    luci.http.header("WWW-Authenticate", "Basic realm=\"yunbridge\"")
    luci.http.status(401)

    return false
  end

  local function make_entry(path, target, title, order)
    local page = entry(path, target, title, order)
    page.leaf = true
    return page
  end

  -- web panel
  local webpanel = entry({ "webpanel" }, alias("webpanel", "go_to_homepage"), _("%s Web Panel") % luci.sys.hostname(), 10)
  webpanel.sysauth = "root"
  webpanel.sysauth_authenticator = "arduinoauth"

  make_entry({ "webpanel", "go_to_homepage" }, call("go_to_homepage"), nil)

  --api security level
  local uci = luci.model.uci.cursor()
  uci:load("yunbridge")
  local secure_rest_api = uci:get_first("yunbridge", "bridge", "secure_rest_api")
  local rest_api_sysauth = false
  if secure_rest_api == "true" then
    rest_api_sysauth = webpanel.sysauth
  end

  --storage api
  local data_api = node("data")
  data_api.sysauth = rest_api_sysauth
  data_api.sysauth_authenticator = webpanel.sysauth_authenticator
  make_entry({ "data", "get" }, call("storage_send_request"), nil).sysauth = rest_api_sysauth
  make_entry({ "data", "put" }, call("storage_send_request"), nil).sysauth = rest_api_sysauth
  make_entry({ "data", "delete" }, call("storage_send_request"), nil).sysauth = rest_api_sysauth
  local mailbox_api = node("mailbox")
  mailbox_api.sysauth = rest_api_sysauth
  mailbox_api.sysauth_authenticator = webpanel.sysauth_authenticator
  make_entry({ "mailbox" }, call("build_bridge_mailbox_request"), nil).sysauth = rest_api_sysauth

  --plain socket endpoint
  local plain_socket_endpoint = make_entry({ "arduino" }, call("board_plain_socket"), nil)
  plain_socket_endpoint.sysauth = rest_api_sysauth
  plain_socket_endpoint.sysauth_authenticator = webpanel.sysauth_authenticator
end

function go_to_homepage()
  luci.http.redirect("/index.html")
end

local function build_bridge_request(command, params)

  local bridge_request = {
    command = command
  }

  if command == "raw" then
    params = table.concat(params, "/")
    if not_nil_or_empty(params) then
      bridge_request["data"] = params
    end
    return bridge_request
  end

  if command == "get" then
    if not_nil_or_empty(params[1]) then
      bridge_request["key"] = params[1]
    end
    return bridge_request
  end

  if command == "put" and not_nil_or_empty(params[1]) and params[2] then
    bridge_request["key"] = params[1]
    bridge_request["value"] = params[2]
    return bridge_request
  end

  if command == "delete" and not_nil_or_empty(params[1]) then
    bridge_request["key"] = params[1]
    return bridge_request
  end

  return nil
end

local function extract_jsonp_param(query_string)
  if not not_nil_or_empty(query_string) then
    return nil
  end

  local qs_parts = string.split(query_string, "&")
  for idx, value in ipairs(qs_parts) do
    if string.find(value, "jsonp") == 1 or string.find(value, "callback") == 1 then
      return string.sub(value, string.find(value, "=") + 1)
    end
  end
end

local function parts_after(url_part)
  local url = luci.http.getenv("PATH_INFO")
  local url_after_part = string.find(url, "/", string.find(url, url_part) + 1)
  if not url_after_part then
    return {}
  end
  return luci.util.split(string.sub(url, url_after_part + 1), "/")
end

function storage_send_request()
  local method = luci.http.getenv("REQUEST_METHOD")
  local jsonp_callback = extract_jsonp_param(luci.http.getenv("QUERY_STRING"))
  local parts = parts_after("data")
  local command = parts[1]
  if not command or command == "" then
    luci.http.status(404)
    return
  end
  local params = {}
  for idx, param in ipairs(parts) do
    if idx > 1 and not_nil_or_empty(param) then
      table.insert(params, param)
    end
  end

  -- TODO check method?
  local bridge_request = build_bridge_request(command, params)
  if not bridge_request then
    luci.http.status(403)
    return
  end

  local uci = luci.model.uci.cursor()
  uci:load("yunbridge")
  local socket_timeout = uci:get_first("yunbridge", "bridge", "socket_timeout", 5)

  local sock, code, msg = nixio.connect("127.0.0.1", 5700)
  if not sock then
    code = code or ""
    msg = msg or ""
    http_error(500, "nil socket, " .. code .. " " .. msg)
    return
  end

  sock:setopt("socket", "sndtimeo", socket_timeout)
  sock:setopt("socket", "rcvtimeo", socket_timeout)
  sock:setopt("tcp", "nodelay", 1)

  local json = require("luci.json")

  sock:write(json.encode(bridge_request))
  sock:writeall("\n")

  local response_text = {}
  while true do
    local bytes = sock:recv(4096)
    if bytes and #bytes > 0 then
      table.insert(response_text, bytes)
    end

    local json_response = json.decode(table.concat(response_text))
    if json_response then
      sock:close()
      luci.http.status(200)
      if jsonp_callback then
        luci.http.prepare_content("application/javascript")
        luci.http.write(jsonp_callback)
        luci.http.write("(")
        luci.http.write_json(json_response)
        luci.http.write(");")
      else
        luci.http.prepare_content("application/json")
        luci.http.write(json.encode(json_response))
      end
      return
    end

    if not bytes or #response_text == 0 then
      sock:close()
      http_error(500, "Empty response")
      return
    end
  end

  sock:close()
end

function board_plain_socket()
  local function send_response(response_text, jsonp_callback)
    if not response_text then
      luci.http.status(500)
      return
    end

    local rows = luci.util.split(response_text, "\r\n")
    if #rows == 1 or string.find(rows[1], "Status") ~= 1 then
      luci.http.prepare_content("text/plain")
      luci.http.status(200)
      luci.http.write(response_text)
      return
    end

    local body_start_at_idx = -1
    local content_type = "text/plain"
    for idx, row in ipairs(rows) do
      if row == "" then
        body_start_at_idx = idx
        break
      end

      local key, value = to_key_value(row)
      if string.lower(key) == "status" then
        luci.http.status(tonumber(value))
      elseif string.lower(key) == "content-type" then
        content_type = value
      else
        luci.http.header(key, value)
      end
    end

    local response_body = table.concat(rows, "\r\n", body_start_at_idx + 1)
    if content_type == "application/json" and jsonp_callback then
      local json = require("luci.json")
      luci.http.prepare_content("application/javascript")
      luci.http.write(jsonp_callback)
      luci.http.write("(")
      luci.http.write_json(json.decode(response_body))
      luci.http.write(");")
    else
      luci.http.prepare_content(content_type)
      luci.http.write(response_body)
    end
  end

  local method = luci.http.getenv("REQUEST_METHOD")
  local jsonp_callback = extract_jsonp_param(luci.http.getenv("QUERY_STRING"))
  local parts = parts_after("arduino")
  local params = {}
  for idx, param in ipairs(parts) do
    if not_nil_or_empty(param) then
      table.insert(params, param)
    end
  end

  if #params == 0 then
    luci.http.status(404)
    return
  end

  params = table.concat(params, "/")

  local uci = luci.model.uci.cursor()
  uci:load("yunbridge")
  local socket_timeout = uci:get_first("yunbridge", "bridge", "socket_timeout", 5)

  local sock, code, msg = nixio.connect("127.0.0.1", 5555)
  if not sock then
    code = code or ""
    msg = msg or ""
    http_error(500, "Could not connect to YunServer " .. code .. " " .. msg)
    return
  end

  sock:setopt("socket", "sndtimeo", socket_timeout)
  sock:setopt("socket", "rcvtimeo", socket_timeout)
  sock:setopt("tcp", "nodelay", 1)

  sock:write(params)
  sock:writeall("\r\n")

  local response_text = sock:readall()
  sock:close()

  send_response(response_text, jsonp_callback)
end

function build_bridge_mailbox_request()
  local method = luci.http.getenv("REQUEST_METHOD")
  local jsonp_callback = extract_jsonp_param(luci.http.getenv("QUERY_STRING"))
  local parts = parts_after("mailbox")
  local params = {}
  for idx, param in ipairs(parts) do
    if not_nil_or_empty(param) then
      table.insert(params, param)
    end
  end

  if #params == 0 then
    luci.http.status(400)
    return
  end

  local bridge_request = build_bridge_request("raw", params)
  if not bridge_request then
    luci.http.status(403)
    return
  end

  local uci = luci.model.uci.cursor()
  uci:load("yunbridge")
  local socket_timeout = uci:get_first("yunbridge", "bridge", "socket_timeout", 5)

  local sock, code, msg = nixio.connect("127.0.0.1", 5700)
  if not sock then
    code = code or ""
    msg = msg or ""
    http_error(500, "nil socket, " .. code .. " " .. msg)
    return
  end

  sock:setopt("socket", "sndtimeo", socket_timeout)
  sock:setopt("socket", "rcvtimeo", socket_timeout)
  sock:setopt("tcp", "nodelay", 1)

  local json = require("luci.json")

  sock:write(json.encode(bridge_request))
  sock:writeall("\n")
  sock:close()

  luci.http.status(200)
end
