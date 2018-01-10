# SSL Configuration

Current as at 21st December 2017.

Applies to main/web-acessible server only.

SSL certificates obtained by free service LetsEncrypt.  Their local agent is called `certbot` and has an Ubuntu package.

## Certbot Installation

As per online documentation:

```bash
$ sudo apt install software-proprietary-common
$ sudo add-apt-repository ppa:certbot/common
$ sudo apt update
$ sudo apt install python-certbot-apache
```

## Cerficate Configuration

I mucked around a lot installing the certificates but I ended up with a single certificate name `rubikscomplex` with all domains attached, e.g. rubikscomplex.net, www.rubikscomplex.net, father.rubikscomplex.net etc.

Automatic install for Apache did not work as it conflicted with the Django implementations (something about using the daemon name twice - I suspect it was trying to set up a parallel configuration under SSL but daemon names must be unique).  The Apache plugin is only in beta at this point anyway, so avoid using it.

The configuration should *something* like:

```bash
$ sudo certbot register --cert-name rubikscomplex -d rubikscomplex.net -d www.rubikscomplex.net -d father.rubikscomplex.net -d mother.rubikscomplex.net
```

A new subdomain can be added or removed just by specifying the "new complete list" with the following format:

```bash
$ sudo certbot --cert-name rubikscomplex --expand -d rubikscomplex.net -d www.rubikscomplex.net -d father.rubikscomplex.net -d mother.rubikscomplex.net -d another-subdomain.rubikscomplex.net
```

## Apache Configuration

Redirect from HTTP to HTTPS (000-le-redirect-rubikscomplex.net.conf):

```apache
<VirtualHost _default_:80>
    ServerName rubikscomplex.net
    ServerAlias www.rubikscomplex.net

    ServerSignature Off

    RewriteEngine On
    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]

    ErrorLog /var/log/apache2/redirect.error.log
    LogLevel warn
</VirtualHost>
```

Django site that's under 2 subdomains (001-money.conf):

```apache
<VirtualHost *:443>
    ServerName father.rubikscomplex.net
    ServerAlias mother.rubikscomplex.net

    ServerAdmin cdavoren@gmail.com
    DocumentRoot /var/www/money

    LogLevel warn

    ErrorLog ${APACHE_LOG_DIR}/money-error.log
    CustomLog ${APACHE_LOG_DIR}/money-access.log combined

    WSGIDaemonProcess djangomoney python-path=/var/www/money:/var/www/money/env/lib/python3.4/site-packages
    WSGIProcessGroup djangomoney
    WSGIScriptAlias / /var/www/money/money/wsgi.py

    Alias /static/ /var/www/money/static/

    <Location /static/>
        Options -Indexes
    </Location>

    <Directory /var/www/money/money>
        <Files wsgi.py>
        Order deny,allow
        Allow from all
        </Files>
    </Directory>

    SSLEngine on
    <FilesMatch "\.(cgi|shtml|phtml|php)$">
        SSLOptions +StdEnvVars
    </FilesMatch>
    <Directory /usr/lib/cgi-bin>
        SSLOptions +StdEnvVars
    </Directory>


    SSLCertificateFile /etc/letsencrypt/live/rubikscomplex/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/rubikscomplex/privkey.pem
    Include /etc/letsencrypt/options-ssl-apache.conf
</VirtualHost>
```

Main site (002-default-ssl.conf)

```apache
<IfModule mod_ssl.c>
    <VirtualHost _default_:443>
        ServerName rubikscomplex.net
    ServerAlias www.rubikscomplex.net
        ServerAdmin webmaster@localhost

        DocumentRoot /var/www/html

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with "a2disconf".
        #Include conf-available/serve-cgi-bin.conf

        #   SSL Engine Switch:
        #   Enable/Disable SSL for this virtual host.
        SSLEngine on

        #   A self-signed (snakeoil) certificate can be created by installing
        #   the ssl-cert package. See
        #   /usr/share/doc/apache2/README.Debian.gz for more info.
        #   If both key and certificate are stored in the same file, only the
        #   SSLCertificateFile directive is needed.

        #   Server Certificate Chain:
        #   Point SSLCertificateChainFile at a file containing the
        #   concatenation of PEM encoded CA certificates which form the
        #   certificate chain for the server certificate. Alternatively
        #   the referenced file can be the same as SSLCertificateFile
        #   when the CA certificates are directly appended to the server
        #   certificate for convinience.
        #SSLCertificateChainFile /etc/apache2/ssl.crt/server-ca.crt

        #   Certificate Authority (CA):
        #   Set the CA certificate verification path where to find CA
        #   certificates for client authentication or alternatively one
        #   huge file containing all of them (file must be PEM encoded)
        #   Note: Inside SSLCACertificatePath you need hash symlinks
        #        to point to the certificate files. Use the provided
        #        Makefile to update the hash symlinks after changes.
        #SSLCACertificatePath /etc/ssl/certs/
        #SSLCACertificateFile /etc/apache2/ssl.crt/ca-bundle.crt

        #   Certificate Revocation Lists (CRL):
        #   Set the CA revocation path where to find CA CRLs for client
        #   authentication or alternatively one huge file containing all
        #   of them (file must be PEM encoded)
        #   Note: Inside SSLCARevocationPath you need hash symlinks
        #        to point to the certificate files. Use the provided
        #        Makefile to update the hash symlinks after changes.
        #SSLCARevocationPath /etc/apache2/ssl.crl/
        #SSLCARevocationFile /etc/apache2/ssl.crl/ca-bundle.crl

        #   Client Authentication (Type):
        #   Client certificate verification type and depth.  Types are
        #   none, optional, require and optional_no_ca.  Depth is a
        #   number which specifies how deeply to verify the certificate
        #   issuer chain before deciding the certificate is not valid.
        #SSLVerifyClient require
        #SSLVerifyDepth  10

        #   SSL Engine Options:
        #   Set various options for the SSL engine.
        #   o FakeBasicAuth:
        #    Translate the client X.509 into a Basic Authorisation.  This means that
        #    the standard Auth/DBMAuth methods can be used for access control.  The
        #    user name is the `one line' version of the client's X.509 certificate.
        #    Note that no password is obtained from the user. Every entry in the user
        #    file needs this password: `xxj31ZMTZzkVA'.
        #   o ExportCertData:
        #    This exports two additional environment variables: SSL_CLIENT_CERT and
        #    SSL_SERVER_CERT. These contain the PEM-encoded certificates of the
        #    server (always existing) and the client (only existing when client
        #    authentication is used). This can be used to import the certificates
        #    into CGI scripts.
        #   o StdEnvVars:
        #    This exports the standard SSL/TLS related `SSL_*' environment variables.
        #    Per default this exportation is switched off for performance reasons,
        #    because the extraction step is an expensive operation and is usually
        #    useless for serving static content. So one usually enables the
        #    exportation for CGI and SSI requests only.
        #   o OptRenegotiate:
        #    This enables optimized SSL connection renegotiation handling when SSL
        #    directives are used in per-directory context.
        #SSLOptions +FakeBasicAuth +ExportCertData +StrictRequire
        <FilesMatch "\.(cgi|shtml|phtml|php)$">
                SSLOptions +StdEnvVars
        </FilesMatch>
        <Directory /usr/lib/cgi-bin>
                SSLOptions +StdEnvVars
        </Directory>

        #   SSL Protocol Adjustments:
        #   The safe and default but still SSL/TLS standard compliant shutdown
        #   approach is that mod_ssl sends the close notify alert but doesn't wait for
        #   the close notify alert from client. When you need a different shutdown
        #   approach you can use one of the following variables:
        #   o ssl-unclean-shutdown:
        #    This forces an unclean shutdown when the connection is closed, i.e. no
        #    SSL close notify alert is send or allowed to received.  This violates
        #    the SSL/TLS standard but is needed for some brain-dead browsers. Use
        #    this when you receive I/O errors because of the standard approach where
        #    mod_ssl sends the close notify alert.
        #   o ssl-accurate-shutdown:
        #    This forces an accurate shutdown when the connection is closed, i.e. a
        #    SSL close notify alert is send and mod_ssl waits for the close notify
        #    alert of the client. This is 100% SSL/TLS standard compliant, but in
        #    practice often causes hanging connections with brain-dead browsers. Use
        #    this only for browsers where you know that their SSL implementation
        #    works correctly.
        #   Notice: Most problems of broken clients are also related to the HTTP
        #   keep-alive facility, so you usually additionally want to disable
        #   keep-alive for those clients, too. Use variable "nokeepalive" for this.
        #   Similarly, one has to force some clients to use HTTP/1.0 to workaround
        #   their broken HTTP/1.1 implementation. Use variables "downgrade-1.0" and
        #   "force-response-1.0" for this.
        # BrowserMatch "MSIE [2-6]" \
        #           nokeepalive ssl-unclean-shutdown \
        #           downgrade-1.0 force-response-1.0

        Include /etc/letsencrypt/options-ssl-apache.conf
        SSLCertificateFile /etc/letsencrypt/live/rubikscomplex/fullchain.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/rubikscomplex/privkey.pem
    </VirtualHost>
</IfModule>
```

## Automatic Renewal

As per `certbot` documentation, recommended to be done twice per day.  Done using the built in command `certbot renew` using a cron job.  The documentation says that the `certbot` package comes with a cron job, but one did not appear to automatically install for me.  It should be run as root due to the user-only permissions on the certificate files.

**Note:** If the certificate is actually being renewed (i.e. it is close to their renewal date), then the Apache server must shut down briefly to allow the automated authentication to run (it requires binding ports 80 and 443).  To automate this, you have to use the 'hooks', which are any *executable* files in the `/var/letsencrypt/renewal-hooks` subdirectories.

Pre-hook (`/etc/letsencrypt/renewal-hooks/pre/apache-stop.sh`):

```bash
#!/bin/bash

systemctl stop apache2
```

Post-hook (`/etc/letsencrupt/renewal-hooks/post/apache-start.sh`):

```bash
#!/bin/bash

systemctl start apache2
```

**Note**: Use `sudo certbot renew --dry-run` to ensure that it's working.

The crontab should be on a 'random minute', presumably as a courtesy to distribute server load.  My crontab file (as root):

```crontab
MAILTO=cdavoren@gmail.com
23 01,13 * * * certbot renew -q
```

Because the -q (quiet, non-interactive) option is specified, this should only email if there is an error.
