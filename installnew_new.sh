#!/bin/bash

# New Odoo instance configuration
NEW_OE_USER="odoo_new"
NEW_OE_HOME="/$NEW_OE_USER"
NEW_OE_HOME_EXT="/$NEW_OE_USER/${NEW_OE_USER}-server"
NEW_OE_PORT="8071"
NEW_OE_CONFIG="${NEW_OE_USER}-server"
NEW_LONGPOLLING_PORT="8073"
NEW_LOG_DIR="/var/log/$NEW_OE_USER"
NEW_OE_SUPERADMIN="new_admin"
OE_VERSION="master"

# Create new Odoo user for the second instance
echo -e "\n---- Create Odoo New User ----"
sudo adduser --system --quiet --shell=/bin/bash --home=$NEW_OE_HOME --gecos 'Odoo New' --group $NEW_OE_USER
sudo adduser $NEW_OE_USER sudo

# Create log directory for the new instance
echo -e "\n---- Create Log directory ----"
sudo mkdir $NEW_LOG_DIR
sudo chown $NEW_OE_USER:$NEW_OE_USER $NEW_LOG_DIR

# Clone Odoo for the new instance
echo -e "\n==== Installing New Odoo Server ===="
sudo git clone --depth 1 --branch $OE_VERSION https://github.com/odoo/odoo $NEW_OE_HOME_EXT/

# Adjust permissions
echo -e "\n---- Setting permissions on home folder ----"
sudo chown -R $NEW_OE_USER:$NEW_OE_USER $NEW_OE_HOME/*

# Create and configure the server config file for the new instance
echo -e "* Create server config file for new instance"
sudo touch /etc/${NEW_OE_CONFIG}.conf
sudo su root -c "printf '[options] \n; This is the password that allows database operations:\n' >> /etc/${NEW_OE_CONFIG}.conf"
sudo su root -c "printf 'admin_passwd = ${NEW_OE_SUPERADMIN}\n' >> /etc/${NEW_OE_CONFIG}.conf"
sudo su root -c "printf 'http_port = ${NEW_OE_PORT}\n' >> /etc/${NEW_OE_CONFIG}.conf"
sudo su root -c "printf 'longpolling_port = ${NEW_LONGPOLLING_PORT}\n' >> /etc/${NEW_OE_CONFIG}.conf"
sudo su root -c "printf 'logfile = ${NEW_LOG_DIR}/${NEW_OE_CONFIG}.log\n' >> /etc/${NEW_OE_CONFIG}.conf"
sudo su root -c "printf 'addons_path=${NEW_OE_HOME_EXT}/addons,${NEW_OE_HOME}/custom/addons\n' >> /etc/${NEW_OE_CONFIG}.conf"
sudo chown $NEW_OE_USER:$NEW_OE_USER /etc/${NEW_OE_CONFIG}.conf
sudo chmod 640 /etc/${NEW_OE_CONFIG}.conf

# Create startup file for the new instance
echo -e "* Create startup file for new instance"
sudo su root -c "echo '#!/bin/sh' >> $NEW_OE_HOME_EXT/start.sh"
sudo su root -c "echo 'sudo -u $NEW_OE_USER $NEW_OE_HOME_EXT/odoo-bin --config=/etc/${NEW_OE_CONFIG}.conf' >> $NEW_OE_HOME_EXT/start.sh"
sudo chmod 755 $NEW_OE_HOME_EXT/start.sh

# Create init file for the new instance (Adjust the init script as needed)
# ...

# Enable the new Odoo instance to start on system boot
echo -e "* Start New Odoo instance on Startup"
sudo update-rc.d $NEW_OE_CONFIG defaults

# Starting the new Odoo service
echo -e "* Starting New Odoo Service"
sudo su root -c "/etc/init.d/$NEW_OE_CONFIG start"
echo "-----------------------------------------------------------"
echo "New Odoo instance setup completed."
echo "Port: $NEW_OE_PORT"
echo "User service: $NEW_OE_USER"
echo "Configuration file location: /etc/${NEW_OE_CONFIG}.conf"
echo "Logfile location: $NEW_LOG_DIR"
echo "-----------------------------------------------------------"
