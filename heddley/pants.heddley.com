<VirtualHost 80.87.131.124:80>
ServerAdmin webmaster@heddley.com
DocumentRoot /home/pants/public_html
ServerName pants.heddley.com
ServerAlias new-pants.heddley.com
CustomLog "|rotatelogs /home/pants/logs/access_log 86400" combined
ErrorLog "|rotatelogs /home/pants/logs/error_log 86400"
DirectoryIndex index.php index.html
RewriteEngine on
RewriteRule ^/((.*).html) /style.php?fname=$1 [L]
RewriteRule ^/((.*).rss) /style.php?fname=$1&type=rss [L]
RewriteRule ^/((.*).mini) /style.php?fname=$1&type=mini [L]
</VirtualHost>
