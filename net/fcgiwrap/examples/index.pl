#!/usr/bin/perl
print "Content-type: text/html\n\n";
print <<HTML;
<html>
<head><title>Perl Index</title></head>
<body>
<div align=center><h1>A Perl CGI index with env variables</h1></div>
</body>
HTML
print "Content-type: text/html\n\n";
foreach my $keys (sort keys %ENV) {
  print "$keys = $ENV{$keys}<br/>\n";
}
exit;
