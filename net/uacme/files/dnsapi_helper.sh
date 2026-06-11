#!/bin/sh
#functions from acme.sh, GPLv3 applies
#utility functions acme.sh provieded for DNS API(and itself), 
#some implementations dffer because uacme/acme.sh difference.

# color functions are ignored because it didn't sent to interactive shell
__green() {
  printf -- "%b" "$1"
}

__red() {
  printf -- "%b" "$1"
}

_usage() {
  __red "$@" >&2
  printf "\n" >&2
}

_sleep() {
    if [ -n "$1" ]; then
        sleep "$1"
    fi
}

_log() {
  prio="$1"
	shift
	if [ "$prio" != debug ] || [ "$debug" = 1 ]; then
		logger -t "$LOG_TAG" -s -p "daemon.$prio" -- "$@"
	fi
}
_err() {
    _log err $@
}
_info() {
    _log info $@
}
_debug() {
  if [ $UACME_VERBOSE -ge 1 ]; then
    _log debug $@
  fi
}
_debug2() {
  if [ $UACME_VERBOSE -ge 2 ]; then
    _log debug $@
  fi
}
_debug3() {
  if [ $UACME_VERBOSE -ge 3 ]; then
    _log debug $@
  fi
}

__USE_TR_TAG=""
if [ "$(echo "abc" | LANG=C tr a-z A-Z 2>/dev/null)" != "ABC" ]; then
  __USE_TR_TAG="1"
fi
export __USE_TR_TAG

_upper_case() {
  if [ "$__USE_TR_TAG" ]; then
    LANG=C tr '[:lower:]' '[:upper:]'
  else
    # shellcheck disable=SC2018,SC2019
    LANG=C tr '[a-z]' '[A-Z]'
  fi
}

_lower_case() {
  if [ "$__USE_TR_TAG" ]; then
    LANG=C tr '[:upper:]' '[:lower:]'
  else
    # shellcheck disable=SC2018,SC2019
    LANG=C tr '[A-Z]' '[a-z]'
  fi
}

_startswith() {
  _str="$1"
  _sub="$2"
  echo "$_str" | grep -- "^$_sub" >/dev/null 2>&1
}

_endswith() {
  _str="$1"
  _sub="$2"
  echo "$_str" | grep -- "$_sub\$" >/dev/null 2>&1
}

_contains() {
  _str="$1"
  _sub="$2"
  echo "$_str" | grep -- "$_sub" >/dev/null 2>&1
}

_hasfield() {
  _str="$1"
  _field="$2"
  _sep="$3"
  if [ -z "$_field" ]; then
    _usage "Usage: str field  [sep]"
    return 1
  fi

  if [ -z "$_sep" ]; then
    _sep=","
  fi

  for f in $(echo "$_str" | tr "$_sep" ' '); do
    if [ "$f" = "$_field" ]; then
      _debug2 "'$_str' contains '$_field'"
      return 0 #contains ok
    fi
  done
  _debug2 "'$_str' does not contain '$_field'"
  return 1 #not contains
}

# str index [sep]
_getfield() {
  _str="$1"
  _findex="$2"
  _sep="$3"

  if [ -z "$_findex" ]; then
    _usage "Usage: str field  [sep]"
    return 1
  fi

  if [ -z "$_sep" ]; then
    _sep=","
  fi

  _ffi="$_findex"
  while [ "$_ffi" -gt "0" ]; do
    _fv="$(echo "$_str" | cut -d "$_sep" -f "$_ffi")"
    if [ "$_fv" ]; then
      printf -- "%s" "$_fv"
      return 0
    fi
    _ffi="$(_math "$_ffi" - 1)"
  done

  printf -- "%s" "$_str"

}

_exists() {
  cmd="$1"
  if [ -z "$cmd" ]; then
    _usage "Usage: _exists cmd"
    return 1
  fi

  if eval type type >/dev/null 2>&1; then
    eval type "$cmd" >/dev/null 2>&1
  elif command >/dev/null 2>&1; then
    command -v "$cmd" >/dev/null 2>&1
  else
    which "$cmd" >/dev/null 2>&1
  fi
  ret="$?"
  _debug3 "$cmd exists=$ret"
  return $ret
}

if [ "$(echo abc | egrep -o b 2>/dev/null)" = "b" ]; then
  __USE_EGREP=1
else
  __USE_EGREP=""
fi

_egrep_o() {
  if [ "$__USE_EGREP" ]; then
    egrep -o -- "$1" 2>/dev/null
  else
    sed -n 's/.*\('"$1"'\).*/\1/p'
  fi
}

#options file
_sed_i() {
  options="$1"
  filename="$2"
  sed -i "$options" "$filename"
}

_math() {
  _m_opts="$@"
  printf "%s" "$(($_m_opts))"
}

#stdin  output hexstr splited by one space
#input:"abc"
#output: " 61 62 63"
_hex_dump() {
    hexdump -v -e '/1 ""' -e '/1 " %02x" ""'
}

#url encode, no-preserved chars : see same named function in acme.sh
#_url_encode [upper-hex]  the encoded hex will be upper-case if the argument upper-hex is followed
#stdin stdout
_url_encode() {
  _upper_hex=$1
  _hex_str=$(_hex_dump)
  _debug3 "_url_encode"
  _debug3 "_hex_str" "$_hex_str"
  for _hex_code in $_hex_str; do
    #upper case
    case "${_hex_code}" in
    "41")
      printf "%s" "A"
      ;;
    "42")
      printf "%s" "B"
      ;;
    "43")
      printf "%s" "C"
      ;;
    "44")
      printf "%s" "D"
      ;;
    "45")
      printf "%s" "E"
      ;;
    "46")
      printf "%s" "F"
      ;;
    "47")
      printf "%s" "G"
      ;;
    "48")
      printf "%s" "H"
      ;;
    "49")
      printf "%s" "I"
      ;;
    "4a")
      printf "%s" "J"
      ;;
    "4b")
      printf "%s" "K"
      ;;
    "4c")
      printf "%s" "L"
      ;;
    "4d")
      printf "%s" "M"
      ;;
    "4e")
      printf "%s" "N"
      ;;
    "4f")
      printf "%s" "O"
      ;;
    "50")
      printf "%s" "P"
      ;;
    "51")
      printf "%s" "Q"
      ;;
    "52")
      printf "%s" "R"
      ;;
    "53")
      printf "%s" "S"
      ;;
    "54")
      printf "%s" "T"
      ;;
    "55")
      printf "%s" "U"
      ;;
    "56")
      printf "%s" "V"
      ;;
    "57")
      printf "%s" "W"
      ;;
    "58")
      printf "%s" "X"
      ;;
    "59")
      printf "%s" "Y"
      ;;
    "5a")
      printf "%s" "Z"
      ;;

      #lower case
    "61")
      printf "%s" "a"
      ;;
    "62")
      printf "%s" "b"
      ;;
    "63")
      printf "%s" "c"
      ;;
    "64")
      printf "%s" "d"
      ;;
    "65")
      printf "%s" "e"
      ;;
    "66")
      printf "%s" "f"
      ;;
    "67")
      printf "%s" "g"
      ;;
    "68")
      printf "%s" "h"
      ;;
    "69")
      printf "%s" "i"
      ;;
    "6a")
      printf "%s" "j"
      ;;
    "6b")
      printf "%s" "k"
      ;;
    "6c")
      printf "%s" "l"
      ;;
    "6d")
      printf "%s" "m"
      ;;
    "6e")
      printf "%s" "n"
      ;;
    "6f")
      printf "%s" "o"
      ;;
    "70")
      printf "%s" "p"
      ;;
    "71")
      printf "%s" "q"
      ;;
    "72")
      printf "%s" "r"
      ;;
    "73")
      printf "%s" "s"
      ;;
    "74")
      printf "%s" "t"
      ;;
    "75")
      printf "%s" "u"
      ;;
    "76")
      printf "%s" "v"
      ;;
    "77")
      printf "%s" "w"
      ;;
    "78")
      printf "%s" "x"
      ;;
    "79")
      printf "%s" "y"
      ;;
    "7a")
      printf "%s" "z"
      ;;
      #numbers
    "30")
      printf "%s" "0"
      ;;
    "31")
      printf "%s" "1"
      ;;
    "32")
      printf "%s" "2"
      ;;
    "33")
      printf "%s" "3"
      ;;
    "34")
      printf "%s" "4"
      ;;
    "35")
      printf "%s" "5"
      ;;
    "36")
      printf "%s" "6"
      ;;
    "37")
      printf "%s" "7"
      ;;
    "38")
      printf "%s" "8"
      ;;
    "39")
      printf "%s" "9"
      ;;
    "2d")
      printf "%s" "-"
      ;;
    "5f")
      printf "%s" "_"
      ;;
    "2e")
      printf "%s" "."
      ;;
    "7e")
      printf "%s" "~"
      ;;
    #other hex
    *)
      if [ "$_upper_hex" = "upper-hex" ]; then
        _hex_code=$(printf "%s" "$_hex_code" | _upper_case)
      fi
      printf '%%%s' "$_hex_code"
      ;;
    esac
  done
}

#Usage: multiline
_base64() {
  [ "" ] #urgly
  if _exists ucode; then
  # I hope throw single line into multiline doesn't break any code
    ucode -p "b64enc(\"$(cat -)\");"
  else
    if [ "$1" ]; then
      _debug3 "base64 multiline:'$1'"
      ${ACME_OPENSSL_BIN:-openssl} base64 -e
    else
      _debug3 "base64 single line."
      ${ACME_OPENSSL_BIN:-openssl} base64 -e | tr -d '\r\n'
    fi
  fi
}

#Usage: multiline
_dbase64() {
  if _exists ucode; then
    ucode -p "b64dec(\"$(cat -)\");"
  else
    if [ "$1" ]; then
      ${ACME_OPENSSL_BIN:-openssl} base64 -d
    else
      ${ACME_OPENSSL_BIN:-openssl} base64 -d -A
    fi
  fi
}

#Usage: hashalg  [outputhex]
#Output Base64-encoded digest
#currnetly only hex option is supported
_digest() {
  alg="$1"
  if [ -z "$alg" ]; then
    _usage "Usage: _digest hashalg"
    return 1
  fi

  outputhex="$2"
  if _exists ${ACME_OPENSSL_BIN:-openssl}; then
    if [ "$alg" = "sha256" ] || [ "$alg" = "sha1" ] || [ "$alg" = "md5" ]; then
      if [ "$outputhex" ]; then
        ${ACME_OPENSSL_BIN:-openssl} dgst -"$alg" -hex | cut -d = -f 2 | tr -d ' '
      else
        ${ACME_OPENSSL_BIN:-openssl} dgst -"$alg" -binary | _base64
      fi
    else
      _err "$alg is not supported yet"
      return 1
    fi
    return 0
  else
    if [ "$outputhex" ]; then
      case "$alg" in
      "md5")
        md5sum | cut -d ' ' -f 1
        return 0
      ;;
      "sha256")
        sha256sum | cut ' ' -f 1
        return 0
      ;;
      *)
        _err "$alg is not supported yet"
        return 1
      ;;
      esac
    else
      _err "binary mode not supported without Openssl"
    fi
  fi
}

#Usage: hashalg  secret_hex  [outputhex]
#Output binary hmac
_hmac() {
  alg="$1"
  secret_hex="$2"
  outputhex="$3"

  if [ -z "$secret_hex" ]; then
    _usage "Usage: _hmac hashalg secret [outputhex]"
    return 1
  fi

  if [ "$alg" = "sha256" ] || [ "$alg" = "sha1" ]; then
    if [ "$outputhex" ]; then
      (${ACME_OPENSSL_BIN:-openssl} dgst -"$alg" -mac HMAC -macopt "hexkey:$secret_hex" 2>/dev/null || ${ACME_OPENSSL_BIN:-openssl} dgst -"$alg" -hmac "$(printf "%s" "$secret_hex" | _h2b)") | cut -d = -f 2 | tr -d ' '
    else
      ${ACME_OPENSSL_BIN:-openssl} dgst -"$alg" -mac HMAC -macopt "hexkey:$secret_hex" -binary 2>/dev/null || ${ACME_OPENSSL_BIN:-openssl} dgst -"$alg" -hmac "$(printf "%s" "$secret_hex" | _h2b)" -binary
    fi
  else
    _err "$alg is not supported yet"
    return 1
  fi

}

#keyfile
_isRSA() {
  keyfile=$1
  if grep "BEGIN RSA PRIVATE KEY" "$keyfile" >/dev/null 2>&1 || ${ACME_OPENSSL_BIN:-openssl} rsa -in "$keyfile" -noout -text 2>&1 | grep "^publicExponent:" 2>&1 >/dev/null; then
    return 0
  fi
  return 1
}

#keyfile
_isEcc() {
  keyfile=$1
  if grep "BEGIN EC PRIVATE KEY" "$keyfile" >/dev/null 2>&1 || ${ACME_OPENSSL_BIN:-openssl} ec -in "$keyfile" -noout -text 2>/dev/null | grep "^NIST CURVE:" 2>&1 >/dev/null; then
    return 0
  fi
  return 1
}

#Usage: keyfile hashalg
#Output: Base64-encoded signature value
_sign() {
  keyfile="$1"
  alg="$2"
  if [ -z "$alg" ]; then
    _usage "Usage: _sign keyfile hashalg"
    return 1
  fi

  _sign_openssl="${ACME_OPENSSL_BIN:-openssl} dgst -sign $keyfile "

  if _isRSA "$keyfile" >/dev/null 2>&1; then
    $_sign_openssl -$alg | _base64
  elif _isEcc "$keyfile" >/dev/null 2>&1; then
    if ! _signedECText="$($_sign_openssl -sha$__ECC_KEY_LEN | ${ACME_OPENSSL_BIN:-openssl} asn1parse -inform DER)"; then
      _err "Sign failed: $_sign_openssl"
      _err "Key file: $keyfile"
      _err "Key content: $(wc -l <"$keyfile") lines"
      return 1
    fi
    _debug3 "_signedECText" "$_signedECText"
    _ec_r="$(echo "$_signedECText" | _head_n 2 | _tail_n 1 | cut -d : -f 4 | tr -d "\r\n")"
    _ec_s="$(echo "$_signedECText" | _head_n 3 | _tail_n 1 | cut -d : -f 4 | tr -d "\r\n")"
    if [ "$__ECC_KEY_LEN" -eq "256" ]; then
      while [ "${#_ec_r}" -lt "64" ]; do
        _ec_r="0${_ec_r}"
      done
      while [ "${#_ec_s}" -lt "64" ]; do
        _ec_s="0${_ec_s}"
      done
    fi
    if [ "$__ECC_KEY_LEN" -eq "384" ]; then
      while [ "${#_ec_r}" -lt "96" ]; do
        _ec_r="0${_ec_r}"
      done
      while [ "${#_ec_s}" -lt "96" ]; do
        _ec_s="0${_ec_s}"
      done
    fi
    if [ "$__ECC_KEY_LEN" -eq "512" ]; then
      while [ "${#_ec_r}" -lt "132" ]; do
        _ec_r="0${_ec_r}"
      done
      while [ "${#_ec_s}" -lt "132" ]; do
        _ec_s="0${_ec_s}"
      done
    fi
    _debug3 "_ec_r" "$_ec_r"
    _debug3 "_ec_s" "$_ec_s"
    printf "%s" "$_ec_r$_ec_s" | _h2b | _base64
  else
    _err "Unknown key file format."
    return 1
  fi

}

_utc_date() {
  date -u "+%Y-%m-%d %H:%M:%S"
}

_time() {
  date -u "+%s"
}

_mktemp() {
  if _exists mktemp; then
    if mktemp 2>/dev/null; then
      return 0
    elif _contains "$(mktemp 2>&1)" "-t prefix" && mktemp -t "$PROJECT_NAME" 2>/dev/null; then
      #for Mac osx
      return 0
    fi
  fi
  if [ -d "/tmp" ]; then
    echo "/tmp/${PROJECT_NAME}wefADf24sf.$(_time).tmp"
    return 0
  elif [ "$LE_TEMP_DIR" ] && mkdir -p "$LE_TEMP_DIR"; then
    echo "/$LE_TEMP_DIR/wefADf24sf.$(_time).tmp"
    return 0
  fi
  _err "Cannot create temp file."
}

#clear all the https envs to cause _inithttp() to run next time.
_resethttp() {
  __HTTP_INITIALIZED=""
  _ACME_CURL=""
  _ACME_WGET=""
  ACME_HTTP_NO_REDIRECTS=""
}

_inithttp() {

  if [ -z "$HTTP_HEADER" ] || ! touch "$HTTP_HEADER"; then
    HTTP_HEADER="$(_mktemp)"
    _debug2 HTTP_HEADER "$HTTP_HEADER"
  fi

  if [ "$__HTTP_INITIALIZED" ]; then
    if [ "$_ACME_CURL$_ACME_WGET" ]; then
      _debug2 "Http already initialized."
      return 0
    fi
  fi

  if [ -z "$_ACME_CURL" ] && _exists "curl"; then
    _ACME_CURL="curl --silent --dump-header $HTTP_HEADER "
    if [ -z "$ACME_HTTP_NO_REDIRECTS" ]; then
      _ACME_CURL="$_ACME_CURL -L "
    fi
    if [ "$DEBUG" ] && [ "$DEBUG" -ge 2 ]; then
      _CURL_DUMP="$(_mktemp)"
      _ACME_CURL="$_ACME_CURL --trace-ascii $_CURL_DUMP "
    fi

    if [ "$CA_PATH" ]; then
      _ACME_CURL="$_ACME_CURL --capath $CA_PATH "
    elif [ "$CA_BUNDLE" ]; then
      _ACME_CURL="$_ACME_CURL --cacert $CA_BUNDLE "
    fi

    if _contains "$(curl --help 2>&1)" "--globoff" || _contains "$(curl --help curl 2>&1)" "--globoff"; then
      _ACME_CURL="$_ACME_CURL -g "
    fi

    #don't use --fail-with-body
    ##from curl 7.76: return fail on HTTP errors but keep the body
    #if _contains "$(curl --help http 2>&1)" "--fail-with-body"; then
    #  _ACME_CURL="$_ACME_CURL --fail-with-body "
    #fi
  fi

  if [ -z "$_ACME_WGET" ] && _exists "wget"; then
    _ACME_WGET="wget -q"
    if [ "$ACME_HTTP_NO_REDIRECTS" ]; then
      _ACME_WGET="$_ACME_WGET --max-redirect 0 "
    fi
    if [ "$DEBUG" ] && [ "$DEBUG" -ge "2" ]; then
      if [ "$_ACME_WGET" ] && _contains "$($_ACME_WGET --help 2>&1)" "--debug"; then
        _ACME_WGET="$_ACME_WGET -d "
      fi
    fi
    if [ "$CA_PATH" ]; then
      _ACME_WGET="$_ACME_WGET --ca-directory=$CA_PATH "
    elif [ "$CA_BUNDLE" ]; then
      _ACME_WGET="$_ACME_WGET --ca-certificate=$CA_BUNDLE "
    fi

    #from wget 1.14: do not skip body on 404 error
    if _contains "$(wget --help 2>&1)" "--content-on-error"; then
      _ACME_WGET="$_ACME_WGET --content-on-error "
    fi
  fi

  __HTTP_INITIALIZED=1

}

# body  url [needbase64] [POST|PUT|DELETE] [ContentType]
_post() {
  body="$1"
  _post_url="$2"
  needbase64="$3"
  httpmethod="$4"
  _postContentType="$5"

  if [ -z "$httpmethod" ]; then
    httpmethod="POST"
  fi
  _debug $httpmethod
  _debug "_post_url" "$_post_url"
  _debug2 "body" "$body"
  _debug2 "_postContentType" "$_postContentType"

  _inithttp

  if [ "$_ACME_CURL" ] && [ "${ACME_USE_WGET:-0}" = "0" ]; then
    _CURL="$_ACME_CURL"
    if [ "$HTTPS_INSECURE" ]; then
      _CURL="$_CURL --insecure  "
    fi
    if [ "$httpmethod" = "HEAD" ]; then
      _CURL="$_CURL -I  "
    fi
    _debug "_CURL" "$_CURL"
    if [ "$needbase64" ]; then
      if [ "$body" ]; then
        if [ "$_postContentType" ]; then
          response="$($_CURL --user-agent "$USER_AGENT" -X $httpmethod -H "Content-Type: $_postContentType" -H "$_H1" -H "$_H2" -H "$_H3" -H "$_H4" -H "$_H5" --data "$body" "$_post_url" | _base64)"
        else
          response="$($_CURL --user-agent "$USER_AGENT" -X $httpmethod -H "$_H1" -H "$_H2" -H "$_H3" -H "$_H4" -H "$_H5" --data "$body" "$_post_url" | _base64)"
        fi
      else
        if [ "$_postContentType" ]; then
          response="$($_CURL --user-agent "$USER_AGENT" -X $httpmethod -H "Content-Type: $_postContentType" -H "$_H1" -H "$_H2" -H "$_H3" -H "$_H4" -H "$_H5" "$_post_url" | _base64)"
        else
          response="$($_CURL --user-agent "$USER_AGENT" -X $httpmethod -H "$_H1" -H "$_H2" -H "$_H3" -H "$_H4" -H "$_H5" "$_post_url" | _base64)"
        fi
      fi
    else
      if [ "$body" ]; then
        if [ "$_postContentType" ]; then
          response="$($_CURL --user-agent "$USER_AGENT" -X $httpmethod -H "Content-Type: $_postContentType" -H "$_H1" -H "$_H2" -H "$_H3" -H "$_H4" -H "$_H5" --data "$body" "$_post_url")"
        else
          response="$($_CURL --user-agent "$USER_AGENT" -X $httpmethod -H "$_H1" -H "$_H2" -H "$_H3" -H "$_H4" -H "$_H5" --data "$body" "$_post_url")"
        fi
      else
        if [ "$_postContentType" ]; then
          response="$($_CURL --user-agent "$USER_AGENT" -X $httpmethod -H "Content-Type: $_postContentType" -H "$_H1" -H "$_H2" -H "$_H3" -H "$_H4" -H "$_H5" "$_post_url")"
        else
          response="$($_CURL --user-agent "$USER_AGENT" -X $httpmethod -H "$_H1" -H "$_H2" -H "$_H3" -H "$_H4" -H "$_H5" "$_post_url")"
        fi
      fi
    fi
    _ret="$?"
    if [ "$_ret" != "0" ]; then
      _err "Please refer to https://curl.haxx.se/libcurl/c/libcurl-errors.html for error code: $_ret"
      if [ "$DEBUG" ] && [ "$DEBUG" -ge "2" ]; then
        _err "Here is the curl dump log:"
        _err "$(cat "$_CURL_DUMP")"
      fi
    fi
  elif [ "$_ACME_WGET" ]; then
    _WGET="$_ACME_WGET"
    if [ "$HTTPS_INSECURE" ]; then
      _WGET="$_WGET --no-check-certificate "
    fi
    if [ "$httpmethod" = "HEAD" ]; then
      _WGET="$_WGET --read-timeout=3.0  --tries=2  "
    fi
    _debug "_WGET" "$_WGET"
    if [ "$needbase64" ]; then
      if [ "$httpmethod" = "POST" ]; then
        if [ "$_postContentType" ]; then
          response="$($_WGET -S -O - --user-agent="$USER_AGENT" --header "$_H5" --header "$_H4" --header "$_H3" --header "$_H2" --header "$_H1" --header "Content-Type: $_postContentType" --post-data="$body" "$_post_url" 2>"$HTTP_HEADER" | _base64)"
        else
          response="$($_WGET -S -O - --user-agent="$USER_AGENT" --header "$_H5" --header "$_H4" --header "$_H3" --header "$_H2" --header "$_H1" --post-data="$body" "$_post_url" 2>"$HTTP_HEADER" | _base64)"
        fi
      else
        if [ "$_postContentType" ]; then
          response="$($_WGET -S -O - --user-agent="$USER_AGENT" --header "$_H5" --header "$_H4" --header "$_H3" --header "$_H2" --header "$_H1" --header "Content-Type: $_postContentType" --method $httpmethod --body-data="$body" "$_post_url" 2>"$HTTP_HEADER" | _base64)"
        else
          response="$($_WGET -S -O - --user-agent="$USER_AGENT" --header "$_H5" --header "$_H4" --header "$_H3" --header "$_H2" --header "$_H1" --method $httpmethod --body-data="$body" "$_post_url" 2>"$HTTP_HEADER" | _base64)"
        fi
      fi
    else
      if [ "$httpmethod" = "POST" ]; then
        if [ "$_postContentType" ]; then
          response="$($_WGET -S -O - --user-agent="$USER_AGENT" --header "$_H5" --header "$_H4" --header "$_H3" --header "$_H2" --header "$_H1" --header "Content-Type: $_postContentType" --post-data="$body" "$_post_url" 2>"$HTTP_HEADER")"
        else
          response="$($_WGET -S -O - --user-agent="$USER_AGENT" --header "$_H5" --header "$_H4" --header "$_H3" --header "$_H2" --header "$_H1" --post-data="$body" "$_post_url" 2>"$HTTP_HEADER")"
        fi
      elif [ "$httpmethod" = "HEAD" ]; then
        if [ "$_postContentType" ]; then
          response="$($_WGET --spider -S -O - --user-agent="$USER_AGENT" --header "$_H5" --header "$_H4" --header "$_H3" --header "$_H2" --header "$_H1" --header "Content-Type: $_postContentType" --post-data="$body" "$_post_url" 2>"$HTTP_HEADER")"
        else
          response="$($_WGET --spider -S -O - --user-agent="$USER_AGENT" --header "$_H5" --header "$_H4" --header "$_H3" --header "$_H2" --header "$_H1" --post-data="$body" "$_post_url" 2>"$HTTP_HEADER")"
        fi
      else
        if [ "$_postContentType" ]; then
          response="$($_WGET -S -O - --user-agent="$USER_AGENT" --header "$_H5" --header "$_H4" --header "$_H3" --header "$_H2" --header "$_H1" --header "Content-Type: $_postContentType" --method $httpmethod --body-data="$body" "$_post_url" 2>"$HTTP_HEADER")"
        else
          response="$($_WGET -S -O - --user-agent="$USER_AGENT" --header "$_H5" --header "$_H4" --header "$_H3" --header "$_H2" --header "$_H1" --method $httpmethod --body-data="$body" "$_post_url" 2>"$HTTP_HEADER")"
        fi
      fi
    fi
    _ret="$?"
    if [ "$_ret" = "8" ]; then
      _ret=0
      _debug "wget returned 8 as the server returned a 'Bad Request' response. Let's process the response later."
    fi
    if [ "$_ret" != "0" ]; then
      _err "Please refer to https://www.gnu.org/software/wget/manual/html_node/Exit-Status.html for error code: $_ret"
    fi
    if _contains "$_WGET" " -d "; then
      # Demultiplex wget debug output
      cat "$HTTP_HEADER" >&2
      _sed_i '/^[^ ][^ ]/d; /^ *$/d' "$HTTP_HEADER"
    fi
    # remove leading whitespaces from header to match curl format
    _sed_i 's/^  //g' "$HTTP_HEADER"
  else
    _ret="$?"
    _err "Neither curl nor wget have been found, cannot make $httpmethod request."
  fi
  _debug "_ret" "$_ret"
  printf "%s" "$response"
  return $_ret
}

# url getheader timeout
_get() {
  _debug GET
  url="$1"
  onlyheader="$2"
  t="$3"
  _debug url "$url"
  _debug "timeout=$t"

  _inithttp

  if [ "$_ACME_CURL" ] && [ "${ACME_USE_WGET:-0}" = "0" ]; then
    _CURL="$_ACME_CURL"
    if [ "$HTTPS_INSECURE" ]; then
      _CURL="$_CURL --insecure  "
    fi
    if [ "$t" ]; then
      _CURL="$_CURL --connect-timeout $t"
    fi
    _debug "_CURL" "$_CURL"
    if [ "$onlyheader" ]; then
      $_CURL -I --user-agent "$USER_AGENT" -H "$_H1" -H "$_H2" -H "$_H3" -H "$_H4" -H "$_H5" "$url"
    else
      $_CURL --user-agent "$USER_AGENT" -H "$_H1" -H "$_H2" -H "$_H3" -H "$_H4" -H "$_H5" "$url"
    fi
    ret=$?
    if [ "$ret" != "0" ]; then
      _err "Please refer to https://curl.haxx.se/libcurl/c/libcurl-errors.html for error code: $ret"
      if [ "$DEBUG" ] && [ "$DEBUG" -ge "2" ]; then
        _err "Here is the curl dump log:"
        _err "$(cat "$_CURL_DUMP")"
      fi
    fi
  elif [ "$_ACME_WGET" ]; then
    _WGET="$_ACME_WGET"
    if [ "$HTTPS_INSECURE" ]; then
      _WGET="$_WGET --no-check-certificate "
    fi
    if [ "$t" ]; then
      _WGET="$_WGET --timeout=$t"
    fi
    _debug "_WGET" "$_WGET"
    if [ "$onlyheader" ]; then
      _wget_out="$($_WGET --user-agent="$USER_AGENT" --header "$_H5" --header "$_H4" --header "$_H3" --header "$_H2" --header "$_H1" -S -O /dev/null "$url" 2>&1)"
      if _contains "$_WGET" " -d "; then
        # Demultiplex wget debug output
        echo "$_wget_out" >&2
        echo "$_wget_out" | sed '/^[^ ][^ ]/d; /^ *$/d; s/^  //g' -
      fi
    else
      $_WGET --user-agent="$USER_AGENT" --header "$_H5" --header "$_H4" --header "$_H3" --header "$_H2" --header "$_H1" -S -O - "$url" 2>"$HTTP_HEADER"
      if _contains "$_WGET" " -d "; then
        # Demultiplex wget debug output
        cat "$HTTP_HEADER" >&2
        _sed_i '/^[^ ][^ ]/d; /^ *$/d' "$HTTP_HEADER"
      fi
      # remove leading whitespaces from header to match curl format
      _sed_i 's/^  //g' "$HTTP_HEADER"
    fi
    ret=$?
    if [ "$ret" = "8" ]; then
      ret=0
      _debug "wget returned 8 as the server returned a 'Bad Request' response. Let's process the response later."
    fi
    if [ "$ret" != "0" ]; then
      _err "Please refer to https://www.gnu.org/software/wget/manual/html_node/Exit-Status.html for error code: $ret"
    fi
  else
    ret=$?
    _err "Neither curl nor wget have been found, cannot make GET request."
  fi
  _debug "ret" "$ret"
  return $ret
}


_h_char_2_dec() {
  _ch=$1
  case "${_ch}" in
  a | A)
    printf "10"
    ;;
  b | B)
    printf "11"
    ;;
  c | C)
    printf "12"
    ;;
  d | D)
    printf "13"
    ;;
  e | E)
    printf "14"
    ;;
  f | F)
    printf "15"
    ;;
  *)
    printf "%s" "$_ch"
    ;;
  esac

}

#openwrt have xargs in busybox
_h2b() {
  if _exists xxd; then
    if _contains "$(xxd --help 2>&1)" "assumes -c30"; then
      if xxd -r -p -c 9999 2>/dev/null; then
        return
      fi
    else
      if xxd -r -p 2>/dev/null; then
        return
      fi
    fi
  fi

  hex=$(cat)
  ic=""
  jc=""
  _debug2 _URGLY_PRINTF "$_URGLY_PRINTF"
  if [ -z "$_URGLY_PRINTF" ]; then
    if [ "$_ESCAPE_XARGS" ] && _exists xargs; then
      _debug2 "xargs"
      echo "$hex" | _upper_case | sed 's/\([0-9A-F]\{2\}\)/\\\\\\x\1/g' | xargs printf
    else
      for h in $(echo "$hex" | _upper_case | sed 's/\([0-9A-F]\{2\}\)/ \1/g'); do
        if [ -z "$h" ]; then
          break
        fi
        printf "\x$h%s"
      done
    fi
  else
    for c in $(echo "$hex" | _upper_case | sed 's/\([0-9A-F]\)/ \1/g'); do
      if [ -z "$ic" ]; then
        ic=$c
        continue
      fi
      jc=$c
      ic="$(_h_char_2_dec "$ic")"
      jc="$(_h_char_2_dec "$jc")"
      printf '\'"$(printf "%o" "$(_math "$ic" \* 16 + $jc)")""%s"
      ic=""
      jc=""
    done
  fi

}

_head_n() {
  head -n "$1"
}

_is_solaris() {
  _contains "${__OS__:=$(uname -a)}" "solaris" || _contains "${__OS__:=$(uname -a)}" "SunOS"
}

_tail_n() {
  if _is_solaris; then
    #fix for solaris
    tail -"$1"
  else
    tail -n "$1"
  fi
}

_tail_c() {
  tail -c "$1" 2>/dev/null || tail -"$1"c
}

#domain
_is_idn() {
  _is_idn_d="$1"
  _debug2 _is_idn_d "$_is_idn_d"
  _idn_temp=$(printf "%s" "$_is_idn_d" | tr -d '[0-9]' | tr -d '[a-z]' | tr -d '[A-Z]' | tr -d '*.,-_')
  _debug2 _idn_temp "$_idn_temp"
  [ "$_idn_temp" ]
}

#aa.com
#aa.com,bb.com,cc.com
_idn() {
  __idn_d="$1"
  if ! _is_idn "$__idn_d"; then
    printf "%s" "$__idn_d"
    return 0
  fi

  if _exists idn; then
    if _contains "$__idn_d" ','; then
      _i_first="1"
      for f in $(echo "$__idn_d" | tr ',' ' '); do
        [ -z "$f" ] && continue
        if [ -z "$_i_first" ]; then
          printf "%s" ","
        else
          _i_first=""
        fi
        idn --quiet "$f" | tr -d "\r\n"
      done
    else
      idn "$__idn_d" | tr -d "\r\n"
    fi
  else
    _err "Please install idn to process IDN names."
  fi
}

_url_replace() {
  tr '/+' '_-' | tr -d '= '
}

_normalizeJson() {
  sed "s/\" *: *\([\"{\[]\)/\":\1/g" | sed "s/^ *\([^ ]\)/\1/" | tr -d "\r\n"
}

#setopt "file"  "opt"  "="  "value" [";"]
_setopt() {
  __conf="$1"
  __opt="$2"
  __sep="$3"
  __val="$4"
  __end="$5"
  if [ -z "$__opt" ]; then
    _usage usage: _setopt '"file"  "opt"  "="  "value" [";"]'
    return
  fi
  if [ ! -f "$__conf" ]; then
    touch "$__conf"
  fi
  if [ -n "$(_tail_c 1 <"$__conf")" ]; then
    echo >>"$__conf"
  fi

  if grep -n "^$__opt$__sep" "$__conf" >/dev/null; then
    _debug3 OK
    if _contains "$__val" "&"; then
      __val="$(echo "$__val" | sed 's/&/\\&/g')"
    fi
    if _contains "$__val" "|"; then
      __val="$(echo "$__val" | sed 's/|/\\|/g')"
    fi
    text="$(cat "$__conf")"
    printf -- "%s\n" "$text" | sed "s|^$__opt$__sep.*$|$__opt$__sep$__val$__end|" >"$__conf"

  elif grep -n "^#$__opt$__sep" "$__conf" >/dev/null; then
    if _contains "$__val" "&"; then
      __val="$(echo "$__val" | sed 's/&/\\&/g')"
    fi
    if _contains "$__val" "|"; then
      __val="$(echo "$__val" | sed 's/|/\\|/g')"
    fi
    text="$(cat "$__conf")"
    printf -- "%s\n" "$text" | sed "s|^#$__opt$__sep.*$|$__opt$__sep$__val$__end|" >"$__conf"

  else
    _debug3 APP
    echo "$__opt$__sep$__val$__end" >>"$__conf"
  fi
  _debug3 "$(grep -n "^$__opt$__sep" "$__conf")"
}

#config file related function: most dns scripts still reads form env variables too though
#_save_conf  file key  value base64encode
#save to conf
_save_conf() {
  _s_c_f="$1"
  _sdkey="$2"
  _sdvalue="$3"
  _b64encode="$4"
  
  if [ "$_sdvalue" ] && [ "$_b64encode" ]; then
    _sdvalue="${B64CONF_START}$(printf "%s" "${_sdvalue}" | _base64)${B64CONF_END}"
  fi
  if [ "$_s_c_f" ]; then
    _setopt "$_s_c_f" "$_sdkey" "=" "'$_sdvalue'"
  else
    _err "Config file is empty, cannot save $_sdkey=$_sdvalue"
  fi
}

#_clear_conf file  key
_clear_conf() {
  _c_c_f="$1"
  _sdkey="$2"
  if [ "$_c_c_f" ]; then
    _conf_data="$(cat "$_c_c_f")"
    echo "$_conf_data" | sed "/^$_sdkey *=.*$/d" >"$_c_c_f"
  else
    _err "Config file is empty, cannot clear"
  fi
}

#_read_conf file  key
_read_conf() {
  _r_c_f="$1"
  _sdkey="$2"
  if [ -f "$_r_c_f" ]; then
    _sdv="$(
      eval "$(grep "^$_sdkey *=" "$_r_c_f")"
      eval "printf \"%s\" \"\$$_sdkey\""
    )"
    if _startswith "$_sdv" "${B64CONF_START}" && _endswith "$_sdv" "${B64CONF_END}"; then
      _sdv="$(echo "$_sdv" | sed "s/${B64CONF_START}//" | sed "s/${B64CONF_END}//" | _dbase64)"
    fi
    printf "%s" "$_sdv"
  else
    _debug "Config file is empty, cannot read $_sdkey"
  fi
}

#_savedomainconf   key  value  base64encode
#save to domain.conf
_savedomainconf() {
  _save_conf "$DOMAIN_CONF" "$@"
}

#_cleardomainconf   key
_cleardomainconf() {
  _clear_conf "$DOMAIN_CONF" "$1"
}

#_readdomainconf   key
_readdomainconf() {
  _read_conf "$DOMAIN_CONF" "$1"
}

#_migratedomainconf   oldkey  newkey  base64encode
_migratedomainconf() {
  _old_key="$1"
  _new_key="$2"
  _b64encode="$3"
  _old_value=$(_readdomainconf "$_old_key")
  _cleardomainconf "$_old_key"
  if [ -z "$_old_value" ]; then
    return 1 # migrated failed: old value is empty
  fi
  _new_value=$(_readdomainconf "$_new_key")
  if [ -n "$_new_value" ]; then
    _debug "Domain config new key exists, old key $_old_key='$_old_value' has been removed."
    return 1 # migrated failed: old value replaced by new value
  fi
  _savedomainconf "$_new_key" "$_old_value" "$_b64encode"
  _debug "Domain config $_old_key has been migrated to $_new_key."
}

#_migratedeployconf   oldkey  newkey  base64encode
_migratedeployconf() {
  _migratedomainconf "$1" "SAVED_$2" "$3" ||
    _migratedomainconf "SAVED_$1" "SAVED_$2" "$3" # try only when oldkey itself is not found
}

#key  value  base64encode
_savedeployconf() {
  _savedomainconf "SAVED_$1" "$2" "$3"
  #remove later
  _cleardomainconf "$1"
}

#key
_getdeployconf() {
  _rac_key="$1"
  _rac_value="$(eval echo \$"$_rac_key")"
  if [ "$_rac_value" ]; then
    if _startswith "$_rac_value" '"' && _endswith "$_rac_value" '"'; then
      _debug2 "trim quotation marks"
      eval $_rac_key=$_rac_value
      export $_rac_key
    fi
    return 0 # do nothing
  fi
  _saved="$(_readdomainconf "SAVED_$_rac_key")"
  eval $_rac_key=\$_saved
  export $_rac_key
}

#_saveaccountconf  key  value  base64encode
_saveaccountconf() {
  _save_conf "$ACCOUNT_CONF_PATH" "$@"
}

#key  value base64encode
_saveaccountconf_mutable() {
  _save_conf "$ACCOUNT_CONF_PATH" "SAVED_$1" "$2" "$3"
  #remove later
  _clearaccountconf "$1"
}

#key
_readaccountconf() {
  _read_conf "$ACCOUNT_CONF_PATH" "$1"
}

#key
_readaccountconf_mutable() {
  _rac_key="$1"
  _readaccountconf "SAVED_$_rac_key"
}

#_clearaccountconf   key
_clearaccountconf() {
  _clear_conf "$ACCOUNT_CONF_PATH" "$1"
}

#key
_clearaccountconf_mutable() {
  _clearaccountconf "SAVED_$1"
  #remove later
  _clearaccountconf "$1"
}

#_savecaconf  key  value
_savecaconf() {
  _save_conf "$CA_CONF" "$1" "$2"
}

#_readcaconf   key
_readcaconf() {
  _read_conf "$CA_CONF" "$1"
}

#_clearaccountconf   key
_clearcaconf() {
  _clear_conf "$CA_CONF" "$1"
}