
RaidFileConf = <confdir>/raidfile.conf
AccountDatabase = <confdir>/bbstored/accounts.txt

# Uncomment this line to see exactly what commands are being received from clients.
# ExtendedLogging = yes

# scan all accounts for files which need deleting every 2 hours.
TimeBetweenHousekeeping = 7200

Server
{
	User = bbstored
	PidFile = <pidfile>
	ListenAddresses = inet:<hostname>
	CertificateFile = <confdir>/bbstored/<hostname>-cert.pem
	PrivateKeyFile = <confdir>/bbstored/<hostname>-key.pem
	TrustedCAsFile = <confdir>/bbstored/clientCA.pem
}


