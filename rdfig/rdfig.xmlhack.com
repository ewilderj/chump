<VirtualHost 80.87.131.124:80>
ServerAdmin webmaster@xmlhack.com
DocumentRoot /home/rdfig/public_html
ServerName rdfig.xmlhack.com
ServerAlias new-rdfig.xmlhack.com
CustomLog "|rotatelogs /home/rdfig/logs/access_log 86400" combined
ErrorLog "|rotatelogs /home/rdfig/logs/error_log 86400"
DirectoryIndex index.php index.html
RewriteEngine on
RewriteRule ^/((.*).html) /style.php?fname=$1 [L]
RewriteRule ^/((.*).rss) /style.php?fname=$1&type=rss [L]
RewriteRule ^/((.*).mini) /style.php?fname=$1&type=mini [L]
</VirtualHost>
