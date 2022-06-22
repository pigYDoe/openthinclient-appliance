#!/usr/bin/env bash -eux
# Filename:     openthinclient-installer.sh
# Purpose:      install new version of the openthinclient software package
#------------------------------------------------------------------------------


OTC_INSTALLER_FULLPATH=$(find /tmp/installers/ -name '*.sh' ! -name '*with_JRE.sh' -type f)
#OTC_INSTALLER_NAME=otc-manager_unix.sh
#OTC_INSTALLER_FULLPATH=/tmp/installers/${OTC_INSTALLER_NAME}

OTC_INSTALLER_VARFILE=/tmp/data/installer/unattended-linux.varfile.txt

# Please sync the following settings with the unattended linux-varfile
OTC_INSTALL_PATH=/opt/otc-manager/
#echo ${OTC_INSTALL_PATH}
#echo $OTC_INSTALL_PATH

# location of the home working directory
OTC_INSTALL_HOME=/home/openthinclient/otc-manager-home/

# Please uncomment password for openthinclient manager for local testing
#OTC_DEFAULT_PASS=0pen%TC

echo "==> Installing new openthinclient manager"
if [ -f "$OTC_INSTALLER_FULLPATH" ]; then
	echo "==> $OTC_INSTALLER_FULLPATH exists. Continue with installation"
	echo $OTC_INSTALLER_FULLPATH

	echo "==> Setting chmod +x for the installer binary: $OTC_INSTALLER_FULLPATH"
	chmod +x $OTC_INSTALLER_FULLPATH

	echo "==> Starting unattended installation with preconfigured varfile: $OTC_INSTALLER_VARFILE"
	echo $OTC_INSTALLER_FULLPATH -q -varfile $OTC_INSTALLER_VARFILE -Vservice.start=false
	$OTC_INSTALLER_FULLPATH -q -varfile $OTC_INSTALLER_VARFILE -Vservice.start=false

    echo "==> Checking for existing manager installation to prepare-home"
	if [ -f ${OTC_INSTALL_PATH}bin/managerctl ]; then
	    echo "==> Running managerctl to check available distributions"
	    ${OTC_INSTALL_PATH}bin/managerctl ls-distributions -v
	    echo $OTC_INSTALL_PATH/bin/managerctl ls-distributions -v

        echo "==> Running managerctl install with predefined variables and mySQL database backend"
	    $OTC_INSTALL_PATH/bin/managerctl prepare-home \
	    --admin-password $OTC_DEFAULT_PASS \
	    --home $OTC_INSTALL_HOME \
	    --dist-source http://archive.openthinclient.org/openthinclient/v2020/first-start-profiles/distributions.xml
	            
        echo "==> removing rpcbind package"
        apt-get remove -y --purge rpcbind nfs-common

        echo "==> Creating .appliance.properties file to activate noVNC"
        touch ${OTC_INSTALL_HOME}.appliance.properties
        chown openthinclient:openthinclient ${OTC_INSTALL_HOME}.appliance.properties

        echo "==> Starting the OTC manager service"
        ${OTC_INSTALL_PATH}/bin/openthinclient-manager start
        sleep 5
        echo "==> Checking service status after start"
        ${OTC_INSTALL_PATH}/bin/openthinclient-manager status

        echo "==> Fix permissions of ${OTC_INSTALL_HOME}"
        chown openthinclient:openthinclient ${OTC_INSTALL_HOME} -R

        ls -la ${OTC_INSTALL_HOME}

        echo "==> Create a symlink between the new install path and the legacy installation dir"
        ln -s "${OTC_INSTALL_PATH%/}" /opt/openthinclient

    else
	    echo "==> $OTC_INSTALL_PATH doesn't exist. Installation was not successful"
    fi

else
	echo "==> $OTC_INSTALLER_FULLPATH doesn't exist. Installation can't be executed"
fi

exit 0
