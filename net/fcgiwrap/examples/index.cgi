#!/bin/bash

echo Content-type: text/html
echo ""
cat << EOF
<HTML>
<HEAD><TITLE>Bash script</TITLE></HEAD>
<BODY><PRE>
<div align=center><h1>A BASH CGI index on third location with env variables</h1></div>
EOF
env
cat << EOF
</BODY>
</HTML>
EOF


