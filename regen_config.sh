#!/bin/bash

XLNX_VIVADO_INSTALLER=FPGAs_AdaptiveSoCs_Unified_SDI_2025.2.1_0320_0604.tar

XLNX_VIVADO_INSTALLER_NOTAR=$(echo $XLNX_VIVADO_INSTALLER | rev | cut -f 2- -d '.' | rev)

tar -xf ./Installers_folder/${XLNX_VIVADO_INSTALLER} ${XLNX_VIVADO_INSTALLER_NOTAR}/xsetup
tar -xf ./Installers_folder/${XLNX_VIVADO_INSTALLER} ${XLNX_VIVADO_INSTALLER_NOTAR}/tps/
tar -xf ./Installers_folder/${XLNX_VIVADO_INSTALLER} ${XLNX_VIVADO_INSTALLER_NOTAR}/bin/
tar -xf ./Installers_folder/${XLNX_VIVADO_INSTALLER} ${XLNX_VIVADO_INSTALLER_NOTAR}/lib/
tar -xf ./Installers_folder/${XLNX_VIVADO_INSTALLER} ${XLNX_VIVADO_INSTALLER_NOTAR}/data/

./${XLNX_VIVADO_INSTALLER_NOTAR}/xsetup --batch ConfigGen

rm -rf ${XLNX_VIVADO_INSTALLER_NOTAR}

