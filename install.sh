#!/bin/bash

# Imunify360 Installer for CentMinMod Installer [CMM]

# Scripted by Brijendra Sial @ Bullten Web Hosting Solutions [https://www.bullten.com]

RED='\033[01;31m'
RESET='\033[0m'
GREEN='\033[01;32m'
YELLOW='\e[93m'
WHITE='\e[97m'
BLINK='\e[5m'

#set -e
#set -x

echo " "
echo -e "$GREEN*******************************************************************************$RESET"
echo " "
echo -e $YELLOW"Imunify360 Installer for CentMinMod Installer [CMM]$RESET"
echo " "
echo -e $YELLOW"By Brijendra Sial @ Bullten Web Hosting Solutions [https://www.bullten.com]"$RESET
echo " "
echo -e $YELLOW"Web Hosting Company Specialized in Providing Managed VPS and Dedicated Server's"$RESET
echo " "
echo -e "$GREEN*******************************************************************************$RESET"


echo " "

if [ -e "/etc/centminmod" ]; then
echo " "
echo -e $GREEN"Centminmod Installation Detected"$RESET
echo " "

if $(nginx -V 2>&1 | tr ' ' '\n' | grep 'ModSecurity-nginx' > /dev/null); then
echo " "
echo -e $GREEN"Mod_Security Installation Found"$RESET
echo " "
$(mkdir -p /etc/sysconfig/imunify360)

cat > /etc/sysconfig/imunify360/integration.conf << EOF
[paths]
ui_path = /usr/local/nginx/html/im360
[web_server]
server_type = nginx
graceful_restart_script = /usr/local/sbin/nginx -s reload
modsec_audit_log = /var/log/nginx/modsec_audit.log
modsec_audit_logdir = /var/log/nginx
[malware]
basedir = /home
pattern_to_watch = ^/home/.+?/(public|private)(/.*)?$
[pam]
service_name = system-auth
EOF

cat > /usr/local/nginx/modsec.conf << EOF
SecAuditEngine RelevantOnly
SecConnEngine Off
SecRuleEngine On
SecAuditLogFormat JSON
# should match modsec_audit_log option in integration.conf (see below)
SecAuditLog /var/log/nginx/modsec_audit.log
EOF

$(mkdir -p /etc/sysconfig/imunify360/generic)
cat > /etc/sysconfig/imunify360/generic/modsec.conf << EOF
modsecurity on;
modsecurity_rules_file /usr/local/nginx/modsec.conf;
modsecurity_rules_file /etc/sysconfig/imunify360/generic/modsec.conf;
EOF

echo " "
echo -e $GREEN"All Configuration Files Created. Now We Will Process The Installation"$RESET
echo " "
echo -e $GREEN"Downloading Imunify360 Installer"$RESET
echo " "
wget https://repo.imunify360.cloudlinux.com/defence360/i360deploy.sh -O i360deploy.sh
echo " "
echo -e $GREEN"Executing Installer now"$RESET
echo " "
bash i360deploy.sh
echo " "
echo -e $GREEN"Installation Successfull"$RESET
echo " "
echo -e $GREEN"You Can Now Open http://$(hostname -I | cut -d' ' -f1)/im360" And Login With Your Root Login Details.$RESET
echo " "


else
echo " "
echo -e $RED"Please Install Mod_Security First By Adding NGINX_MODSECURITY='y' to /etc/centminmod/custom_config.inc Aand Compiling Nginx Again "$RESET
echo " "
fi
else
echo " "
echo -e $RED"Centminmod Installation Not Found"$RESET
echo " "
fi
