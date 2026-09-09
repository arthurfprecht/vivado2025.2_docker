#!/bin/bash
XLNX_VIVADO_VERSION=2025.2
XLNX_VIVADO_INSTALLER=FPGAs_AdaptiveSoCs_Unified_SDI_2025.2_0530_0145_Lin64.bin
XLNX_VIVADO_AUTH_FILE=wi_authentication_key
XLNX_VIVADO_BATCH_CONFIG_FILE=install_config_vivado.txt
XLNX_PETALINUX_BATCH_CONFIG_FILE=install_config_petalinux.txt

./${XLNX_VIVADO_INSTALLER} -- -b AuthTokenGen
mv ${HOME}/.Xilinx/wi_authentication_key .
docker image build \
	--build-arg XLNX_VIVADO_VERSION=${XLNX_VIVADO_VERSION} \
	--build-arg XLNX_VIVADO_INSTALLER=${XLNX_VIVADO_INSTALLER} \
	--build-arg XLNX_VIVADO_AUTH_FILE=${XLNX_VIVADO_AUTH_FILE} \
	--build-arg XLNX_VIVADO_BATCH_CONFIG_FILE=${XLNX_VIVADO_BATCH_CONFIG_FILE} \
	--build-arg XLNX_PETALINUX_BATCH_CONFIG_FILE=${XLNX_PETALINUX_BATCH_CONFIG_FILE} \
	-t vivado:${XLNX_VIVADO_VERSION} .
rm -rf wi_authentication_key
