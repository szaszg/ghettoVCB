# Author: William Lam 
# 08/18/2009
# http://www.virtuallyghetto.com/
##################################################################

###### DO NOT EDIT PASS THIS LINE ######

LAST_MODIFIED_DATE=2020_04_14
VERSION=1
VERSION_STRING=${LAST_MODIFIED_DATE}_${VERSION}

printUsage() {
    echo "###############################################################################"
    echo "#"
    echo "# ghettoVCB-restore for ESX/ESXi 3.5, 4.x, 5.x, 6.x & 7.x"
    echo "# Author: William Lam"
    echo "# http://www.virtuallyghetto.com/"
    echo "# Documentation: http://communities.vmware.com/docs/DOC-8760"
    echo "# Created: 08/18/2009"
    echo "# Last modified: ${VERSION_STRING}"
    echo "#"
    echo "###############################################################################"
    echo
    echo "Usage: $0 -c [VM_BACKUP_UP_LIST] -l [LOG_FILE] -d [DRYRUN_DEBUG_INFO]"
    echo
    echo "OPTIONS:"
    echo "   -c     VM backup list"
    echo "   -l     File ot output logging"
    echo "   -d     Dryrun/Debug Info [1|2]"
    echo
    echo "(e.g.)"
    echo -e "\nOutput will go to stdout"
    echo -e "\t$0 -c vms_to_restore "
    echo -e "\nOutput will log to /tmp/ghettoVCB-restore.log"
    echo -e "\t$0 -c vms_to_restore -l /tmp/ghettoVCB-restore.log"
    echo -e "\nDryrun/Debug Info (dryrun only)"
    echo -e "\t$0 -c vms_to_restore -d 1"
    echo -e "\t$0 -c vms_to_restore -d 2"
    echo
    exit 1
}

logger() {
    MSG=$1
    [[ -n "$2" ]] && MSG="$1 $2"
    if [ "${LOG_TO_STDOUT}" -eq 1 ]; then
        echo -e "${MSG}"
    else
        echo -e "${MSG}" >> "${LOG_OUTPUT}"
    fi
}

sanityCheck() {
    NUM_OF_ARGS=$1

    # ensure root user is running the script
    if [ ! $(env | grep -e "^USER=" | awk -F = '{print $2}') == "root" ]; then
        logger "info" "This script needs to be executed by \"root\"!"
        echo "ERROR: This script needs to be executed by \"root\"!"
        exit 1
    fi

    if [[ ${RESTORE_INTERACTIVE} -ne 1 ]] && [[ ${NUM_OF_ARGS} -ne 2 ]] && [[ ${NUM_OF_ARGS} -ne 4 ]] && [[ ${NUM_OF_ARGS} -ne 6 ]] ; then
        printUsage
    fi

    #log to stdout or to logfile
    if [ -z "${LOG_OUTPUT}" ]; then
        LOG_TO_STDOUT=1
        REDIRECT=/dev/null
    else
        LOG_TO_STDOUT=0
        REDIRECT=${LOG_OUTPUT}
        echo "Logging output to \"${LOG_OUTPUT}\" ..."
        touch "${LOG_OUTPUT}"
    fi

    if [[ "${DEVEL_MODE}" == "1" ]] && [[ "${DEVEL_MODE}" == "2" ]] && [[ "${DEVEL_MODE}" == "0" ]] ; then
        DEVEL_MODE=0
    fi

    if [ -f /usr/bin/vmware-vim-cmd ]; then
        VMWARE_CMD=/usr/bin/vmware-vim-cmd
        VMKFSTOOLS_CMD=/usr/sbin/vmkfstools
    elif [ -f /bin/vim-cmd ]; then
        VMWARE_CMD=/bin/vim-cmd
        VMKFSTOOLS_CMD=/sbin/vmkfstools
    else
        logger "ERROR: Unable to locate *vimsh*! You're not running ESX(i) 3.5+, 4.x+, 5.x+, 6.x or 7.x!"
        echo "ERROR: Unable to locate *vimsh*! You're not running ESX(i) 3.5+, 4.x+, 5.x+, 6.x or 7.x!"
        exit
    fi

    ESX_VERSION=$(vmware -v | awk '{print $3}')

    case "${ESX_VERSION}" in
        7.0.0)                VER=7; break;;
        6.0.0|6.5.0|6.7.0)    VER=6; break;;
        5.0.0|5.1.0|5.5.0)    VER=5; break;;
        4.0.0|4.1.0)          VER=4; break;;
        3.5.0|3i)             VER=3; break;;
        *)              echo "You're not running ESX(i) 3.5, 4.x, 5.x, 6.x & 7.x!"; exit 1; break;;
    esac

    TAR="tar"
    [[ ! -f /bin/tar ]] && TAR="busybox tar"

    #ensure input file exists
    if [[ ${RESTORE_INTERACTIVE} -ne 1 ]] && [ ! -f "${CONFIG_FILE}" ]; then
        logger "ERROR: \"${CONFIG_FILE}\" input file does not exists\n"
        echo -e "ERROR: \"${CONFIG_FILE}\" input file does not exists\n"
        exit 1
    fi
}

startTimer() {
    START_TIME=$(date)
    S_TIME=$(date +%s)
}

endTimer() {
    END_TIME=$(date)
    E_TIME=$(date +%s)
    logger "\nStart time: ${START_TIME}"
    logger "End   time: ${END_TIME}"
    DURATION=$(echo $((E_TIME - S_TIME)))

    #calculate overall completion time
    if [ ${DURATION} -le 60 ]; then
        logger "Duration  : ${DURATION} Seconds"
    else
        logger "Duration  : $(awk 'BEGIN{ printf "%.2f\n", '${DURATION}'/60}') Minutes\n"
    fi
    logger "\n---------------------------------------------------------------------------------------------------------------\n"
    echo
}

ghettoVCBrestore() {
    VM_FILE=$1

    startTimer

    ORIG_IFS=${IFS}
    IFS='
'

    for LINE in $(cat "${VM_FILE}" | sed '/^$/d' | sed -e '/^#/d' | sed -e 's/^[[:blank:]]*//;s/[[:blank:]]*$//'); do
        VM_TO_RESTORE=$(echo "${LINE}" | awk -F ';' '{print $1}' | sed 's/"//g' | sed -e 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
        DATASTORE_TO_RESTORE_TO=$(echo "${LINE}" | awk -F ';' '{print $2}' | sed 's/"//g' | sed -e 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
        RESTORE_DISK_FORMAT=$(echo "${LINE}" | awk -F ';' '{print $3}' | sed 's/"//g' | sed -e 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
        RESTORE_VM_NAME=$(echo "${LINE}" | awk -F ';' '{print $4}' | sed 's/"//g' | sed -e 's/^[[:blank:]]*//;s/[[:blank:]]*$//')

        #figure the disk format to use
        if [ "${RESTORE_DISK_FORMAT}" -eq 1 ]; then
            FORMAT_STRING=zeroedthick
        elif [ "${RESTORE_DISK_FORMAT}" -eq 2 ]; then
            FORMAT_STRING=2gbsparse
        elif [ "${RESTORE_DISK_FORMAT}" -eq 3 ]; then
            FORMAT_STRING=thin
        elif [ "${RESTORE_DISK_FORMAT}" -eq 4 ]; then
            FORMAT_STRING=eagerzeroedthick
        fi

        #supports DIR or .TGZ from ghettoVCB.sh ONLY!
        if [ ${VM_TO_RESTORE##*.} == 'gz' ]; then
            logger "GZ found, extracting ..."
            ${TAR} -xzf $VM_TO_RESTORE -C `dirname $VM_TO_RESTORE`
            VM_TO_RESTORE=${VM_TO_RESTORE%.*}
        fi
        if [ -d "${VM_TO_RESTORE}" ]; then
            #figure out the contents of the directory (*.vmdk,*-flat.vmdk,*.vmx)
            VM_ORIG_VMX=$(ls "${VM_TO_RESTORE}" | grep ".vmx")
            VM_VMDK_DESCRS=$(ls "${VM_TO_RESTORE}" | grep ".vmdk" | grep -v "\-flat.vmdk")
            VMDKS_FOUND=$(grep -iE '(scsi|ide|sata)' "${VM_TO_RESTORE}/${VM_ORIG_VMX}" | grep -i fileName | awk -F " " '{print $1}')
            VM_FOLDER_NAME=$(echo "${VM_TO_RESTORE##*/}")

            # Default to original VM Display Name if custom name is not specified
            if [ -z ${RESTORE_VM_NAME} ]; then
                VM_DISPLAY_NAME=$(grep -i "displayName" "${VM_TO_RESTORE}/${VM_ORIG_VMX}" | awk -F '=' '{print $2}' | sed 's/"//g' | sed -e 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
                VM_ORIG_FOLDER_NAME=$(echo "${VM_FOLDER_NAME}" | sed 's/-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]_[0-1].*//g')
                VM_VMX_NAME=${VM_ORIG_VMX}
		VM_RESTORE_FOLDER_NAME=${VM_ORIG_FOLDER_NAME}
		VM_RESTORE_VMX=${VM_ORIG_VMX}
            else
                VM_DISPLAY_NAME=${RESTORE_VM_NAME}
                VM_RESTORE_FOLDER_NAME=${RESTORE_VM_NAME}
                VM_RESTORE_VMX=${RESTORE_VM_NAME}.vmx
            fi

            #figure out the VMDK rename, esepcially important if original backup had VMDKs spread across multiple datastores
            #restoration will not support that since I can't assume the original system will be availabl with same ds/etc.
            #files will be restored to single VMFS volume without disrupting original backup

            NUM_OF_VMDKS=0
            TMP_IFS=${IFS}
            IFS=${ORIG_IFS}
            for VMDK in ${VMDKS_FOUND}; do
                #extract the SCSI ID and use it to check for valid vmdk disk
                SCSI_ID=$(echo ${VMDK%%.*})
                grep -i "${SCSI_ID}.present" "${VM_TO_RESTORE}/${VM_ORIG_VMX}" | grep -i "true" > /dev/null 2>&1
                #if valid, then we use the vmdk file
                if [ $? -eq 0 ]; then
                    grep -i "${SCSI_ID}.deviceType" "${VM_TO_RESTORE}/${VM_ORIG_VMX}" | grep -i "scsi-hardDisk" > /dev/null 2>&1
                    #if we find the device type is of scsi-disk, then proceed
                    if [ $? -eq 0 ]; then
                        DISK=$(grep -i ${SCSI_ID}.fileName "${VM_TO_RESTORE}/${VM_ORIG_VMX}")
                    else
                        #if the deviceType is NULL for IDE which it is, thanks for the inconsistency VMware
                        #we'll do one more level of verification by checking to see if an ext. of .vmdk exists
                        #since we can not rely on the deviceType showing "ide-hardDisk"
                        grep -i ${SCSI_ID}.fileName "${VM_TO_RESTORE}/${VM_ORIG_VMX}" | grep -i ".vmdk" > /dev/null 2>&1
                        if [ $? -eq 0 ]; then
                            DISK=$(grep -i ${SCSI_ID}.fileName "${VM_TO_RESTORE}/${VM_ORIG_VMX}")
                        fi
                    fi

                    if [ "${DISK}" != "" ]; then 
                        SCSI_CONTROLLER=$(echo ${DISK} | awk -F '=' '{print $1}')
                        RENAME_DESTINATION_LINE_VMDK_DISK="${SCSI_CONTROLLER} = \"${VM_DISPLAY_NAME}-${NUM_OF_VMDKS}.vmdk\""
                        if [ -z "${VMDK_LIST_TO_MODIFY}" ]; then
                            VMDK_LIST_TO_MODIFY="${DISK},${RENAME_DESTINATION_LINE_VMDK_DISK}"
                        else
                            VMDK_LIST_TO_MODIFY="${VMDK_LIST_TO_MODIFY};${DISK},${RENAME_DESTINATION_LINE_VMDK_DISK}"
                        fi
                        DISK=''
                    fi
                fi
                NUM_OF_VMDKS=$((NUM_OF_VMDKS+1))
            done
            IFS=${TMP_IFS}
        else 
            logger "Support for .tgz not supported - \"${VM_TO_RESTORE}\" will not be backed up!"
            IS_TGZ=1
        fi

if [ ! "${IS_TGZ}" == "1" ]; then
    if [ "${DEVEL_MODE}" == "1" ]; then
        logger "\n################ DEBUG MODE ##############"
        logger "Virtual Machine: \"${VM_DISPLAY_NAME}\""
        logger "VM_ORIG_VMX: \"${VM_ORIG_VMX}\""
        logger "VM_ORG_FOLDER: \"${VM_FOLDER_NAME}\""
        logger "VM_RESTORE_VMX: \"${VM_RESTORE_VMX}\""
        logger "VM_RESTORE_FOLDER: \"${VM_RESTORE_FOLDER_NAME}\""
        logger "VMDK_LIST_TO_MODIFY:"
        OLD_IFS="${IFS}"
        IFS=";"
        for i in ${VMDK_LIST_TO_MODIFY}; do
            VMDK_1=$(echo $i | awk -F ',' '{print $1}')
            VMDK_2=$(echo $i | awk -F ',' '{print $2}')
            logger "${VMDK_1}"
            logger "${VMDK_2}"
        done
        unset IFS
        IFS="${OLD_IFS}"
        logger "##########################################\n"
    else
        #validates the datastore to restore is valid and available
        if [ ! -d "${DATASTORE_TO_RESTORE_TO}" ]; then
            logger "ERROR: Unable to verify datastore location: \"${DATASTORE_TO_RESTORE_TO}\"! Ensure this exists"
            #validates that all 4 required variables are defined before continuing 

        elif [[ -z "${VM_RESTORE_VMX}" ]] && [[ -z "${VM_VMDK_DESCRS}" ]] && [[ -z "${VM_DISPLAY_NAME}" ]] && [[ -z "${VM_RESTORE_FOLDER_NAME}" ]] ; then			     	    
            logger "ERROR: Unable to define all required variables: VM_RESTORE_VMX, VM_VMDK_DESCR and VM_DISPLAY_NAME!"	
            #validates that a directory with the same VM does not already exists

        elif [ -d "${DATASTORE_TO_RESTORE_TO}/${VM_RESTORE_FOLDER_NAME}" ]; then
            logger "ERROR: Directory \"${DATASTORE_TO_RESTORE_TO}/${VM_RESTORE_FOLDER_NAME}\" looks like it already exists, please check contents and remove directory before trying to restore!" 

        else		
            logger "################## Restoring VM: $VM_DISPLAY_NAME  #####################"
            if [ "${DEVEL_MODE}" == "2" ]; then
                logger "==========> DEBUG MODE LEVEL 2 ENABLED <=========="
            fi

            logger "Start time: $(date)"
            logger "Restoring VM from: \"${VM_TO_RESTORE}\""
            logger "Restoring VM to Datastore: \"${DATASTORE_TO_RESTORE_TO}\" using Disk Format: \"${FORMAT_STRING}\""

            VM_RESTORE_DIR="${DATASTORE_TO_RESTORE_TO}/${VM_RESTORE_FOLDER_NAME}"

            #create VM folder on datastore if it doesn't already exists
            logger "Creating VM directory: \"${VM_RESTORE_DIR}\" ..."
            if [ ! "${DEVEL_MODE}" == "2" ]; then	
                mkdir -p "${VM_RESTORE_DIR}"
            fi

            #copy .vmx file
            logger "Copying \"${VM_ORIG_VMX}\" file ..."
            if [ ! "${DEVEL_MODE}" == "2" ]; then
                cp "${VM_TO_RESTORE}/${VM_ORIG_VMX}" "${VM_RESTORE_DIR}/${VM_RESTORE_VMX}"
                sed -i "s/displayName =.*/displayName = \"${VM_DISPLAY_NAME}\"/g" "${VM_RESTORE_DIR}/${VM_RESTORE_VMX}"
            fi

            #loop through all VMDK(s) and vmkfstools copy to destination
            logger "Restoring VM's VMDK(s) ..."
            #MAX=${#ORIGINAL_VMX_VMDK_LINES[*]}

            OLD_IFS="${IFS}"
            IFS=";"
            for i in ${VMDK_LIST_TO_MODIFY}; do
                #retrieve individual VMDKs
                SOURCE_LINE_VMDK=$(echo "${i}" | awk -F ',' '{print $1}' | awk -F '=' '{print $2}' | sed 's/"//g' | sed -e 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
                DESTINATION_LINE_VMDK=$(echo "${i}" | awk -F ',' '{print $2}' | awk -F '=' '{print $2}' | sed 's/"//g' | sed -e 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
                #retrieve individual VMDK lines in .vmx file to update
                ORIGINAL_VMX_LINE=$(echo "${i}" | awk -F ',' '{print $1}')
                MODIFIED_VMX_LINE=$(echo "${i}" | awk -F ',' '{print $2}')

                #update restored VM to match VMDKs
                logger "Updating VMDK entry in \"${VM_RESTORE_VMX}\" file ..."
                if [ ! "${DEVEL_MODE}" == "2" ]; then
                    sed -i "s#${ORIGINAL_VMX_LINE}#${MODIFIED_VMX_LINE}#g" "${VM_RESTORE_DIR}/${VM_RESTORE_VMX}"
                fi

                echo "${SOURCE_LINE_VMDK}" | grep "/vmfs/volumes" > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                    #SOURCE_VMDK="${SOURCE_LINE_VMDK}"
                    DS_VMDK_PATH=$(echo "${SOURCE_LINE_VMDK}" | sed 's/\/vmfs\/volumes\///g')
                    VMDK_DATASTORE=$(echo "${DS_VMDK_PATH%%/*}")
                    VMDK_VM=$(echo "${DS_VMDK_PATH##*/}")
                    SOURCE_VMDK="${VM_TO_RESTORE}/${VMDK_DATASTORE}/${VMDK_VM}"
                else
                    SOURCE_VMDK="${VM_TO_RESTORE}/${SOURCE_LINE_VMDK}"
                fi
                DESTINATION_VMDK="${VM_RESTORE_DIR}/${DESTINATION_LINE_VMDK}"

                if [ ! "${DEVEL_MODE}" == "2" ]; then
                    ADAPTER_FORMAT=$(grep -i "ddb.adapterType" "${SOURCE_VMDK}" | awk -F "=" '{print $2}' | sed -e 's/^[[:blank:]]*//;s/[[:blank:]]*$//;s/"//g')

                    if [ ${RESTORE_DISK_FORMAT} -eq 1 ]; then
                        if [[ "${VER}" == "4" ]] || [[ "${VER}" == "5" ]] || [[ "${VER}" == "6" ]] ; then
                            ${VMKFSTOOLS_CMD} -i "${SOURCE_VMDK}" -a "${ADAPTER_FORMAT}" -d zeroedthick "${DESTINATION_VMDK}" 2>&1 | tee "${REDIRECT}"
                        else
                            ${VMKFSTOOLS_CMD} -i "${SOURCE_VMDK}" -a "${ADAPTER_FORMAT}" "${DESTINATION_VMDK}" 2>&1 | tee "${REDIRECT}"
                        fi

                    elif [ ${RESTORE_DISK_FORMAT} -eq 2 ]; then
                        ${VMKFSTOOLS_CMD} -i "${SOURCE_VMDK}" -a "${ADAPTER_FORMAT}" -d 2gbsparse "${DESTINATION_VMDK}" 2>&1 | tee "${REDIRECT}"

                    elif [ ${RESTORE_DISK_FORMAT} -eq 3 ]; then
                        ${VMKFSTOOLS_CMD} -i "${SOURCE_VMDK}" -a "${ADAPTER_FORMAT}" -d thin "${DESTINATION_VMDK}" 2>&1 | tee "${REDIRECT}"

                    elif [ ${RESTORE_DISK_FORMAT} -eq 4 ]; then
                        if [[ "${VER}" == "4" ]] || [[ "${VER}" == "5" ]] || [[ "${VER}" == "6" ]] ; then
                            ${VMKFSTOOLS_CMD} -i "${SOURCE_VMDK}" -a "${ADAPTER_FORMAT}" -d eagerzeroedthick "${DESTINATION_VMDK}" 2>&1 | tee "${REDIRECT}"
                        else
                            ${VMKFSTOOLS_CMD} -i "${SOURCE_VMDK}" -a "${ADAPTER_FORMAT}" "${DESTINATION_VMDK}" 2>&1 | tee "${REDIRECT}"
                        fi
                    fi
                else
                    logger "\nSOURCE: \"${SOURCE_VMDK}\""
                    logger "\tORIGINAL_VMX_LINE: -->${ORIGINAL_VMX_LINE}<--"
                    logger "DESTINATION: \"${DESTINATION_VMDK}\""
                    logger "\tMODIFIED_VMX_LINE: -->${MODIFIED_VMX_LINE}<--"
                fi
            done
            unset IFS
            IFS="${OLD_IFS}"				

            #register VM on ESX(i) host
            logger "Registering $VM_DISPLAY_NAME ..."

            if [ ! "${DEVEL_MODE}" == "2" ]; then
                ${VMWARE_CMD} solo/registervm "${VM_RESTORE_DIR}/${VM_RESTORE_VMX}"
            fi

            logger "End time: $(date)"
            logger "################## Completed restore for $VM_DISPLAY_NAME! #####################\n"
        fi
    fi
fi

VMDK_LIST_TO_MODIFY=''
    done
    unset IFS	

    endTimer
}

getVMIDs() {
    ${VMWARE_CMD} vmsvc/getallvms | sed 's/[[:blank:]]\{3,\}/   /g' | fgrep "[" | fgrep "vmx-" | fgrep ".vmx" | fgrep "/" | awk -F'   ' '{print ""$1""}' | sed '/^$/d'
}

getVMMACs() {
    MAC_LIST=
    for vmid in $(getVMIDs); do
        echo -n .
        FILE=$(${VMWARE_CMD} vmsvc/get.summary $vmid | grep -iF vmpathname | awk -F "\[" '{print "/vmfs/volumes/"$2}' | awk -F "] " '{print $1"/"$2}' | awk -F"\"" '{print $1}')
        MAC_LIST="${MAC_LIST}
"$(grep -iE '^\s*ethernet[0-9]+\..*address\s*=' "${FILE}" | awk -F "\"" '{print $2}')  #'
    done
}

ghettoVCBcheckPath() {
    if [[ -z "$2" ]] ; then
        if [[ -d "$1" ]] ; then
            echo ''
        else
            echo "DIRECTORY NOT EXISTS!"
        fi
    else
        if [[ -d "$1" ]] ; then
            if [[ -r "$1" ]] ; then
                echo ''
            else
                echo "FILE NOT EXISTS!"
            fi
        else
            if [[ -r "$1" ]] ; then
                echo "DIRECTORY NOT EXISTS!"
            else
                echo "DIRECTORY NOT EXISTS, FILE NOT EXISTS!"
            fi
        fi
    fi
}

ghettoVCBdiskDirs() {
    FILE_NO=0
    DIR_NO=0
    DISK_DIR=start
    DIRLIST=::
    while [[ -n "${DISK_DIR}" ]]
    do
        eval "DISK_DIR=\"\${SOURCE_VMDK__${FILE_NO}}\""
        [[ -z "${DISK_DIR}" ]] && break
        eval "DISK_DIR_VMDKNO=\"${FILE_NO}\""
        DISK_DIR="${DISK_DIR%/*}"
        echo -n "."
        if [[ -z "${DISK_DIR##/vmfs/volumes/*}" ]] && echo "${DIRLIST}" | grep -qvF "::${DISK_DIR}::" ; then
            DIRLIST="$DIRLIST${DISK_DIR}::"
            eval "DISK_DIR__${DIR_NO}=\"${DISK_DIR}\"; DISK_DIR_VMDKNO__${DIR_NO}=\"${DISK_DIR_VMDKNO}\"; DISK_NEW_DIR__${DIR_NO}=\"${DISK_DIR}\"; VMDK_DISK_DIR_NO__${FILE_NO}=\"${DIR_NO}\""
            let FILE_NO2=FILE_NO+1
            while true
            do
                eval "DISK_DIR2=\"\${SOURCE_VMDK__${FILE_NO2}}\""
                [[ -z "${DISK_DIR2}" ]] && break
                eval "DISK_DIR_VMDKNO=\"${FILE_NO2}\""
                DISK_DIR2="${DISK_DIR2%/*}"
                [[ "${DISK_DIR2}" = "${DISK_DIR}" ]] && eval "DISK_DIR_VMDKNO__${DIR_NO}=\"\${DISK_DIR_VMDKNO__${DIR_NO}}::${DISK_DIR_VMDKNO}\"; VMDK_DISK_DIR_NO__${FILE_NO2}=\"${DIR_NO}\""
                let FILE_NO2++
            done
            let DIR_NO++
        fi
        let FILE_NO++
    done
}

ghettoVCBcheckFiles() {
    CHECK_ERROR=
    while [[ 1 = 1 ]]
    do
        [[ ! -d "${VM_BACKUP_DIR}" ]] && CHECK_ERROR="$CHECK_ERROR${VM_BACKUP_DIR} NOT FOUND; " && break
        [[ ! -r "${VM_BACKUP_DIR}/${VMX_FILE}" ]] && CHECK_ERROR="$CHECK_ERROR${VMX_FILE} NOT FOUND; " && break
        [[ -n "${VMSD_FILE}" ]] && [[ ! -r "${VM_BACKUP_DIR}/${VMSD_FILE}" ]] && CHECK_ERROR="$CHECK_ERROR${VMSD_FILE} NOT FOUND; " && break
        [[ -n "${NVRM_FILE}" ]] && [[ ! -r "${VM_BACKUP_DIR}/${NVRM_FILE}" ]] && CHECK_ERROR="$CHECK_ERROR${NVRM_FILE} NOT FOUND; " && break

        FILE_NO=0
        FILE=start
        while [[ -n "$FILE" ]]
        do
            eval "FILE=\"\${VMSN_FILE__$FILE_NO}\""
            eval "COMPRESSION_EXT=\"\${VMSN_COMPRESSED__$FILE_NO}\""
            [[ -n "${COMPRESSION_EXT}" ]] && COMPRESSION_COPY="${COMPRESSION_EXT}" && COMPRESSION_EXT=".${COMPRESSION_EXT}"
            [[ -n "${FILE}" ]] && [[ ! -r "${VM_BACKUP_DIR}/${FILE}${COMPRESSION_EXT}" ]] && [[ ! -r "${VM_BACKUP_DIR}/${FILE}" ]] && CHECK_ERROR="$CHECK_ERROR${FILE} NOT FOUND; " && break
            let FILE_NO++
        done
        [[ -n "${FILE}" ]] && break

        FILE_NO=0
        FILE=start
        while [[ -n "$FILE" ]]
        do
            eval "FILE=\"\${DESTINATION_VMDK__$FILE_NO}\""
            eval "COMPRESSION_EXT=\"\${VMDK_COMPRESSED__$FILE_NO}\""
            [[ -n "${COMPRESSION_EXT}" ]] && COMPRESSION_FILE="${COMPRESSION_EXT}" && COMPRESSION_EXT=".${COMPRESSION_EXT}"
            [[ -n "${FILE}" ]] && [[ ! -r "${VM_BACKUP_DIR}/${FILE}${COMPRESSION_EXT}" ]] && [[ ! -r "${VM_BACKUP_DIR}/${FILE}" ]] && CHECK_ERROR="$CHECK_ERROR${FILE} NOT FOUND; " && break
            let FILE_NO++
        done
        [[ -n "${FILE}" ]] && break
        BKP_DIR_PROBLEM=
        return 0
    done
    BKP_DIR_PROBLEM="${CHECK_ERROR}"
}

fileUnCompr() {
    if [[ -n "${VM_UNCOMPR_FILE}" ]]; then
        COMPR_X_FILE="$1"
        eval "${VM_UNCOMPR_FILE}"
    fi
}

#if VM_COMPR set, we copy+uncompress
# $1 from -> $2 to
copyUnCompr() {
    if [[ -n "${VM_UNCOMPR_COPY}" ]]; then
        COMPR_X_FILE="$1"
        COMPR_X_DIR="$2"
        eval "${VM_UNCOMPR_COPY}"
    elif [[ -n "${VM_UNCOMPR_FILE}" ]]; then
        cp "$1" "$2"
        fileUnCompr "$2/${1##*/}"
    fi
    return $?
}

#find all extent and uncompress it
# VMDK_BACKUP_FILE -> VMDK_PATH/VMDK_FILE***.vmdk.lzo -> VMDK_PATH - - - >
vmdkUnCompr() {
    VMDK_FILE="${VMDK_BACKUP_FILE##*/}"
    VMDK_PATH="${VMDK_BACKUP_FILE%/*}"
#try catch all file for [name].vmdk
# [name]-flat.vmdk thick, thin?
# [name]-s###.vmdk 2gbsparse
# [name]-delta.vmdk snapshot sparse
# [name]-sesparse.vmdk snapshot sesparse
    FILE_LIST="$(find 2>/dev/null "${VMDK_PATH%/}/" -maxdepth 1 -name "${VMDK_FILE%.vmdk}-*.vmdk*" )"
    while [[ -n "${FILE_LIST}" ]]
    do
        FILE="$(echo "${FILE_LIST}" | head -1)"
        if echo "${FILE}" | grep -qiE -- '-(flat|s[0-9]+|delta|sesparse)\.vmdk.'"${VMDK_COMPRESSED}"'$'; then
            FILE1=$(echo "${FILE}" | sed -re 's/-(flat|s[0-9]+|delta|sesparse)\.vmdk.'"${VMDK_COMPRESSED}"'$//') #'
            if [[ "${FILE1##*/}" = "${VMDK_FILE%.vmdk}" ]] ; then
                logger "debug" "Uncompressing ${FILE}"
                if [[ -n "${VMDK_TEMP_PATH}" ]] ; then
                    VMDK_CMPR=${FILE##*/}
                    if [[ ! -f "${VMDK_TEMP_PATH}/${VMDK_CMPR%.*}" ]] ; then
                        logger "debug" "Uncompressing ${FILE} to ${VMDK_TEMP_PATH}"
                        copyUnCompr "${FILE}" "${VMDK_TEMP_PATH}"
                    else
                        logger "debug" "Already uncompressed ${FILE}"
                    fi
                else
                    if [[ ! -f "${FILE%.*}" ]] ; then
                        logger "debug" "Uncompressing ${FILE}"
                        copyUnCompr "${FILE}" "${VMDK_PATH}"
                    else
                        logger "debug" "Already uncompressed ${FILE%.*}"
                    fi
                fi
            fi
#        elif echo "${VMDK_FILE}" | grep -qiE -- '-(flat|s[0-9]+|delta|sesparse)\.vmdk$' ; then
#            logger "debug" "Already uncompressed ${VMDK_FILE}"
        fi
        FILE_LIST="$(echo "${FILE_LIST}" | sed -re '1d')"
    done
    [[ -n "${VMDK_TEMP_PATH}" ]] && cp "${VMDK_BACKUP_FILE}" "${VMDK_TEMP_PATH}"
}

vmdkCleanUnCompr() {
    VMDK_FILE="${VMDK_BACKUP_FILE##*/}"
    VMDK_PATH="${VMDK_BACKUP_FILE%/*}"
#try catch all file for [name].vmdk
# [name]-flat.vmdk thick, thin?
# [name]-s###.vmdk 2gbsparse
# [name]-delta.vmdk snapshot sparse
# [name]-sesparse.vmdk snapshot sesparse
    FILE_LIST="$(find 2>/dev/null "${VMDK_PATH%/}/" -maxdepth 1 -name "${VMDK_FILE%.vmdk}-*.vmdk*" )"
    while [[ -n "${FILE_LIST}" ]]
    do
        FILE="$(echo "${FILE_LIST}" | head -1)"
        if echo "${FILE}" | grep -qiE -- '-(flat|s[0-9]+|delta|sesparse)\.vmdk.'"${VMDK_COMPRESSED}"'$'; then
            FILE1=$(echo "${FILE}" | sed -re 's/-(flat|s[0-9]+|delta|sesparse)\.vmdk.'"${VMDK_COMPRESSED}"'$//') #'
            if [[ "${FILE1##*/}" = "${VMDK_FILE%.vmdk}" ]] ; then
                FILE="${FILE%.*}"
                if [[ -n "${VMDK_TEMP_PATH}" ]] ; then
                    if [[ -f "${VMDK_TEMP_PATH}/${FILE##*/}" ]] ; then
                        logger "debug" "Remove Uncompressed file ${VMDK_TEMP_PATH}/${FILE##*/}"
                        rm "${VMDK_TEMP_PATH}/${FILE##*/}"
                    fi
                else
                    if [[ -f "${FILE}" ]] ; then
                        logger "debug" "Remove Uncompressed file ${FILE}"
                        rm "${FILE}"
                    fi
                fi
            fi
        fi
        FILE_LIST="$(echo "${FILE_LIST}" | sed -re '1d')"
    done
    [[ -n "${VMDK_TEMP_PATH}" ]] && rm "${VMDK_TEMP_PATH}/${VMDK_BACKUP_FILE##*/}"
}

checkUnCompr() {
    WORKDIR=/tmp/ghettoVCB-restore-$$
    UNCOMPRESSION_CMD_COPY=
    VM_UNCOMPR_COPY=
    UNCOMPRESSION_CMD_FILE=
    VM_UNCOMPR_FILE=
    # we try to compress/uncompress
    # we test
    mkdir -p "${WORKDIR}"
    if [[ -n "${COMPRESSION_CMD_COPY}" ]]; then
#we assume -d option to "decompress" lzop/gzip/bzip2/xz use this
        VM_COMPR_COPY="$(echo "${COMPRESSION_CMD_COPY}" | sed -re 's/%f/\"\${COMPR_X_FILE}\"/g; s/%d/\"\${COMPR_X_DIR}\"/g')"
        UNCOMPRESSION_CMD_COPY="$(echo "${COMPRESSION_CMD_COPY}" | sed -re 's/(^[^ \t]+ )/\1-d /')"
        VM_UNCOMPR_COPY="$(echo "${UNCOMPRESSION_CMD_COPY}" | sed -re 's/%f/\"\${COMPR_X_FILE}\"/g; s/%d/\"\${COMPR_X_DIR}\"/g')"
        echo "Compression Test File." >"${WORKDIR}/cmpr.txt"
        mkdir "${WORKDIR}/comprtest"
        COMPR_X_FILE="${WORKDIR}/cmpr.txt"
        COMPR_X_DIR="${WORKDIR}/comprtest"
        eval "${VM_COMPR_COPY}"
        COMPR_X_FILE=$(ls "${WORKDIR}/comprtest")
        [[ -f "${WORKDIR}/cmpr.txt" ]] && [[ -f "${WORKDIR}/comprtest/${COMPR_X_FILE}" ]] && COMPRESSION_EXT_COPY="${COMPR_X_FILE##*.}"
        if [[ "${COMPRESSION_COPY}" != "${COMPRESSION_EXT_COPY}" ]] || ! echo "${COMPRESSION_EXT_COPY}" | grep -qiE '(lzo|gz|bz2|lzma|zip|7z)'; then
#            COMPRESSION_CMD_COPY=
            VM_UNCOMPR_COPY=
            COMPRESSION_EXT_COPY=
#check working uncompress
        else
            rm "${WORKDIR}/cmpr.txt"
            copyUnCompr "${WORKDIR}/comprtest/${COMPR_X_FILE}" "${WORKDIR}"
            if [[ ! -f "${COMPR_X_FILE}" ]] || [[ ! -f "${WORKDIR}/cmpr.txt" ]] ; then
#                COMPRESSION_CMD_COPY=
                VM_UNCOMPR_COPY=
                COMPRESSION_EXT_COPY=
            fi
        fi
    fi
    if [[ -n "${COMPRESSION_CMD_FILE}" ]]; then
        VM_COMPR_FILE="$(echo "${COMPRESSION_CMD_FILE}" | sed -re 's/%f/\"${COMPR_X_FILE}\"/g')"
        UNCOMPRESSION_CMD_FILE="$(echo "${COMPRESSION_CMD_FILE}" | sed -re 's/(^[^ \t]+ )/\1-d /')"
        VM_UNCOMPR_FILE="$(echo "${UNCOMPRESSION_CMD_FILE}" | sed -re 's/%f/\"${COMPR_X_FILE}\"/g')"
        mkdir "${WORKDIR}/comprtest2"
        echo "Compression Test File." >"${WORKDIR}/comprtest2/cmpr.txt"
        COMPR_X_FILE="${WORKDIR}/comprtest2/cmpr.txt"
        eval "${VM_COMPR_FILE}"
        [[ ! -f "${WORKDIR}/comprtest2/cmpr.txt" ]] && COMPR_X_FILE=$(ls "${WORKDIR}/comprtest2") && COMPRESSION_EXT_FILE="${COMPR_X_FILE##*.}"
        if [[ "${COMPRESSION_FILE}" != "${COMPRESSION_EXT_FILE}" ]] || ! echo "${COMPRESSION_EXT_FILE}" | grep -qiE '(lzo|gz|bz2|lzma|zip|7z)'; then
#            COMPRESSION_CMD_FILE=
            VM_UNCOMPR_FILE=
            COMPRESSION_EXT_FILE=
        else
            fileUnCompr "${WORKDIR}/comprtest2/cmpr.txt.${COMPRESSION_EXT_FILE}"
            if [[ ! -f "${WORKDIR}/comprtest2/cmpr.txt" ]] || [[ -f "${WORKDIR}/comprtest2/cmpr.txt.${COMPRESSION_EXT_FILE}" ]] ; then
#                COMPRESSION_CMD_FILE=
                VM_UNCOMPR_FILE=
                COMPRESSION_EXT_FILE=
            fi
        fi
    fi
    rm -r "${WORKDIR}"
}

ghettoVCBinteractive() {

    NFS_VERSION=4
    NFS_UMOUNT=0
    OLDDIR=$(pwd)
    echo  "###############################################################################"
    echo  "#"
    echo  "# ghettoVCB for ESX/ESXi 3.5, 4.x+, 5.x, 6.x, & 7.x"
    echo  "# Author: William Lam"
    echo  "# http://www.virtuallyghetto.com/"
    echo  "# Documentation: http://communities.vmware.com/docs/DOC-8760"
    echo  "# Created: 11/17/2008"
    echo  "# Last modified: ${LAST_MODIFIED_DATE} Version ${VERSION}"
    echo  "#"

    while [[ ! -r ghettovcb-restore.conf ]]
    do
        echo  "###############################################################################"
        echo  "#"
        echo  "# RESTORE_CONFIG_DIR=\"$(pwd)\""
        echo  "# There is no any readable ghettovcb-restore.conf file"
        echo  "#"
        echo -n "Mount NFS*/(S)elect other directory/(C)ancel > "
        read
        if [[ "$REPLY" = c ]] || [[ "$REPLY" = C ]] ; then
            echo  "#"
            echo  "# RESTORE OPERATION CANCELED!!!"
            echo  "#"
            exit 0
        elif [[ "$REPLY" = s ]] || [[ "$REPLY" = S ]] ; then
            echo  -n "#INFO '~' expanded to /vmfs/volumes/"
            echo  -n "RESTORE_CONFIG_DIR=[$(pwd)]="
            read
            REPLY=$(echo "$REPLY" | sed -re 's!~!/vmfs/volumes/!; s!//+!/!g')
            [[ -n "$REPLY" ]] && [[ -d "${REPLY}" ]] && cd "${REPLY}"
            RESTORE_CONFIG_DIR="$(pwd)"
        else
            while true
            do
                echo  -n "NFS_SERVER=[$NFS_SERVER]="
                read
                [[ -n "$REPLY" ]] && ping -c 3 "${REPLY}" >/dev/null 2>&1 && NFS_SERVER="${REPLY}"
                echo  "#INFO 3: nfsv3, 4:nfsv4.1"
                echo  -n "NFS_VERSION=[${NFS_VERSION}]="
                read
                [[ -n "$REPLY" ]] && echo "$REPLY" | grep -qE '(3|4)' && NFS_VERSION="${REPLY}"
                echo  "#INFO export path on server e.g.: /exports/backup"
                echo  -n "NFS_MOUNT=[$NFS_MOUNT]="
                read
                [[ -n "$REPLY" ]] && NFS_MOUNT="${REPLY}"
                echo  -n "NFS_LOCAL_NAME=[$NFS_LOCAL_NAME]="
                read
                [[ -n "$REPLY" ]] && NFS_LOCAL_NAME="${REPLY}"
                echo  -n "NFS_VM_BACKUP_PATH=[$NFS_VM_BACKUP_PATH]="
                read
                [[ -n "$REPLY" ]] && NFS_VM_BACKUP_PATH="${REPLY}"
                [[ -n "${NFS_VM_BACKUP_PATH}" ]] && [[ -n "${NFS_LOCAL_NAME}" ]] && [[ -n "${NFS_MOUNT}" ]] && [[ -n "${NFS_VERSION}" ]] && [[ -n "${NFS_SERVER}" ]] && break
                echo  "#"
                echo  "#INFO Some parameter missing!"
                echo  "#"
                echo -n "Redo*/(C)ancel > "
                read
                if [[ "$REPLY" = c ]] || [[ "$REPLY" = C ]] ; then
                    break
                fi
            done
            if [[ -n "${NFS_VM_BACKUP_PATH}" ]] && [[ -n "${NFS_LOCAL_NAME}" ]] && [[ -n "${NFS_MOUNT}" ]] && [[ -n "${NFS_VERSION}" ]] && [[ -n "${NFS_SERVER}" ]] ; then
                logger "debug" "Mounting NFS: ${NFS_SERVER}:${NFS_MOUNT} to /vmfs/volume/${NFS_LOCAL_NAME}"
                NFS_VER=nfs
                [[ "${NFS_VERSION}" = 4 ]] && NFS_VER=nfs41
                if [[ ${ESX_RELEASE} == "5.5.0" ]] || [[ ${ESX_RELEASE} == "6.0.0" || ${ESX_RELEASE} == "6.5.0" || ${ESX_RELEASE} == "6.7.0" || ${ESX_RELEASE} == "7.0.0" ]] ; then
                    ${VMWARE_CMD} hostsvc/datastore/nas_create "${NFS_LOCAL_NAME}" "${NFS_VER}" "${NFS_MOUNT}" 0 "${NFS_SERVER}" && NFS_UMOUNT=1
                else
                    ${VMWARE_CMD} hostsvc/datastore/nas_create "${NFS_LOCAL_NAME}" "${NFS_SERVER}" "${NFS_MOUNT}" 0 && NFS_UMOUNT=1
                fi
            fi
            [[ -d "/vmfs/volume/${NFS_LOCAL_NAME}/${NFS_VM_BACKUP_PATH}" ]] && cd "/vmfs/volume/${NFS_LOCAL_NAME}/${NFS_VM_BACKUP_PATH}" && RESTORE_CONFIG_DIR=$(pwd)
        fi
    done

    DISK_RESTORE_FORMAT=thin
    DISK_SNAPSHOT_RESTORE_FORMAT=original
    VM_MAC_REGENERATE=2
    VM_RESTORE_TO_NONEMPTY_DIR=0

    eval "$(grep '^#VAR: ' ghettovcb-restore.conf | sed -re 's/#VAR: //; /".*\$.*"$/ {s/\$/\\$/g}')"
    echo  -n "### Scanning existing VM UUIDs "
    UUID_BIOS=$(echo "${VM_UUID}" | sed -re 's/[- ]//g')
    for vmid in $(getVMIDs); do echo -n "."; [[ "$(${VMWARE_CMD} vmsvc/get.config "$vmid" | grep uuid | awk -F "\"" '{print $2}' | sed -re 's/[- ]//g')" = "${UUID_BIOS}" ]] && VM_UUID_EXISTS="UUID EXISTS!"; done
    echo
    echo  -n "### Scanning existing MAC addresses"
    getVMMACs
    echo
    echo  -n "### Scanning backed up disk path "
    ghettoVCBdiskDirs
    echo
    echo  "# restore configuration"
    echo  "#"
    REPLY=
    while [[ -z "$REPLY" ]] || [[ "$REPLY" = M ]] || [[ "$REPLY" = m ]]
    do
        CFG_PROBLEM=
        VM_REGISTERED=
        VM_RESTORE_DIR_EXISTS=
        COMPRESSION_COPY=
        COMPRESSION_FILE=
        #check VM already registered?
        [[ ${VM_REGISTER} -eq 1 ]] && ${VMWARE_CMD} vmsvc/getallvms | sed 's/[[:blank:]]\{3,\}/   /g' | fgrep "[" | fgrep "vmx-" | fgrep ".vmx" | fgrep "/" | awk -F'   ' '{print ""$2""}' | sed '/^$/d' | grep -qiE "^${VM_NAME}\$" && VM_REGISTERED="REGISTERD!"

        [[ ${VM_RESTORE_TO_NONEMPTY_DIR} -ne 1 ]] && [[ -d "${VM_RESTORE_DIR}" ]] && [[ $(ls 2>/dev/null "${VM_RESTORE_DIR}" | wc -l ) -gt 0 ]] && VM_RESTORE_DIR_EXISTS="VM RESTORE DIR NOT EMPTY!"
        if [[ -z "${VM_NAME}" ]] || [[ -n "${VM_REGISTERED}" ]] || [[ -n "$VM_RESTORE_DIR_EXISTS" ]] ; then
            CFG_PROBLEM=1
        fi
        MAC_DUPLICATE=
        for mac in $(grep 2>/dev/null -iE '^\s*ethernet[0-9]+\..*address\s*=' "${VM_BACKUP_DIR}/${VMX_FILE}" | awk -F "\"" '{print $2}')
        do
            echo "${MAC_LIST}" | grep -qF "$mac" && MAC_DUPLICATE="MAC ADDRESS EXISTS!"
        done

        ghettoVCBcheckFiles
        checkUnCompr
        echo  "###############################################################################"
        echo  "# VM_NAME=\"${VM_NAME}\""  $VM_REGISTERED
        echo  "# VM_UUID=\"${VM_UUID}\" $VM_UUID_EXISTS"
        echo  "# VM_RESTORE_DIR=\"${VM_RESTORE_DIR}\""  $VM_RESTORE_DIR_EXISTS
        echo  -e "\n#INFO: thin|zeroedthick|eagerzeroedthick|thick"
        echo  "# DISK_RESTORE_FORMAT=\"${DISK_RESTORE_FORMAT}\""
        echo  -e "\n#INFO: thin|zeroedthick|eagerzeroedthick|thick|sesparse|original"
        echo  "# DISK_SNAPSHOT_RESTORE_FORMAT=\"${DISK_SNAPSHOT_RESTORE_FORMAT}\""
        n=0
        [[ -n "${DISK_DIR__0}" ]] && echo -e "\n#INFO: There is (at least) a disk out of the VM directory"
        while [[ -n "${DISK_DIR__0}" ]]
        do
            DISK_DIR_EXISTS=
            eval "DISK_DIR=\"\${DISK_NEW_DIR__$n}\""
            [[ -z "${DISK_DIR}" ]] && break
            [[ ${VM_RESTORE_TO_NONEMPTY_DIR} -ne 1 ]] && [[ -d "${DISK_DIR}" ]] && [[ $(ls 2>/dev/null "${DISK_DIR}" | wc -l ) -gt 0 ]] && DISK_DIR_EXISTS="RESTORE DISK DIR NOT EMPTY!" && CFG_PROBLEM=1
            echo  "# DISK_DIR__$n=\"${DISK_DIR}\"  $DISK_DIR_EXISTS"
            let n++
        done
        echo  "# VM_BACKUP_DIR=\"${VM_BACKUP_DIR}\""
        echo  "# VM_RESTORE_TO_NONEMPTY_DIR=\"${VM_RESTORE_TO_NONEMPTY_DIR}\""
        echo  "# VM_REGISTER=\"${VM_REGISTER}\""
        echo  -e "\n#INFO: 0|1|2  2 - if register VM an DUP"
        echo  "# VM_MAC_REGENERATE=${VM_MAC_REGENERATE}  $MAC_DUPLICATE"
        echo  "# VMX_FILE=\"${VMX_FILE}\""
        echo  "# VMSD_FILE=\"${VMSD_FILE}\""
        echo  "# NVRM_FILE=\"${NVRM_FILE}\""
        if [[ -n "${COMPRESSION_COPY}" ]] ; then
            echo -e "\n#INFO: compressed VMNS files"
            echo  "# UNCOMPRESSION_CMD_COPY=\"${UNCOMPRESSION_CMD_COPY}\""
        fi
        if [[ -n "${COMPRESSION_FILE}" ]] ; then
            echo  -e "\n#INFO: compressed VMDK files"
            echo  "# UNCOMPRESSION_CMD_FILE=\"${UNCOMPRESSION_CMD_FILE}\""
        fi
        echo  "# VM_SNAPSHOT_MEMORY=\"${VM_SNAPSHOT_MEMORY}\""
        if [[ -n "${LIVE_VM_BACKUP_SNAPSHOT_ID}" ]] ; then
            echo  "# LIVE_VM_BACKUP_SNAPSHOT_ID=\"${LIVE_VM_BACKUP_SNAPSHOT_ID}\""
        fi
        echo  "###############################################################################"
        [[ -n "${BKP_DIR_PROBLEM}" ]] && echo "# BACKUP_DIR_PROBLEM: ${BKP_DIR_PROBLEM}"
        if [[ -n "${CFG_PROBLEM}" ]] || [[ -n "${BKP_DIR_PROBLEM}" ]] ; then
            echo  "# CANNOT RESTORE: PLEASE REVIEW CONFIG!"
            echo -n "Modify*/(S)how DISKs/(C)ancel > "
        else
            echo -n "(R)estore/Modify*/(S)how DISKs/(C)ancel > "
        fi
        read
        if [[ "$REPLY" = c ]] || [[ "$REPLY" = C ]] ; then
            echo  "#"
            echo  "# RESTORE OPERATION CANCELED!!!"
            echo  "#"
            exit 0
        fi
        [[ -z "${CFG_PROBLEM}" ]] && if [[ "$REPLY" = r ]] || [[ "$REPLY" = R ]] ; then
            break
        fi

        #show disks
        if [[ "$REPLY" = s ]] || [[ "$REPLY" = S ]] ; then
            echo  "#"
            echo  "# List of VMDKs (DISKS)"
            echo  "#"
            n=0
            show_mod=
            while true
            do
                eval "VMDK=\"\${SOURCE_VMDK__$n}\""
                [[ -z "${VMDK}" ]] && break
                echo "SOURCE_VMDK__$n=\"${VMDK}\""
                [[ -z "${VMDK##/vmfs/volumes/*}" ]] && show_mod=1
                let n++
            done
            if [[ -n "${show_mod}" ]] ; then
                echo -n "Back*/(M)odify > "
            else
                echo -n "Back* > "
            fi
            read
            [[ -z "${show_mod}" ]] && continue
            [[ "$REPLY" != M ]] && [[ "$REPLY" != m ]] && continue
            #Modify
            n=0
            while true
            do
                eval "VMDK=\"\${SOURCE_VMDK__$n}\""
                [[ -z "${VMDK}" ]] && break
                echo -n "SOURCE_VMDK__$n[${VMDK}]="
                read
                [[ -n "$REPLY" ]] && echo "$REPLY" | grep -qvE '[[:cntrl:]]' && eval "SOURCE_VMDK__$n=\"${REPLY}\""
                let n++
            done
            REPLY=$(echo "$REPLY" | sed -re 's!~!/vmfs/volumes/!')
            [[ -n "$REPLY" ]] && eval "DISK_DIR__$n=\"${REPLY}\""
            continue
        fi

        #Modify
        echo  -n "VM_NAME[${VM_NAME}]="
        read
        [[ -n "$REPLY" ]] && VM_NAME="${REPLY}"
        echo  -e "\n#INFO: *:${RESTORE_CONFIG_DIR}"
        echo  -n "VM_BACKUP_DIR[${VM_BACKUP_DIR}]="
        read
        REPLY=$(echo "$REPLY" | sed -re 's!~!/vmfs/volumes/!; s!//+!/!g' | awk -vstar="${RESTORE_CONFIG_DIR}" '{gsub(/^\*/, star); print}') #'
        [[ -n "$REPLY" ]] && echo "$REPLY" | grep -qvE '[[:cntrl:]]' && VM_BACKUP_DIR="${REPLY}"
        [[ "$VM_BACKUP_DIR" = '*' ]] && VM_BACKUP_DIR="${RESTORE_CONFIG_DIR}"


        TMP_DIR="${VM_RESTORE_DIR%/*}/${VM_NAME}"
        echo  -e "\n#INFO: *:${TMP_DIR}"
        echo  -n "VM_RESTORE_DIR[${VM_RESTORE_DIR}]="
        read
        REPLY=$(echo "$REPLY" | sed -re 's!~!/vmfs/volumes/!; s!//+!/!g' | awk -vstar="${TMP_DIR}" '{gsub(/^\*/, star); print}') #'
        [[ -n "$REPLY" ]] && echo "$REPLY" | grep -qvE '[[:cntrl:]]' && VM_RESTORE_DIR="${REPLY}"
        [[ "$VM_RESTORE_DIR" = '*' ]] && VM_RESTORE_DIR="${TMP_DIR}"

        n=0
        while [[ -n "${DISK_DIR__0}" ]]
        do
            eval "DISK_DIR=\"\${DISK_DIR__$n}\""
            eval "DISK_NEW_DIR=\"\${DISK_NEW_DIR__$n}\""
            [[ -z "${DISK_DIR}" ]] && break
            echo  -e "\n#INFO: *:${DISK_DIR}"
            echo -n "DISK_DIR__$n[${DISK_NEW_DIR}]="
            read
            REPLY=$(echo "$REPLY" | sed -re 's!~!/vmfs/volumes/!; s!//+!/!g' | awk -vstar="${DISK_DIR}" '{gsub(/^\*/, star); print}') #'
            [[ -n "$REPLY" ]] && echo "$REPLY" | grep -qvE '[[:cntrl:]]' && eval "DISK_NEW_DIR__$n=\"\${REPLY}\""
            [[ "$DISK_NEW_DIR" = '*' ]] && eval "DISK_NEW_DIR__$n=\"\${DISK_DIR}\""
            let n++
        done

        echo  -n "DISK_RESTORE_FORMAT[${DISK_RESTORE_FORMAT}]="
        read
        [[ -n "$REPLY" ]] && echo "${REPLY}" | grep -qiE "^(thin|zeroedthick|eagerzeroedthick|thick)$" && DISK_RESTORE_FORMAT="${REPLY}"

        echo  -n "DISK_SNAPSHOT_RESTORE_FORMAT[${DISK_SNAPSHOT_RESTORE_FORMAT}]="
        read
        [[ -n "$REPLY" ]] && echo "${REPLY}" | grep -qiE "^(thin|zeroedthick|eagerzeroedthick|thick|sesparse|original)$" && DISK_SNAPSHOT_RESTORE_FORMAT="${REPLY}"

        echo  -n "VM_RESTORE_TO_NONEMPTY_DIR[${VM_RESTORE_TO_NONEMPTY_DIR}]="
        read
        [[ -n "$REPLY" ]] && echo "${REPLY}" | grep -qiE "^(0|1)$" && VM_RESTORE_TO_NONEMPTY_DIR="${REPLY}"

        echo  -n "VM_REGISTER[${VM_REGISTER}]="
        read
        [[ -n "$REPLY" ]] && echo "${REPLY}" | grep -qiE "^(0|1)$" && VM_REGISTER="${REPLY}"

        echo  -n "VM_MAC_REGENERATE[${VM_MAC_REGENERATE}]="
        read
        [[ -n "$REPLY" ]] && echo "${REPLY}" | grep -qiE "^(0|1)$" && VM_MAC_REGENERATE="${REPLY}"

        REPLY=
    done
    #START TO RESTORE

    startTimer

    [[ "$REPLY" != r ]] && [[ "$REPLY" != R ]] && exit 1

    logger "################## Restoring VM: $VM_DISPLAY_NAME  #####################"
    logger "Start time: $(date)"
    logger "Restoring VM from: \"${VM_BACKUP_DIR}\""
    logger "Restoring VM to: \"${VM_RESTORE_DIR}\" using Disk Format: \"${DISK_RESTORE_FORMAT}\""
    #create VM folder on datastore if it doesn't already exists
    logger "Creating VM directory: \"${VM_RESTORE_DIR}\" ..."
    mkdir -p "${VM_RESTORE_DIR}"

    #copy .vmx file
    logger "Copying \"${VMX_FILE}\" file ..."
    cp "${VM_BACKUP_DIR}/${VMX_FILE}" "${VM_RESTORE_DIR}/${VMX_FILE}"
#    sed -i "s/displayName =.*/displayName = \"${VM_DISPLAY_NAME}\"/g" "${VM_RESTORE_DIR}/${VM_RESTORE_VMX}"
    #copy .vmsd file
    if [[ -n "${VMSD_FILE}" ]] ; then
        logger "Copying \"${VMSD_FILE}\" file ..."
        cp "${VM_BACKUP_DIR}/${VMSD_FILE}" "${VM_RESTORE_DIR}/${VMSD_FILE}"
    fi
    #copy .nvrm file
    if [[ -n "${NVRM_FILE}" ]] ; then
        logger "Copying \"${NVRM_FILE}\" file ..."
        cp "${VM_BACKUP_DIR}/${NVRM_FILE}" "${VM_RESTORE_DIR}/${NVRM_FILE}"
    fi
    n=0
    while [[ -n "${VMSN_FILE__0}" ]]; do
        eval "VMSN_FILE=\"\${VMSN_FILE__$n}\""
        eval "VMSN_COMPRESSED=\"\${VMSN_COMPRESSED__$n}\""
        [[ -z "${VMSN_FILE}" ]] && break
        logger "Copying \"${VMSN_FILE}\" file ..."
        if [[ -n "${VMSN_COMPRESSED}" ]] && [[ -r "${VM_BACKUP_DIR}/${VMSN_FILE}.${VMSN_COMPRESSED}" ]] ; then
            copyUnCompr "${VM_BACKUP_DIR}/${VMSN_FILE}.${VMSN_COMPRESSED}" "${VM_RESTORE_DIR}" || VMSN_RESTORE_ERROR="${VMSN_RESTORE_ERROR}Cannot uncompress restore: ${VMSN_FILE}.${VMSN_COMPRESSED}"$'\n'
        else
            cp "${VM_BACKUP_DIR}/${VMSN_FILE}" "${VM_RESTORE_DIR}/${VMSN_FILE}" || VMSN_RESTORE_ERROR="${VMSN_RESTORE_ERROR}Cannot restore: ${VMSN_FILE}"$'\n'
        fi
        let n++
    done
    #create additional disk directories
    n=0
    while [[ -n "${DISK_NEW_DIR__0}" ]]
    do
        eval "DISK_DIR=\"\${DISK_NEW_DIR__$n}\""
        [[ -z "${DISK_DIR}" ]] && break
        logger "Creating additional VMDK directory: \"${DISK_DIR}\" ..."
        mkdir -p "${DISK_DIR}"
        let n++
    done

    #loop through all VMDK(s) and vmkfstools copy to destination
    logger "Restoring VM's VMDK(s) ..."
    DIR_NO=0
    n=0
    while [[ -n "${SOURCE_VMDK__0}" ]]
    do
        eval "VMDK=\"\${SOURCE_VMDK__$n}\""
        [[ -z "${VMDK}" ]] && break
        #by default
        VMDK_RESTORE_DIR=${VM_RESTORE_DIR}
        echo "${VMDK}" | grep -q "^/vmfs/volumes/" && eval "VMDK_DISK_DIR_NO=\"\${VMDK_DISK_DIR_NO__$n}\"" && eval "VMDK_RESTORE_DIR=\"\${DISK_NEW_DIR__${VMDK_DISK_DIR_NO}}\"; let DIR_NO++"
        VMDK="${VMDK_RESTORE_DIR}/${VMDK##*/}"
        eval "DESTINATION_VMDK=\"\${DESTINATION_VMDK__$n}\""
        eval "ADAPTER_FORMAT=\"\${ADAPTER_FORMAT__$n}\""
        eval "VMDK_RID=\"\${VMDK_RID__$n}\""
        eval "VMDK_COMPRESSED=\"\${VMDK_COMPRESSED__$n}\""
        eval "SOURCE_VMDK_TYPE=\"\${SOURCE_VMDK_TYPE__$n}\""
        [[ ${SOURCE_VMDK_TYPE} = vmfs ]] && SOURCE_VMDK_TYPE=thin
        if [[ -z "${VMDK_RID##snapshot*}" ]] ; then
            if [[ ${DISK_SNAPSHOT_RESTORE_FORMAT} = original ]] ; then
                RESTORE_FORMAT=${SOURCE_VMDK_TYPE}
            else
                RESTORE_FORMAT=${DISK_SNAPSHOT_RESTORE_FORMAT}
            fi
        else
            if [[ ${DISK_RESTORE_FORMAT} = original ]] ; then
                RESTORE_FORMAT=${SOURCE_VMDK_TYPE}
            else
                RESTORE_FORMAT=${DISK_RESTORE_FORMAT}
            fi
        fi
#try to uncompress vmdk
        VMDK_BACKUP_FILE="${VM_BACKUP_DIR}/${DESTINATION_VMDK}"

        vmdkUnCompr
#uncompressed files now in ${VM_BACKUP_DIR} or in ${VMDK_TEMP_PATH}
        [[ -n "${VMDK_TEMP_PATH}" ]] && VMDK_BACKUP_FILE="${VM_TEMP_PATH}/${DESTINATION_VMDK##*/}"
        logger "Restoring VMDK: \"${VMDK}\" ..."
        logger "debug:" "${VMKFSTOOLS_CMD} -i \"${VMDK_BACKUP_FILE}\" \"${ADAPTER_FORMAT}\" -d ${DISK_RESTORE_FORMAT} \"${VMDK}\""
#        eval "${VMKFSTOOLS_CMD} -i '$(echo "${DESTINATION_VMDK}" | sed -re "s/'/'\"'\"'/g")' ${ADAPTER_FORMAT} -d ${RESTORE_FORMAT} '$(echo "${VMDK}" | sed -re "s/'/'\"'\"'/g")' 2>&1" | tee "${REDIRECT}"
        eval "${VMKFSTOOLS_CMD} -i \"\${VMDK_BACKUP_FILE}\" ${ADAPTER_FORMAT} -d ${RESTORE_FORMAT} \"\${VMDK}\" 2>&1" | tee "${REDIRECT}"
        VMDK_BACKUP_FILE="${VM_BACKUP_DIR}/${DESTINATION_VMDK}"
        vmdkCleanUnCompr

        let n++
    done

    if [[ -n "${DISK_DIR__0}" ]] ; then
        logger "Fixing off-dir VMDK paths for \"${VM_NAME}\" ..."
        n=0
        while [[ -n "${DISK_DIR__0}" ]]
        do
            eval "DISK_DIR=\"\${DISK_DIR__$n}\""
            [[ -z "${DISK_DIR}" ]] && break
            eval "DISK_NEW_DIR=\"\${DISK_NEW_DIR__$n}\""
            if [[ "${DISK_DIR}" != "${DISK_NEW_DIR}" ]] ; then
                eval "DISK_DIR_VMDKNO=\"\${DISK_DIR_VMDKNO__$n}\""
                for vmdk_no in $(echo "${DISK_DIR_VMDKNO}" | sed -re 's/::/\n/' | sed -re '/^$/ d')
                do
                    eval "VMDK_RID=\"\${VMDK_RID__${vmdk_no}}\""
                    eval "VMDK=\"\${SOURCE_VMDK__${vmdk_no}}\""
                    VMDK="${DISK_NEW_DIR}/${VMDK##*/}"
                    if [[ -z "${VMDK_RID##snapshot*}" ]] ; then
                        VM_CFG_FILE="${VM_RESTORE_DIR}/${VMSD_FILE}"
                    else
                        VM_CFG_FILE="${VM_RESTORE_DIR}/${VMX_FILE}"
                    fi
                    FILE_NAME="${VMDK_RID}.fileName = \"${VMDK}\""
                    awk -vfn="${FILE_NAME}" '/^'"${VMDK_RID}"'\.fileName/i {$0 = fn}; {print}' "${VM_CFG_FILE}" >"${VM_CFG_FILE}".new
                    mv "${VM_CFG_FILE}".new "${VM_CFG_FILE}"
                done
            fi
            let n++
        done
    fi

    [[ ${VM_MAC_REGENERATE} -eq 2 ]] && [[ ${VM_REGISTER} -eq 1 ]] && [[ -n "${MAC_DUPLICATE}" ]] && VM_MAC_REGENERATE=1
    if [[ ${VM_MAC_REGENERATE} -eq 1 ]] ; then
        MAC_DUPLICATE=1
        # vpx, generated, static 00:50:56:XX:YY:ZZ - we change YY:ZZ
        while [[ ${MAC_DUPLICATE} -eq 1 ]]
        do
            logger "Regenerate MAC addresses for \"${VM_NAME}\" ..."
            MAC_DUPLICATE=0
            #1. generate new "Base"
            VM_MAC_BASE=$(dd 2>/dev/null if=/dev/urandom bs=2 count=1 | hexdump -e '/2 "%5u\n"' | sed -re 's/ *//g')
            #2. change mac addresses
            for mac_id in $(grep 2>/dev/null -iE '^\s*ethernet[0-9]+\..*address\s*=' "${VM_RESTORE_DIR}/${VMX_FILE}" | awk -F "." '{print $1}')
            do
                mac_off=$(grep 2>/dev/null -iE "^${mac_id}"'\.generatedaddressoffset\s*=' "${VM_RESTORE_DIR}/${VMX_FILE}" | awk -F "\"" '{print $2}')
                if [[ -z "${mac_off}" ]] ; then
                    mac_sfx=$(dd 2>/dev/null if=/dev/urandom bs=2 count=1 | hexdump -e '/2 "%5u\n"' | sed -re 's/ *//g')
                else
                    let "mac_new = VM_MAC_BASE + mac_off"
                fi
                mac_sfx=$(printf '%4x' ${mac_new} | sed -re 's/(..)(..)/\1:\2/') #'
                mac=$(grep 2>/dev/null -iE "^${mac_id}"'\.(generated\.)?address\s*=' "${VM_RESTORE_DIR}/${VMX_FILE}" | awk -F "\"" '{print $2}' | sed -re 's/^(.{12}.*)/\1/')${mac_sfx} #'
                if echo "${MAC_LIST}" | grep -F "$mac"; then
                    logger "Generated MAC address is duplicate: \"${mac}\", redo ..."
                    MAC_DUPLICATE=1
                    break
                else
                    logger "Change MAC address to: \"${mac}\" ..."
                    sed -i -re "s/^${mac_id}"'\.(generated\.)?address\s*=\s*/${mac_id}.\1address = \"${mac}\"/" "${VM_RESTORE_DIR}/${VMX_FILE}" #'
                fi
            done
        done
    fi
    if [[ ${VM_REGISTER} -eq 1 ]] ; then
        if [[ -n "${VM_UUID_EXISTS}" ]] ; then
            logger "Remove existing UUID: \"${VM_UUID}\" ..."
            sed -i -re "/^\s*uuid\.bios/d" "${VM_RESTORE_DIR}/${VMX_FILE}"
        fi
        logger "Registering VM: \"${VM_NAME}\" ..."
        ${VMWARE_CMD} solo/registervm "${VM_RESTORE_DIR}/${VMX_FILE}" "${VM_NAME}"
        if [[ -n "${LIVE_VM_BACKUP_SNAPSHOT_ID}" ]] ; then
            sleep 2
            logger "Revert to last state of VM: \"${VM_NAME}\" ..."
            VM_ID=$(${VMWARE_CMD} vmsvc/getallvms | sed 's/[[:blank:]]\{3,\}/   /g' | fgrep "[" | fgrep "vmx-" | fgrep ".vmx" | fgrep "/" | fgrep "${VM_NAME}" | awk -F'   ' '{print ""$1""}' | sed '/^$/d' )
            if ${VMWARE_CMD} vmsvc/snapshot.revert "${VM_ID}" "${LIVE_VM_BACKUP_SNAPSHOT_ID}" 0 ; then
                sleep 2
                logger "Remove technical snapshot ..."
                ${VMWARE_CMD} vmsvc/snapshot.remove "${VM_ID}" "${LIVE_VM_BACKUP_SNAPSHOT_ID}"
            else
                logger "Cannot revert last state ..."
            fi
        fi
        [[ -n "${VM_LAST_SNAPSHOT_UID}" ]] && sed -i -re "s/^snapshot\.lastUID\s*=.*/snapshot.lastUID = \"${VM_LAST_SNAPSHOT_UID}\"/" "${VM_RESTORE_DIR}/${VMSD_FILE}"
        [[ $? -eq 0 ]] && logger "        Success"
    fi
    endTimer
    logger "################## Completed restore for $VM_NAME! #####################\n"
    if [[ ${NFS_UMOUNT} -eq 1 ]] ; then
        logger "debug" "Sleeping for 30seconds before unmounting NFS volume"
        sleep 30
        ${VMWARE_CMD} hostsvc/datastore/destroy ${NFS_LOCAL_NAME}
    fi
}

####################
#                  #
# Start of Script  #
#                  #
####################

#read user input
while getopts ":ic:l:d:" ARGS; do
    case $ARGS in
        c) 
            CONFIG_FILE="${OPTARG}"
            ;;
        l)
            LOG_OUTPUT="${OPTARG}"
            ;;
        d)
            DEVEL_MODE="${OPTARG}"
            ;;
        i)
            RESTORE_INTERACTIVE=1
            ;;
        :)
            echo "Option -${OPTARG} requires an argument."
            exit 1
            ;;
        *)
            printUsage
            exit 1
            ;;
    esac
done

ESX_VERSION=$(vmware -v | awk '{print $3}')
ESX_RELEASE=$(uname -r)

if [[ -r ghettovcb-restore.conf ]] || [[ -n "$RESTORE_INTERACTIVE" ]] ; then
    RESTORE_INTERACTIVE=1
    CONFIG_FILE=ghettovcb-restore.conf
    sanityCheck $#
    ghettoVCBinteractive
    exit 0
fi
#performs a check on the number of commandline arguments + verifies $2 is a valid file
sanityCheck $#

ghettoVCBrestore ${CONFIG_FILE}
