#!/bin/bash

a2enmod headers

cat > /etc/apache2/conf-available/security.conf <<'END'
ServerTokens Prod
ServerSignature Off
TraceEnable Off

FileETag None

<Directory />
	Options -Indexes -Includes
</Directory>

<IfModule mod_headers.c>
	Header set X-XSS-Protection "1; mode=block"
	Header set X-Content-Type-Options: "nosniff"
	Header set X-Frame-Options: "sameorigin"
	Header edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure
</IfModule>
END

cat > /etc/apache2/conf-available/ssloptions.conf <<'END'
<IfModule ssl_module>
	SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
	SSLCipherSuite HIGH:!aNULL:!MD5
	SSLHonorCipherOrder on
	<IfModule mod_headers.c>
		Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
	</IfModule>
</IfModule>
END

a2enconf security
a2enconf ssloptions

systemctl reload apache2
