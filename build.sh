#!/bin/bash
XLNX_VIVADO_VERSION=2025.2.1
XLNX_VIVADO_INSTALLER=FPGAs_AdaptiveSoCs_Unified_SDI_2025.2.1_0320_0604.tar
XLNX_PETALINUX_INSTALLER=petalinux-v2025.2-11160223-installer.run
XLNX_VIVADO_AUTH_FILE=wi_authentication_key
XLNX_VIVADO_BATCH_CONFIG_FILE=install_config_vivado.txt

XLNX_VIVADO_INSTALLER_NOTAR=$(echo $XLNX_VIVADO_INSTALLER | rev | cut -f 2- -d '.' | rev)
if [ ! -e wi_authentication_key ]; then
    tar -xf ./Installers_folder/${XLNX_VIVADO_INSTALLER} ${XLNX_VIVADO_INSTALLER_NOTAR}/xsetup
    tar -xf ./Installers_folder/${XLNX_VIVADO_INSTALLER} ${XLNX_VIVADO_INSTALLER_NOTAR}/tps/
    tar -xf ./Installers_folder/${XLNX_VIVADO_INSTALLER} ${XLNX_VIVADO_INSTALLER_NOTAR}/bin/
    tar -xf ./Installers_folder/${XLNX_VIVADO_INSTALLER} ${XLNX_VIVADO_INSTALLER_NOTAR}/lib/
    tar -xf ./Installers_folder/${XLNX_VIVADO_INSTALLER} ${XLNX_VIVADO_INSTALLER_NOTAR}/data/

    ./${XLNX_VIVADO_INSTALLER_NOTAR}/xsetup -b AuthTokenGen

    rm -rf ${XLNX_VIVADO_INSTALLER_NOTAR}
    
    mv ${HOME}/.Xilinx/wi_authentication_key .
fi

docker image build \
	--build-arg XLNX_VIVADO_VERSION=${XLNX_VIVADO_VERSION} \
	--build-arg XLNX_UNIFIED_INSTALLER=${XLNX_VIVADO_INSTALLER} \
    --build-arg XLNX_VIVADO_INSTALLER_NOTAR=${XLNX_VIVADO_INSTALLER_NOTAR} \
	--build-arg XLNX_PETALINUX_INSTALLER=${XLNX_PETALINUX_INSTALLER} \
	--build-arg XLNX_VIVADO_AUTH_FILE=${XLNX_VIVADO_AUTH_FILE} \
	--build-arg XLNX_VIVADO_BATCH_CONFIG_FILE=${XLNX_VIVADO_BATCH_CONFIG_FILE} \
	-t vivado:${XLNX_VIVADO_VERSION} .
#    --progress=plain \

if [ $? -eq 0 ]; then
    rm -rf wi_authentication_key
fi
