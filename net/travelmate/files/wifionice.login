#!/bin/sh
# captive portal auto-login script for german ICE hotspots
# written by Dirk Brenken (dev@brenken.org)

# This is free software, licensed under the GNU General Public License v3.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

domain="www.wifionice.de"
cmd="$(command -v curl)"

# curl check
#
if [ ! -x "${cmd}" ]
then
	exit 1
fi

# initial get request to receive & extract a valid security token
#
"${cmd}" "http://${domain}/en/" -s -o /dev/null -c "/tmp/${domain}.cookie"
if [ -f "/tmp/${domain}.cookie" ]
then
	sec_token="$(awk '/csrf/{print $7}' "/tmp/${domain}.cookie")"
	rm -f "/tmp/${domain}.cookie"
else
	exit 2
fi

# final post request/login with valid session cookie/security token
#
if [ -n "${sec_token}" ]
then
	"${cmd}" "http://${domain}/en/" -H "Cookie: csrf=${sec_token}" --data "login=true&CSRFToken=${sec_token}&connect=" -s -o /dev/null
else
	exit 3
fi
