# Author: William Lam
# Created Date: 11/17/2008
# http://www.virtuallyghetto.com/
# https://github.com/lamw/ghettoVCB
# http://communities.vmware.com/docs/DOC-8760

##################################################################
#                   User Definable Parameters
##################################################################

LAST_MODIFIED_DATE=2019_01_06
VERSION=4

# directory that all VM backups should go (e.g. /vmfs/volumes/SAN_LUN1/mybackupdir)
VM_BACKUP_VOLUME=/vmfs/volumes/mini-local-datastore-hdd/backups

# Format output of VMDK backup
# zeroedthick
# 2gbsparse
# thin
# eagerzeroedthick
DISK_BACKUP_FORMAT=thin

# Number of backups for a given VM before deleting
VM_BACKUP_ROTATION_COUNT=3

# Directory naming convention for backup rotations (please ensure there are no spaces!)
# If set to "0", VMs will be rotated via an index, beginning at 0, ending at
# VM_BACKUP_ROTATION_COUNT-1
VM_BACKUP_DIR_NAMING_CONVENTION="$(date +%F_%H-%M-%S)"

# Shutdown guestOS prior to running backups and power them back on afterwards
# This feature assumes VMware Tools are installed, else they will not power down and loop forever
# 1=on, 0 =off
POWER_VM_DOWN_BEFORE_BACKUP=0

# enable shutdown code 1=on, 0 = off
ENABLE_HARD_POWER_OFF=0

# if the above flag "ENABLE_HARD_POWER_OFF "is set to 1, then will look at this flag which is the # of iterations
# the script will wait before executing a hard power off, this will be a multiple of 60seconds
# (e.g) = 3, which means this will wait up to 180seconds (3min) before it just powers off the VM
ITER_TO_WAIT_SHUTDOWN=3

# Number of iterations the script will wait before giving up on powering down the VM and ignoring it for backup
# this will be a multiple of 60 (e.g) = 5, which means this will wait up to 300secs (5min) before it gives up
POWER_DOWN_TIMEOUT=5

# enable compression with gzip+tar 1=on, 0=off, 2=compress .vmsn and vmdk files only
ENABLE_COMPRESSION=0
# compression command for copy (.vmsn files). This has to leave source and save compressed to a directory
# %f - source file, %d - destination directory you should not quote args, ghettoVCB take care
COMPRESSION_CMD_COPY='lzop -c %f >%d'
# compression command for a file (.vmdk files). This has to remove source file and save compressed to the same dir
# %f - source file you should not quote arg, ghettoVCB take care
COMPRESSION_CMD_FILE='lzop %f'

# enable two stage file level compression:
# stage 1 - vmkfstool copy VMDK to VMDK_TEMP_PATH (should be on a VMFS volume)
# stage 2 - compress to backup dir
VMDK_TEMP_PATH=

# Include VMs memory when taking snapshot
VM_SNAPSHOT_MEMORY=0

# Quiesce VM when taking snapshot (requires VMware Tools to be installed)
VM_SNAPSHOT_QUIESCE=0

# default 15min timeout
SNAPSHOT_TIMEOUT=15

# Allow VMs with snapshots to be backed up, 1 - this WILL CONSOLIDATE EXISTING SNAPSHOTS!
# 2 - PRESERVE SNAPSOTS
ALLOW_VMS_WITH_SNAPSHOTS_TO_BE_BACKEDUP=0

# Create a second snapshot to restore VM in running state
LIVE_VM_BACKUP=0

##########################################################
# NON-PERSISTENT NFS-BACKUP ONLY
#
# ENABLE NON PERSISTENT NFS BACKUP 1=on, 0=off

ENABLE_NON_PERSISTENT_NFS=0

# umount NFS datastore after backup is complete 1=yes, 0=no
UNMOUNT_NFS=0

# IP Address of NFS Server
NFS_SERVER=172.51.0.192

# NFS Version (v3=nfs v4=nfsv41) - Only v3 is valid for 5.5
NFS_VERSION=nfs

# Path of exported folder residing on NFS Server (e.g. /some/mount/point )
NFS_MOUNT=/upload

# Non-persistent NFS datastore display name of choice
NFS_LOCAL_NAME=backup

# Name of backup directory for VMs residing on the NFS volume
NFS_VM_BACKUP_DIR=mybackups

# ignore ghettoVCB.noBackup and ghettoVCB.excludeDisk options
#   if -x command line switch supplied
IGNORE_VMX_OPTIONS=0

##########################################################
# EMAIL CONFIGURATIONS
#

# Email Alerting 1=yes, 0=no
EMAIL_ALERT=0

# Email log 1=yes, 0=no
EMAIL_LOG=0

# Email Delay Interval from NC (netcat) - default 1
EMAIL_DELAY_INTERVAL=1

# Email SMTP server
EMAIL_SERVER=auroa.primp-industries.com

# Email SMTP server port
EMAIL_SERVER_PORT=25

# Email SMTP username
EMAIL_USER_NAME=

# Email SMTP password
EMAIL_USER_PASSWORD=

# Email FROM
EMAIL_FROM=root@ghettoVCB

# Email_STARTTLS
EMAIL_STARTTLS=0

# Email AUTH: empty - no authentication, plain - AUTH PLAIN, login - AUTH LOGIN
EMAIL_AUTH=

# Comma seperated list of receiving email addresses
EMAIL_TO=auroa@primp-industries.com

# %%0 - script name without path and .sh, %%h - hostname, %%s - final status short, %%S - final status full
EMAIL_SUBJ='%%0 - %%h %%s'
EMAIL_SUBJ_ERROR='%%0 - %%h %%s'

# Comma seperated list of additional receiving email addresses if status is not "OK"
EMAIL_ERRORS_TO=

# Comma separated list of VM startup/shutdown ordering
VM_SHUTDOWN_ORDER=
VM_STARTUP_ORDER=

# RSYNC LINK 1=yes, 0 = no
RSYNC_LINK=0

# DO NOT USE - UNTESTED CODE
# Path to another location that should have backups rotated,
# this is useful when your backups go to a temporary location
# then are rsync'd to a final destination.  You can specify the final
# destination as the ADDITIONAL_ROTATION_PATH which will be rotated after
# all VMs have been restarted
ADDITIONAL_ROTATION_PATH=

##########################################################
# SLOW NAS CONFIGURATIONS - By Rapitharian
##########################################################
#This Feature was added to the program to provide a fix for slow NAS devices similar to the Drobo and Synology devices.  SMB and Home NAS devices.
#This Feature enables the device to perform tasks (Deletes/data save for large files) and has the script wait for the NAS to catchup.
#This code has been in production on the authors systems for the last 2 years.

# Enable use of the NFS IO HACK for all NAS commands 1=yes, 0=no
# 0 uses the script in it's original state.
ENABLE_NFS_IO_HACK=0

# Set this value to determine how many times the script tries to work arround I/O errors each time the NAS slows down.
# The script will skip past this loop if the NAS is responsive.
NFS_IO_HACK_LOOP_MAX=10

# This value determines the  number of seconds to sleep, when the NFS device is unresponsive.
NFS_IO_HACK_SLEEP_TIMER=60

# ONLY USE THIS WITH EXTREMELY SLOW NAS DEVICES!
# This is a Brute-force/Mandatory delay added on top of any delay imposed by the NFS_IO_Hack.
# Set a delay timer to allow the NFS server to catch up to GhettoVCB's stream, when the NAS isn't responding timely.
# This acts like a cooldown period for the NAS.
# The value is measured in seconds.  This causes the script to pause between each VM.
NFS_BACKUP_DELAY=0

##################################################################
#                   End User Definable Parameters
##################################################################

########################## DO NOT MODIFY PAST THIS LINE ##########################

# Do not remove workdir on exit: 1=yes, 0=no
WORKDIR_DEBUG=0
LOG_LEVEL="info"

#VMDK_FILES_TO_BACKUP="all"
# We use "not-set" to indicate "all"
# $VMDK_FILES_TO_BACKUP is a NL separated list filename\nfilename\nfilename
VMDK_FILES_TO_BACKUP=

VERSION_STRING=${LAST_MODIFIED_DATE}_${VERSION}
LOG_TO_STDOUT=0

printUsage() {
        echo "###############################################################################"
        echo "#"
        echo "# ghettoVCB for ESX/ESXi 3.5, 4.x+, 5.x, 6.x, & 7.x"
        echo "# Author: William Lam"
        echo "# http://www.virtuallyghetto.com/"
        echo "# Documentation: http://communities.vmware.com/docs/DOC-8760"
        echo "# Created: 11/17/2008"
        echo "# Last modified: ${LAST_MODIFIED_DATE} Version ${VERSION}"
        echo "#"
        echo "###############################################################################"
        echo
        echo "Usage: $(basename $0) [options]"
        echo
        echo "OPTIONS:"
        echo "   -a     Backup all VMs on host"
        echo "   -f     List of VMs to backup"
        echo "   -m     Name of VM to backup (overrides -f and options in .vmx)"
        echo "   -c     VM configuration directory for VM backups"
        echo "   -g     Path to global ghettoVCB configuration file"
        echo "   -l     File to output logging"
        echo "   -w     ghettoVCB work directory (default: /tmp/ghettoVCB.work)"
        echo "   -x     ignore options in .vmx files"
        echo "   -d     Debug level [info|debug|dryrun] (default: info)"
        echo
        echo "(e.g.)"
        echo -e "\nBackup VMs stored in a list"
        echo -e "\t$0 -f vms_to_backup"
        echo -e "\nBackup a single VM"
        echo -e "\t$0 -m vm_to_backup"
        echo -e "\nBackup all VMs residing on this host"
        echo -e "\t$0 -a"
        echo -e "\nBackup all VMs residing on this host except for the VMs in the exclusion list"
        echo -e "\t$0 -a -e vm_exclusion_list"
        echo -e "\nBackup VMs based on specific configuration located in directory"
        echo -e "\t$0 -f vms_to_backup -c vm_backup_configs"
        echo -e "\nBackup VMs using global ghettoVCB configuration file"
        echo -e "\t$0 -f vms_to_backup -g /global/ghettoVCB.conf"
        echo -e "\nOutput will log to /tmp/ghettoVCB.log (consider logging to local or remote datastore to persist logs)"
        echo -e "\t$0 -f vms_to_backup -l /vmfs/volume/local-storage/ghettoVCB.log"
        echo -e "\nDry run (no backup will take place)"
        echo -e "\t$0 -f vms_to_backup -d dryrun"
        echo
        echo "NOTE:"
        echo "   .vmx file options (Settings->VM Options->Advanced, Edit configuration)"
        echo "      ghettoVCB.noBackup = \"Yes\" -- do not backup this VM"
        echo "      ghettoVCB.excludeDisk = \"scsi0:1 ide0:2\" -- do not backup listed disks"
        echo "      ghettoVCB.powerOff = \"True\" -- override global \"power off before backup\" option"
        echo
}

logger() {
    LOG_TYPE=$1
    MSG=$2

    if [[ "${LOG_LEVEL}" == "debug" ]] && [[ "${LOG_TYPE}" == "debug" ]] || [[ "${LOG_TYPE}" == "info" ]] || [[ "${LOG_TYPE}" == "dryrun" ]]; then
        TIME=$(date +%F" "%H:%M:%S)
        if [[ "${LOG_TO_STDOUT}" -eq 1 ]] ; then
            echo -e "${TIME} -- ${LOG_TYPE}: ${MSG}"
        fi

        if [[ -n "${LOG_OUTPUT}" ]] ; then
            echo -e "${TIME} -- ${LOG_TYPE}: ${MSG}" >> "${LOG_OUTPUT}"
        fi

        if [[ "${EMAIL_LOG}" -eq 1 ]] ; then
            echo -ne "${TIME} -- ${LOG_TYPE}: ${MSG}\r\n" >> "${EMAIL_LOG_OUTPUT}"
        fi
    fi
}

sanityCheck() {
    # ensure root user is running the script
    if [ ! $(env | grep -e "^USER=" | awk -F = '{print $2}') == "root" ]; then
        logger "info" "This script needs to be executed by \"root\"!"
        echo "ERROR: This script needs to be executed by \"root\"!"
        exit 1
    fi

    # use of global ghettoVCB configuration
    if [[ "${USE_GLOBAL_CONF}" -eq 1 ]] ; then
        reConfigureGhettoVCBConfiguration "${GLOBAL_CONF}"
    fi

    # always log to STDOUT, use "> /dev/null" to ignore output
    LOG_TO_STDOUT=1

    #if no logfile then provide default logfile in /tmp

    if [[ -z "${LOG_OUTPUT}" ]] ; then
        LOG_OUTPUT="/tmp/ghettoVCB-$(date +%F_%H-%M-%S)-$$.log"
        echo "Logging output to \"${LOG_OUTPUT}\" ..."
    fi

    touch "${LOG_OUTPUT}"
    # REDIRECT is used by the "tail" trick, use REDIRECT=/dev/null to redirect vmkfstool to STDOUT only
    REDIRECT=${LOG_OUTPUT}

    if [[ ! -f "${VM_FILE}" ]] && [[ "${USE_VM_CONF}" -eq 0 ]] && [[ "${BACKUP_ALL_VMS}" -eq 0 ]]; then
        logger "info" "ERROR: \"${VM_FILE}\" is not valid VM input file!"
        printUsage
    fi

    if [[ ! -f "${VM_EXCLUSION_FILE}" ]] && [[ "${EXCLUDE_SOME_VMS}" -eq 1 ]]; then
        logger "info" "ERROR: \"${VM_EXCLUSION_FILE}\" is not valid VM exclusion input file!"
        printUsage
    fi

    if [[ ! -d "${CONFIG_DIR}" ]] && [[ "${USE_VM_CONF}" -eq 1 ]]; then
        logger "info" "ERROR: \"${CONFIG_DIR}\" is not valid directory!"
        printUsage
    fi

    if [[ ! -f "${GLOBAL_CONF}" ]] && [[ "${USE_GLOBAL_CONF}" -eq 1 ]]; then
        logger "info" "ERROR: \"${GLOBAL_CONF}\" is not valid global configuration file!"
        printUsage
    fi

    if [[ -f /usr/bin/vmware-vim-cmd ]]; then
        VMWARE_CMD=/usr/bin/vmware-vim-cmd
        VMKFSTOOLS_CMD=/usr/sbin/vmkfstools
    elif [[ -f /bin/vim-cmd ]]; then
        VMWARE_CMD=/bin/vim-cmd
        VMKFSTOOLS_CMD=/sbin/vmkfstools
    else
        logger "info" "ERROR: Unable to locate *vimsh*! You're not running ESX(i) 3.5+, 4.x+, 5.x+ or 6.x!"
        echo "ERROR: Unable to locate *vimsh*! You're not running ESX(i) 3.5+, 4.x+, 5.x+ or 6.x!"
        exit 1
    fi
    if vmkfstools 2>&1 -h | grep -F -e '--adaptertype' | grep -qF 'deprecated'; then
        ADAPTERTYPE_DEPRECATED=1
    fi

    ESX_VERSION=$(vmware -v | awk '{print $3}')
    ESX_RELEASE=$(uname -r)

    case "${ESX_VERSION}" in
        7.0.0)                VER=7; break;;
        6.0.0|6.5.0|6.7.0)    VER=6; break;;
        5.0.0|5.1.0|5.5.0)    VER=5; break;;
        4.0.0|4.1.0)          VER=4; break;;
        3.5.0|3i)             VER=3; break;;
        *)              echo "You're not running ESX(i) 3.5, 4.x, 5.x & 6.x!"; exit 1; break;;
    esac

    NEW_VIMCMD_SNAPSHOT="no"
    ${VMWARE_CMD} vmsvc/snapshot.remove 2>&1 | grep -q "snapshotId"
    [[ $? -eq 0 ]] && NEW_VIMCMD_SNAPSHOT="yes"

    if [[ "${EMAIL_LOG}" -eq 1 ]] && [[ -f /usr/bin/nc ]] || [[ -f /bin/nc ]]; then
        if [[ -f /usr/bin/nc ]] ; then
            NC_BIN=/usr/bin/nc
        elif [[ -f /bin/nc ]] ; then
            NC_BIN=/bin/nc
        fi
    else
        EMAIL_LOG=0
    fi

    TAR="tar"
    [[ ! -f /bin/tar ]] && TAR="busybox tar"

    # Enable multiextent VMkernel module if disk format is 2gbsparse (disabled by default in 5.1)
    if [[ "${DISK_BACKUP_FORMAT}" == "2gbsparse" ]] && [[ "${VER}" -eq 5 || "${VER}" == "6" || "${VER}" == "7" ]]; then
        esxcli system module list | grep multiextent > /dev/null 2>&1
        if [ $? -eq 1 ]; then
            logger "info" "multiextent VMkernel module is not loaded & is required for 2gbsparse, enabling ..."
            esxcli system module load -m multiextent
        fi
    fi
}

startTimer() {
    START_TIME=$(date)
    S_TIME=$(date +%s)
}

endTimer() {
    END_TIME=$(date)
    E_TIME=$(date +%s)
    DURATION=$(echo $((E_TIME - S_TIME)))

    #calculate overall completion time
    if [[ ${DURATION} -le 60 ]] ; then
        logger "info" "Backup Duration: ${DURATION} Seconds"
    else
        logger "info" "Backup Duration: $(awk 'BEGIN{ printf "%.2f\n", '${DURATION}'/60}') Minutes"
    fi
}

captureDefaultConfigurations() {
    DEFAULT_VM_BACKUP_VOLUME="${VM_BACKUP_VOLUME}"
    DEFAULT_DISK_BACKUP_FORMAT="${DISK_BACKUP_FORMAT}"
    DEFAULT_VM_BACKUP_ROTATION_COUNT="${VM_BACKUP_ROTATION_COUNT}"
    DEFAULT_POWER_VM_DOWN_BEFORE_BACKUP="${POWER_VM_DOWN_BEFORE_BACKUP}"
    DEFAULT_ENABLE_HARD_POWER_OFF="${ENABLE_HARD_POWER_OFF}"
    DEFAULT_ITER_TO_WAIT_SHUTDOWN="${ITER_TO_WAIT_SHUTDOWN}"
    DEFAULT_POWER_DOWN_TIMEOUT="${POWER_DOWN_TIMEOUT}"
    DEFAULT_SNAPSHOT_TIMEOUT="${SNAPSHOT_TIMEOUT}"
    DEFAULT_ENABLE_COMPRESSION="${ENABLE_COMPRESSION}"
    DEFAULT_COMPRESSION_CMD_COPY="${COMPRESSION_CMD_COPY}"
    DEFAULT_COMPRESSION_CMD_FILE="${COMPRESSION_CMD_FILE}"
    DEFAULT_VMDK_TEMP_PATH="${VMDK_TEMP_PATH}"
    DEFAULT_VM_SNAPSHOT_MEMORY="${VM_SNAPSHOT_MEMORY}"
    DEFAULT_VM_SNAPSHOT_QUIESCE="${VM_SNAPSHOT_QUIESCE}"
    DEFAULT_ALLOW_VMS_WITH_SNAPSHOTS_TO_BE_BACKEDUP="${ALLOW_VMS_WITH_SNAPSHOTS_TO_BE_BACKEDUP}"
    DEFAULT_VMDK_FILES_TO_BACKUP="${VMDK_FILES_TO_BACKUP}"
    DEFAULT_EMAIL_LOG="${EMAIL_LOG}"
    DEFAULT_WORKDIR_DEBUG="${WORKDIR_DEBUG}"
    DEFAULT_VM_SHUTDOWN_ORDER="${VM_SHUTDOWN_ORDER}"
    DEFAULT_VM_STARTUP_ORDER="${VM_STARTUP_ORDER}"
    DEFAULT_RSYNC_LINK="${RSYNC_LINK}"
    DEFAULT_BACKUP_FILES_CHMOD="${BACKUP_FILES_CHMOD}"
	# Added the NFS_IO_HACK values below
    DEFAULT_NFS_IO_HACK_LOOP_MAX="${NFS_IO_HACK_LOOP_MAX}"
    DEFAULT_NFS_IO_HACK_SLEEP_TIMER="${NFS_IO_HACK_SLEEP_TIMER}"
    DEFAULT_NFS_BACKUP_DELAY="${NFS_BACKUP_DELAY}"
    DEFAULT_ENABLE_NFS_IO_HACK="${ENABLE_NFS_IO_HACK}"
}

useDefaultConfigurations() {
    VM_BACKUP_VOLUME="${DEFAULT_VM_BACKUP_VOLUME}"
    DISK_BACKUP_FORMAT="${DEFAULT_DISK_BACKUP_FORMAT}"
    VM_BACKUP_ROTATION_COUNT="${DEFAULT_VM_BACKUP_ROTATION_COUNT}"
    POWER_VM_DOWN_BEFORE_BACKUP="${DEFAULT_POWER_VM_DOWN_BEFORE_BACKUP}"
    ENABLE_HARD_POWER_OFF="${DEFAULT_ENABLE_HARD_POWER_OFF}"
    ITER_TO_WAIT_SHUTDOWN="${DEFAULT_ITER_TO_WAIT_SHUTDOWN}"
    POWER_DOWN_TIMEOUT="${DEFAULT_POWER_DOWN_TIMEOUT}"
    SNAPSHOT_TIMEOUT="${DEFAULT_SNAPSHOT_TIMEOUT}"
    ENABLE_COMPRESSION="${DEFAULT_ENABLE_COMPRESSION}"
    COMPRESSION_CMD_COPY="${DEFAULT_COMPRESSION_CMD_COPY}"
    COMPRESSION_CMD_FILE="${DEFAULT_COMPRESSION_CMD_FILE}"
    VMDK_TEMP_PATH="${DEFAULT_VMDK_TEMP_PATH}"
    VM_SNAPSHOT_MEMORY="${DEFAULT_VM_SNAPSHOT_MEMORY}"
    VM_SNAPSHOT_QUIESCE="${DEFAULT_VM_SNAPSHOT_QUIESCE}"
    ALLOW_VMS_WITH_SNAPSHOTS_TO_BE_BACKEDUP="${DEFAULT_ALLOW_VMS_WITH_SNAPSHOTS_TO_BE_BACKEDUP}"
    VMDK_FILES_TO_BACKUP="${DEFAULT_VMDK_FILES_TO_BACKUP}"
    EMAIL_LOG="${DEFAULT_EMAIL_LOG}"
    WORKDIR_DEBUG="${DEFAULT_WORKDIR_DEBUG}"
    VM_SHUTDOWN_ORDER="${DEFAULT_VM_SHUTDOWN_ORDER}"
    VM_STARTUP_ORDER="${DEFAULT_VM_STARTUP_ORDER}"
    RSYNC_LINK="${DEFAULT_RSYNC_LINK}"
    BACKUP_FILES_CHMOD="${DEFAULT_BACKUP_FILES_CHMOD}"
        # Added the NFS_IO_HACK values below
    ENABLE_NFS_IO_HACK="${DEFAULT_ENABLE_NFS_IO_HACK_ON}"
    NFS_IO_HACK_LOOP_MAX="${DEFAULT_NFS_IO_HACK_LOOP_MAX}"
    NFS_IO_HACK_SLEEP_TIMER="${DEFAULT_NFS_IO_HACK_SLEEP_TIMER}"
    NFS_BACKUP_DELAY="${DEFAULT_NFS_BACKUP_DELAY}"
}

reConfigureGhettoVCBConfiguration() {
    GLOBAL_CONF=$1

    if [[ -f "${GLOBAL_CONF}" ]]; then
        source "${GLOBAL_CONF}"
    else
        useDefaultConfigurations
    fi
}

reConfigureBackupParam() {
    VM=$1

    if [[ -e "${CONFIG_DIR}/${VM}" ]]; then
        logger "info" "CONFIG - USING CONFIGURATION FILE = ${CONFIG_DIR}/${VM}"
        source "${CONFIG_DIR}/${VM}"
    else
        useDefaultConfigurations
    fi
}

dumpHostInfo() {
    VERSION=$(vmware -v)
    logger "debug" "HOST VERSION: ${VERSION}"
    echo ${VERSION} | grep "Server 3i" || logger "debug" "HOST LEVEL: $(vmware -l)"
    logger "debug" "HOSTNAME: $(hostname)\n"
}

# if $1 WITH_SNAPS=0 - no; 1 - SNAPS; 2 - GET current SNAP ID
# we fill up
# VMDK__0 .. VMDK__n
# VMDK_SIZE__0 .. VMDK_SIZE__n
# VMDK_RID__0 .. VMDK_RID__n
# VMDK_N
# VMDK_X__0 .. VMDK_X__n
# VMDK_SIZE_X__0 .. VMDK_SIZE__n
# VMDK_XN
# LIVE_VM_BACKUP_SNAPSHOT_ID
getVMDKs() {
    if [[ "$1" = 2 ]]; then
    #we get only current snapshot VMDKs
        LIVE_VM_BACKUP_SNAPSHOT_ID=$(grep -iE "^snapshot.current" "${VMSD_PATH}" | awk -F "\"" '{print $2}')
    fi
    #get all VMDKs listed in .vmx file
    VMDKS_FOUND=$(grep -iE '(^scsi|^ide|^sata|^nvme)' "${VMX_PATH}" | grep -i fileName | awk -F " " '{print $1}')
    ## scsi0:3.fileName
    #'
    if [[ -n "$1" ]]; then
    #we have to backup all disk in .vmsd file
        VMDKS_FOUND="${VMDKS_FOUND}
$(grep -iE "^snapshot[0-9]+\.disk[0-9]+\.node" "${VMSD_PATH}" | awk -F "\"" '{print $1"."$2}' | awk -F "." '{print $1"."$2}')"
        ## snapshot0.disk12
    fi

    #get excluded VMDKs listed in .vmx file ghettoVCB.excludeDisk
    if [[ "${IGNORE_VMX_OPTIONS}" -ne 1 ]]; then
        VMDKS_EXCLUDE="::$(grep -iE 'ghettoVCB.excludeDisk' "${VMX_PATH}" | awk -F "\"" '{$0 = $2; gsub(/ +/, "::"); print}')::"
        logger "debug" "getVMDKs() exclude disk list: $VMDKS_EXCLUDE"
    fi

    #loop through each disk and verify that it's currently present and create array of valid VMDKS
    for DISK in ${VMDKS_FOUND}; do
        #extract the SCSI ID and use it to check for valid vmdk disk
        if [[ -n "${DISK%snapshot*}" ]]; then
            SCSI_ID=$(echo ${DISK%%.*})
            FILE_NAME=$(grep -i "^${SCSI_ID}.fileName" "${VMX_PATH}" | awk -F "\"" '{print $2}')
        else
            SCSI_ID=$(grep -i "^${DISK}\.node" "${VMSD_PATH}" |  awk -F "\"" '{print $2}')
            FILE_NAME=$(grep -i "^${DISK}\.fileName" "${VMSD_PATH}" | awk -F "\"" '{print $2}')
        fi
        if echo "${VMDKS_EXCLUDE}" | grep -q "::${SCSI_ID}::"; then
            VMDK_EXCLUDE_THIS=1
        else
            VMDK_EXCLUDE_THIS=0
        fi
        grep -i "^${SCSI_ID}.present" "${VMX_PATH}" | grep -qi "true" > /dev/null

## hmmm. for disk snapshots, we check the "original" disk properties...
## how vmware handle, if we change disk structure between two snapshot?

        #if valid, then we use the vmdk file
        if grep -i "^${SCSI_ID}.present" "${VMX_PATH}" | grep -qi "true" ; then
            #verify disk is not independent
            if ! grep -i "^${SCSI_ID}.mode" "${VMX_PATH}" | grep -i "independent" ; then
                #if works from .vmsd always have... [ -n $1 ]
                #if we find the device type is of scsi-disk, then proceed
                #if the deviceType is NULL for IDE which it is, thanks for the inconsistency VMware
                    #we'll do one more level of verification by checking to see if an ext. of .vmdk exists
                    #since we can not rely on the deviceType showing "ide-hardDisk"
                if [[ -z "${DISK%snapshot*}" ]] || grep -i "^${SCSI_ID}.deviceType" "${VMX_PATH}" | grep -qi "scsi-hardDisk" || grep -i "^${SCSI_ID}.fileName" "${VMX_PATH}" | grep -qi ".vmdk"; then
#                    DISK=$(grep -i "^${SCSI_ID}.fileName" "${VMX_PATH}" | awk -F "\"" '{print $2}')

                    if echo "${FILE_NAME}" | grep -qF "/vmfs/volumes" ; then
                        DISK_SIZE_IN_SECTORS=$(cat "${FILE_NAME}" | grep -F "VMFS" | grep -F ".vmdk" | awk '{print $2}')
                    else
                        DISK_SIZE_IN_SECTORS=$(cat "${VMX_DIR}/${FILE_NAME}" | grep -F "VMFS" | grep -F ".vmdk" | awk '{print $2}')
                    fi

                    DISK_SIZE=$(echo "${DISK_SIZE_IN_SECTORS}" | awk '{printf "%.0f\n",$1*512/1024/1024/1024}')
                    if [[ $VMDK_EXCLUDE_THIS = 0 ]]; then
                        eval "VMDK__${VMDK_N}=\"\${FILE_NAME}\""
                        eval "VMDK_SIZE__${VMDK_N}=\"${DISK_SIZE}\""
                        eval "VMDK_RID__${VMDK_N}=\"${DISK%.fileName}\""
                        eval "VMDK_NODE__${VMDK_N}=\"${SCSI_ID}\""
                        TOTAL_VM_SIZE=$((TOTAL_VM_SIZE+DISK_SIZE))
                        let VMDK_N++
                    else
                        eval "VMDK_X__${VMDK_XN}=\"\${FILE_NAME}\""
                        eval "VMDK_SIZE_X__${VMDK_XN}=\"${DISK_SIZE}\""
                        let VMDK_XN++
                    fi
                fi
            else
                #independent disks are not affected by snapshots, hence they can not be backed up
                # so we never encounter an independent disk in .vmsd (?)
#                DISK=$(grep -i "^${SCSI_ID}.fileName" "${VMX_PATH}" | awk -F "\"" '{print $2}')
                if echo "${FILE_NAME}" | grep -qF "/vmfs/volumes" ; then
                    DISK_SIZE_IN_SECTORS=$(cat "${FILE_NAME}" | grep -F "VMFS" | grep -F ".vmdk" | awk '{print $2}')
                else
                    DISK_SIZE_IN_SECTORS=$(cat "${VMX_DIR}/${FILE_NAME}" | grep -F "VMFS" | grep -F ".vmdk" | awk '{print $2}')
                fi
                DISK_SIZE=$(echo "${DISK_SIZE_IN_SECTORS}" | awk '{printf "%.0f\n",$1*512/1024/1024/1024}')
                INDEP_VMDKS="${FILE_NAME}###${DISK_SIZE}:${INDEP_VMDKS}"
            fi
        fi
    done
    logger "debug" "getVMDKs() - ${VMDKS}"
}

dumpVMConfigurations() {
    logger "info" "CONFIG - VERSION = ${VERSION_STRING}"
    logger "info" "CONFIG - GHETTOVCB_PID = ${GHETTOVCB_PID}"
    logger "info" "CONFIG - VM_BACKUP_VOLUME = ${VM_BACKUP_VOLUME}"
    logger "info" "CONFIG - ENABLE_NON_PERSISTENT_NFS = ${ENABLE_NON_PERSISTENT_NFS}"
	if [[ "${ENABLE_NON_PERSISTENT_NFS}" -eq 1 ]]; then
        logger "info" "CONFIG - UNMOUNT_NFS = ${UNMOUNT_NFS}"
        logger "info" "CONFIG - NFS_SERVER = ${NFS_SERVER}"
        logger "info" "CONFIG - NFS_VERSION = ${NFS_VERSION}"
        logger "info" "CONFIG - NFS_MOUNT = ${NFS_MOUNT}"
    fi
    logger "info" "CONFIG - VM_BACKUP_ROTATION_COUNT = ${VM_BACKUP_ROTATION_COUNT}"
    logger "info" "CONFIG - VM_BACKUP_DIR_NAMING_CONVENTION = ${VM_BACKUP_DIR_NAMING_CONVENTION}"
    logger "info" "CONFIG - DISK_BACKUP_FORMAT = ${DISK_BACKUP_FORMAT}"
    logger "info" "CONFIG - POWER_VM_DOWN_BEFORE_BACKUP = ${POWER_VM_DOWN_BEFORE_BACKUP}"
    logger "info" "CONFIG - ENABLE_HARD_POWER_OFF = ${ENABLE_HARD_POWER_OFF}"
    logger "info" "CONFIG - ITER_TO_WAIT_SHUTDOWN = ${ITER_TO_WAIT_SHUTDOWN}"
    logger "info" "CONFIG - POWER_DOWN_TIMEOUT = ${POWER_DOWN_TIMEOUT}"
    logger "info" "CONFIG - SNAPSHOT_TIMEOUT = ${SNAPSHOT_TIMEOUT}"
    logger "info" "CONFIG - LOG_LEVEL = ${LOG_LEVEL}"
    logger "info" "CONFIG - BACKUP_LOG_OUTPUT = ${LOG_OUTPUT}"
    logger "info" "CONFIG - ENABLE_COMPRESSION = ${ENABLE_COMPRESSION}"
    logger "info" "CONFIG - COMPRESSION_CMD_COPY = ${COMPRESSION_CMD_COPY}"
    logger "info" "CONFIG - COMPRESSION_CMD_FILE = ${COMPRESSION_CMD_FILE}"
    logger "info" "CONFIG - VMDK_TEMP_PATH = ${VMDK_TEMP_PATH}"
    logger "info" "CONFIG - VM_SNAPSHOT_MEMORY = ${VM_SNAPSHOT_MEMORY}"
    logger "info" "CONFIG - VM_SNAPSHOT_QUIESCE = ${VM_SNAPSHOT_QUIESCE}"
    logger "info" "CONFIG - ALLOW_VMS_WITH_SNAPSHOTS_TO_BE_BACKEDUP = ${ALLOW_VMS_WITH_SNAPSHOTS_TO_BE_BACKEDUP}"
    logger "info" "CONFIG - LIVE_VM_BACKUP = ${LIVE_VM_BACKUP}"
    logger "info" "CONFIG - VMDK_FILES_TO_BACKUP = ${VMDK_FILES_TO_BACKUP}"
    logger "info" "CONFIG - VM_SHUTDOWN_ORDER = ${VM_SHUTDOWN_ORDER}"
    logger "info" "CONFIG - VM_STARTUP_ORDER = ${VM_STARTUP_ORDER}"
    logger "info" "CONFIG - RSYNC_LINK = ${RSYNC_LINK}"
    logger "info" "CONFIG - BACKUP_FILES_CHMOD = ${BACKUP_FILES_CHMOD}"
    logger "info" "CONFIG - EMAIL_LOG = ${EMAIL_LOG}"
    if [[ "${EMAIL_LOG}" -eq 1 ]]; then
        logger "info" "CONFIG - EMAIL_SERVER = ${EMAIL_SERVER}"
        logger "info" "CONFIG - EMAIL_SERVER_PORT = ${EMAIL_SERVER_PORT}"
        logger "info" "CONFIG - EMAIL_DELAY_INTERVAL = ${EMAIL_DELAY_INTERVAL}"
        logger "info" "CONFIG - EMAIL_FROM = ${EMAIL_FROM}"
        logger "info" "CONFIG - EMAIL_TO = ${EMAIL_TO}"
        logger "info" "CONFIG - WORKDIR_DEBUG = ${WORKDIR_DEBUG}"
    fi
	if [[ "${ENABLE_NFS_IO_HACK}" -eq 1 ]]; then
		logger "info" "CONFIG - ENABLE NFS IO HACK = ${ENABLE_NFS_IO_HACK}"
		logger "info" "CONFIG - NFS IO HACK LOOP MAX = ${NFS_IO_HACK_LOOP_MAX}"
		logger "info" "CONFIG - NFS IO HACK SLEEP TIMER = ${NFS_IO_HACK_SLEEP_TIMER}"
		logger "info" "CONFIG - NFS BACKUP DELAY = ${NFS_BACKUP_DELAY}\n"
	else
	    logger "info" "CONFIG - ENABLE NFS IO HACK = ${ENABLE_NFS_IO_HACK}\n"
	fi
}

# Added the function below to allow reuse of the basics of the original hack in more places in the script.
# Rewrote the code to reduce the calls to the NAS when it slows.  Why make a bad situation worse with extra calls? 
NfsIoHack() {
    # NFS I/O error handling hack
    NFS_IO_HACK_COUNTER=0
    NFS_IO_HACK_STATUS=0
    NFS_IO_HACK_FILECHECK="$BACKUP_DIR_PATH/nfs_io.check"

    while [[ "${NFS_IO_HACK_STATUS}" -eq 0 ]] && [[ "${NFS_IO_HACK_COUNTER}" -lt "${NFS_IO_HACK_LOOP_MAX}" ]]; do
        touch "${NFS_IO_HACK_FILECHECK}"
        if [[ $? -ne 0 ]] ; then
            sleep "${NFS_IO_HACK_SLEEP_TIMER}"
            NFS_IO_HACK_COUNTER=$((NFS_IO_HACK_COUNTER+1))
        fi
        [[ $? -eq 0 ]] && NFS_IO_HACK_STATUS=1
    done

    NFS_IO_HACK_SLEEP_TIME=$((NFS_IO_HACK_COUNTER*NFS_IO_HACK_SLEEP_TIMER))

    rm -rf "${NFS_IO_HACK_FILECHECK}"

    if [[ "${NFS_IO_HACK_SLEEP_TIME}" -ne 0 ]] ; then
        if [[ "${NFS_IO_HACK_STATUS}" -eq 1 ]] ; then
            logger "info" "Slept ${NFS_IO_HACK_SLEEP_TIME} seconds to work around NFS I/O error"
        else
            logger "info" "Slept ${NFS_IO_HACK_SLEEP_TIME} seconds but failed work around for NFS I/O error"
        fi
    fi
}

# Converted the section of code below to a function to be able to call it when a failed backup occurs.
Get_Final_Status_Sendemail() {
    getFinalStatus

    logger "debug" "Succesfully removed lock directory - ${WORKDIR}\n"
    logger "info" "============================== ghettoVCB LOG END ================================\n"

    sendMail
}

indexedRotate() {
    local BACKUP_DIR_PATH=$1
    local VM_TO_SEARCH_FOR=$2

    #default rotation if variable is not defined
    if [[ -z ${VM_BACKUP_ROTATION_COUNT} ]]; then
        VM_BACKUP_ROTATION_COUNT=1
    fi

    #LIST_BACKUPS=$(ls -t "${BACKUP_DIR_PATH}" | grep "${VM_TO_SEARCH_FOR}-[0-9]*")
    i=${VM_BACKUP_ROTATION_COUNT}
    while [[ $i -ge 0 ]]; do
        if [[ -f ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$i.gz ]]; then
            if [[ $i -eq $((VM_BACKUP_ROTATION_COUNT-1)) ]]; then
                rm -rf ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$i.gz
				# Added the NFS_IO_HACK check and function call here.  Some NAS devices slow at this step.
                if [[ $? -ne 0 ]]  && [[ "${ENABLE_NFS_IO_HACK}" -eq 1 ]]; then
                    NfsIoHack
                fi
                if [[ $? -eq 0 ]]; then
                    logger "info" "Deleted ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$i.gz"
                else
                    logger "info" "Failure deleting ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$i.gz"
                fi
            else
                mv -f ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$i.gz ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$((i+1)).gz
				# Added the NFS_IO_HACK check and function call here.  Some NAS devices slow at this step.
                if [[ $? -ne 0 ]]  && [[ "${ENABLE_NFS_IO_HACK}" -eq 1 ]]; then
                    NfsIoHack
                fi
                if [[ $? -eq 0 ]]; then
                    logger "info" "Moved ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$i.gz to ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$((i+1)).gz"
                else
                    logger "info" "Failure moving ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$i.gz to ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$((i+1)).gz"
                fi
            fi
        fi
        if [[ -d ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$i ]]; then
            if [[ $i -eq $((VM_BACKUP_ROTATION_COUNT-1)) ]]; then
                rm -rf ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$i
				# Added the NFS_IO_HACK check and function call here.  Some NAS devices slow at this step.
                if [[ $? -ne 0 ]]  && [[ "${ENABLE_NFS_IO_HACK}" -eq 1 ]]; then
                    NfsIoHack
                fi
                if [[ $? -eq 0 ]]; then
                    logger "info" "Deleted ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$i"
                else
                    logger "info" "Failure deleting ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$i"
                fi
            else
                mv -f ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$i ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$((i+1))
				# Added the NFS_IO_HACK check and function call here.  Some NAS devices slow at this step.
                if [[ $? -ne 0 ]]  && [[ "${ENABLE_NFS_IO_HACK}" -eq 1 ]]; then
                    NfsIoHack
                fi
                if [[ $? -eq 0 ]]; then
                    logger "info" "Moved ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$i to ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$((i+1))"
                else
                    logger "info" "Failure moving ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$i to ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$((i+1))"
                fi
                if [[ $i -eq 0 ]]; then
                    mkdir ${BACKUP_DIR_PATH}/${VM_TO_SEARCH_FOR}-$i
                fi
            fi
        fi

        i=$((i-1))
    done
}

checkVMBackupRotation() {
    local BACKUP_DIR_PATH=$1
    local VM_TO_SEARCH_FOR=$2

    #default rotation if variable is not defined
    if [[ -z ${VM_BACKUP_ROTATION_COUNT} ]]; then
        VM_BACKUP_ROTATION_COUNT=1
    fi

    LIST_BACKUPS=$(ls -t "${BACKUP_DIR_PATH}" | grep "${VM_TO_SEARCH_FOR}-[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}_[0-9]\{2\}-[0-9]\{2\}-[0-9]\{2\}")
    BACKUPS_TO_KEEP=$(ls -t "${BACKUP_DIR_PATH}" | grep "${VM_TO_SEARCH_FOR}-[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}_[0-9]\{2\}-[0-9]\{2\}-[0-9]\{2\}" | head -"${VM_BACKUP_ROTATION_COUNT}")

    ORIG_IFS=${IFS}
    IFS='
'
    for i in ${LIST_BACKUPS}; do
        FOUND=0
        for j in ${BACKUPS_TO_KEEP}; do
            [[ $i == $j ]] && FOUND=1
        done

        if [[ $FOUND -eq 0 ]]; then
            logger "debug" "Removing $BACKUP_DIR_PATH/$i"
            rm -rf "$BACKUP_DIR_PATH/$i"

			# Added the NFS_IO_HACK check and function call here.  Also set the script to function the same, if the new feature is turned off.
            # Added variables to the code to control the timers and loops.
            # This code could be optimized based on the work in the NFS_IO_HACK function or that code could be used all the time with a few minor changes.
            if [[ $? -ne 0 ]] && [[ "${ENABLE_NFS_IO_HACK}" -eq 1 ]]; then 
                NfsIoHack
            else
				#NFS I/O error handling hack
				if [[ $? -ne 0 ]] ; then
					NFS_IO_HACK_COUNTER=0
					NFS_IO_HACK_STATUS=0
					NFS_IO_HACK_FILECHECK="$BACKUP_DIR_PATH/nfs_io.check"

					while [[ "${NFS_IO_HACK_STATUS}" -eq 0 ]] && [[ "${NFS_IO_HACK_COUNTER}" -lt "${NFS_IO_HACK_LOOP_MAX}" ]]; do
						sleep "${NFS_IO_HACK_SLEEP_TIMER}"
						NFS_IO_HACK_COUNTER=$((NFS_IO_HACK_COUNTER+1))
						touch "${NFS_IO_HACK_FILECHECK}"

						[[ $? -eq 0 ]] && NFS_IO_HACK_STATUS=1
					done

					NFS_IO_HACK_SLEEP_TIME=$((NFS_IO_HACK_COUNTER*NFS_IO_HACK_SLEEP_TIMER))

					rm -rf "${NFS_IO_HACK_FILECHECK}"

					if [[ "${NFS_IO_HACK_STATUS}" -eq 1 ]] ; then
						logger "info" "Slept ${NFS_IO_HACK_SLEEP_TIME} seconds to work around NFS I/O error"
					else
						logger "info" "Slept ${NFS_IO_HACK_SLEEP_TIME} seconds but failed work around for NFS I/O error"
					fi
                fi
            fi
        fi
    done
    IFS=${ORIG_IFS}
}

storageInfo() {
    SECTION=$1

    #SOURCE DATASTORE
    SRC_DATASTORE_CAPACITY=$($VMWARE_CMD hostsvc/datastore/info "${VMFS_VOLUME}" | grep -i "^\s*capacity" | awk '{print $3}' | sed 's/,//g')
    SRC_DATASTORE_FREE=$($VMWARE_CMD hostsvc/datastore/info "${VMFS_VOLUME}" | grep -iF "freespace" | awk '{print $3}' | sed 's/,//g')
    SRC_DATASTORE_BLOCKSIZE=$($VMWARE_CMD hostsvc/datastore/info "${VMFS_VOLUME}" | grep -iF blockSizeMb | awk '{print $3}' | sed 's/,//g')
    if [[ -z ${SRC_DATASTORE_BLOCKSIZE} ]] ; then
        SRC_DATASTORE_BLOCKSIZE="NA"
        SRC_DATASTORE_MAX_FILE_SIZE="NA"
    else
        case ${SRC_DATASTORE_BLOCKSIZE} in
            1)SRC_DATASTORE_MAX_FILE_SIZE="256 GB";;
            2)SRC_DATASTORE_MAX_FILE_SIZE="512 GB";;
            4)SRC_DATASTORE_MAX_FILE_SIZE="1024 GB";;
            8)SRC_DATASTORE_MAX_FILE_SIZE="2048 GB";;
        esac
    fi
    SRC_DATASTORE_CAPACITY_GB=$(echo "${SRC_DATASTORE_CAPACITY}" | awk '{printf "%.1f\n",$1/1024/1024/1024}')
    SRC_DATASTORE_FREE_GB=$(echo "${SRC_DATASTORE_FREE}" | awk '{printf "%.1f\n",$1/1024/1024/1024}')

    #DESTINATION DATASTORE
    DST_VOL_1=$(echo "${VM_BACKUP_VOLUME#/*/*/}")
    DST_DATASTORE=$(echo "${DST_VOL_1%%/*}")
    DST_DATASTORE_CAPACITY=$($VMWARE_CMD hostsvc/datastore/info "${DST_DATASTORE}" | grep -i "^\s*capacity" | awk '{print $3}' | sed 's/,//g')
    DST_DATASTORE_FREE=$($VMWARE_CMD hostsvc/datastore/info "${DST_DATASTORE}" | grep -iF "freespace" | awk '{print $3}' | sed 's/,//g')
    DST_DATASTORE_BLOCKSIZE=$($VMWARE_CMD hostsvc/datastore/info "${DST_DATASTORE}" | grep -iF blockSizeMb | awk '{print $3}' | sed 's/,//g')

    if [[ -z ${DST_DATASTORE_BLOCKSIZE} ]] ; then
        DST_DATASTORE_BLOCKSIZE="NA"
        DST_DATASTORE_MAX_FILE_SIZE="NA"
    else
        case ${DST_DATASTORE_BLOCKSIZE} in
            1)DST_DATASTORE_MAX_FILE_SIZE="256 GB";;
            2)DST_DATASTORE_MAX_FILE_SIZE="512 GB";;
            4)DST_DATASTORE_MAX_FILE_SIZE="1024 GB";;
            8)DST_DATASTORE_MAX_FILE_SIZE="2048 GB";;
        esac
    fi

    DST_DATASTORE_CAPACITY_GB=$(echo "${DST_DATASTORE_CAPACITY}" | awk '{printf "%.1f\n",$1/1024/1024/1024}')
    DST_DATASTORE_FREE_GB=$(echo "${DST_DATASTORE_FREE}" | awk '{printf "%.1f\n",$1/1024/1024/1024}')

    logger "debug" "Storage Information ${SECTION} backup: "
    logger "debug" "SRC_DATASTORE: ${VMFS_VOLUME}"
    logger "debug" "SRC_DATASTORE_CAPACITY: ${SRC_DATASTORE_CAPACITY_GB} GB"
    logger "debug" "SRC_DATASTORE_FREE: ${SRC_DATASTORE_FREE_GB} GB"
    logger "debug" "SRC_DATASTORE_BLOCKSIZE: ${SRC_DATASTORE_BLOCKSIZE}"
    logger "debug" "SRC_DATASTORE_MAX_FILE_SIZE: ${SRC_DATASTORE_MAX_FILE_SIZE}"
    logger "debug" ""
    logger "debug" "DST_DATASTORE: ${DST_DATASTORE}"
    logger "debug" "DST_DATASTORE_CAPACITY: ${DST_DATASTORE_CAPACITY_GB} GB"
    logger "debug" "DST_DATASTORE_FREE: ${DST_DATASTORE_FREE_GB} GB"
    logger "debug" "DST_DATASTORE_BLOCKSIZE: ${DST_DATASTORE_BLOCKSIZE}"
    logger "debug" "DST_DATASTORE_MAX_FILE_SIZE: ${DST_DATASTORE_MAX_FILE_SIZE}"
    if [[ "${SRC_DATASTORE_BLOCKSIZE}" != "NA" ]] && [[ "${DST_DATASTORE_BLOCKSIZE}" != "NA" ]]; then
        if [[ "${SRC_DATASTORE_BLOCKSIZE}" -lt "${DST_DATASTORE_BLOCKSIZE}" ]]; then
            logger "debug" ""
            logger "debug" "SRC VMFS blocksze of ${SRC_DATASTORE_BLOCKSIZE}MB is less than DST VMFS blocksize of ${DST_DATASTORE_BLOCKSIZE}MB which can be an issue for VM snapshots"
        fi
    fi

logger "debug" ""
}

powerOff() {
    VM_NAME="$1"
    VM_ID="$2"
    POWER_OFF_EC=0

    START_ITERATION=0
    logger "info" "Powering off initiated for ${VM_NAME}, backup will not begin until VM is off..."

    ${VMWARE_CMD} vmsvc/power.shutdown ${VM_ID} > /dev/null 2>&1
    while ${VMWARE_CMD} vmsvc/power.getstate ${VM_ID} | grep -qi "Powered on" ; do
        #enable hard power off code
        if [[ ${ENABLE_HARD_POWER_OFF} -eq 1 ]] ; then
            if [[ ${START_ITERATION} -ge ${ITER_TO_WAIT_SHUTDOWN} ]] ; then
                logger "info" "Hard power off occured for ${VM_NAME}, waited for $((ITER_TO_WAIT_SHUTDOWN*60)) seconds"
                ${VMWARE_CMD} vmsvc/power.off ${VM_ID} > /dev/null 2>&1
                #this is needed for ESXi, even the hard power off did not take affect right away
                sleep 60
                break
            fi
        fi

        logger "info" "VM is still on - Iteration: ${START_ITERATION} - sleeping for 60secs (Duration: $((START_ITERATION*60)) seconds)"
        sleep 60

        #logic to not backup this VM if unable to shutdown
        #after certain timeout period
        if [[ ${START_ITERATION} -ge ${POWER_DOWN_TIMEOUT} ]] ; then
            logger "info" "Unable to power off ${VM_NAME}, waited for $((POWER_DOWN_TIMEOUT*60)) seconds! Ignoring ${VM_NAME} for backup!"
            POWER_OFF_EC=1
            break
        fi
        START_ITERATION=$((START_ITERATION + 1))
    done
    if [[ ${POWER_OFF_EC} -eq 0 ]] ; then
        logger "info" "VM is powerdOff"
    fi
}

powerOn() {
    VM_NAME="$1"
    VM_ID="$2"
    POWER_ON_EC=0

    START_ITERATION=0
    logger "info" "Powering on initiated for ${VM_NAME}"

    ${VMWARE_CMD} vmsvc/power.on ${VM_ID} > /dev/null 2>&1
    while ${VMWARE_CMD} vmsvc/get.guest ${VM_ID} | grep -qi "toolsNotRunning" ; do
        logger "info" "VM is still not booted - Iteration: ${START_ITERATION} - sleeping for 60secs (Duration: $((START_ITERATION*60)) seconds)"
        sleep 60

        #logic to not backup this VM if unable to shutdown
        #after certain timeout period
        if [[ ${START_ITERATION} -ge ${POWER_DOWN_TIMEOUT} ]] ; then
            logger "info" "Unable to detect started tools on ${VM_NAME}, waited for $((POWER_DOWN_TIMEOUT*60)) seconds!"
            POWER_ON_EC=1
            break
        fi
        START_ITERATION=$((START_ITERATION + 1))
    done
    if [[ ${POWER_ON_EC} -eq 0 ]] ; then
        logger "info" "VM is powerdOn"
    fi
}

fileCompr() {
    if [[ -n "${VM_COMPR_FILE}" ]]; then
        COMPR_X_FILE="$1"
        eval "${VM_COMPR_FILE}"
    fi
}

#if VM_COMPR set, we copy+compress, if not just plain copy
# $1 from -> $2 to
copyCompr() {
    if [[ -n "${VM_COMPR_COPY}" ]]; then
        COMPR_X_FILE="$1"
        COMPR_X_DIR="$2"
        eval "${VM_COMPR_COPY}"
    elif [[ -n "${VM_COMPR_FILE}" ]]; then
        cp "$1" "$2"
        fileCompr "$2/${1##*/}"
    else
        cp "$1" "$2"
    fi
}

#find all extent and compress it
vmdkCompr() {
    if [[ -n "${VMDK_TEMP_PATH}" ]] ; then
        VMDK_FILE="${DESTINATION_VMDK_ORIG##*/}"
        VMDK_PATH="${DESTINATION_VMDK_ORIG%/*}"
        FILE_LIST="$(find 2>/dev/null "${VMDK_TEMP_PATH%/}/" -maxdepth 1 -name "${VMDK_FILE%.vmdk}-*.vmdk" )"
        while [[ -n "${FILE_LIST}" ]]
        do
            VMDK_FILE="$(echo "${FILE_LIST}" | head -1)"
            if echo "${VMDK_FILE}" | grep -qiE '.-(flat|s[0-9]+|delta|sesparse)\.vmdk$'; then
                logger "debug" "Compressing ${VMDK_FILE} to ${VMDK_PATH}"
                copyCompr "${VMDK_FILE}" "${VMDK_PATH}"
                rm "${VMDK_FILE}"
            fi
            FILE_LIST="$(echo "${FILE_LIST}" | sed -re '1d')"
        done
        mv "${DESTINATION_VMDK}" "${VMDK_PATH}"
    elif [[ -n "${VM_COMPR_FILE}" ]]; then
#try catch all file for [name].vmdk
# [name]-flat.vmdk thick, thin?
# [name]-s###.vmdk 2gbsparse
# [name]-delta.vmdk snapshot sparse
# [name]-sesparse.vmdk snapshot sesparse
        VMDK_FILE="${DESTINATION_VMDK##*/}"
        VMDK_PATH="${DESTINATION_VMDK%/*}"
        FILE_LIST="$(find 2>/dev/null "${VMDK_PATH%/}/" -maxdepth 1 -name "${VMDK_FILE%.vmdk}-*.vmdk" )"
        while [[ -n "${FILE_LIST}" ]]
        do
            VMDK_FILE="$(echo "${FILE_LIST}" | head -1)"
            if echo "${VMDK_FILE}" | grep -qiE '.-(flat|s[0-9]+|delta|sesparse)\.vmdk$' ; then
                logger "debug" "Compressing ${VMDK_FILE}"
                fileCompr "${VMDK_FILE}"
            fi
            FILE_LIST="$(echo "${FILE_LIST}" | sed -re '1d')"
        done
        mv "${DESTINATION_VMDK}" "${VMDK_PATH}"
    fi
}

ghettoVCB() {
    VM_INPUT=$1
    VM_OK=0
    VM_FAILED=0
    VMDK_FAILED=0
    PROBLEM_VMS=

    dumpHostInfo

    if [[ ${ENABLE_NON_PERSISTENT_NFS} -eq 1 ]] ; then
        VM_BACKUP_VOLUME="/vmfs/volumes/${NFS_LOCAL_NAME}/${NFS_VM_BACKUP_DIR}"
        if [[ "${LOG_LEVEL}" !=  "dryrun" ]] ; then
            #1 = readonly
            #0 = readwrite
            logger "debug" "Mounting NFS: ${NFS_SERVER}:${NFS_MOUNT} to /vmfs/volume/${NFS_LOCAL_NAME}"
            if [[ ${ESX_RELEASE} == "5.5.0" ]] || [[ ${ESX_RELEASE} == "6.0.0" || ${ESX_RELEASE} == "6.5.0" || ${ESX_RELEASE} == "6.7.0" || ${ESX_RELEASE} == "7.0.0" ]] ; then
                ${VMWARE_CMD} hostsvc/datastore/nas_create "${NFS_LOCAL_NAME}" "${NFS_VERSION}" "${NFS_MOUNT}" 0 "${NFS_SERVER}"
            else
                ${VMWARE_CMD} hostsvc/datastore/nas_create "${NFS_LOCAL_NAME}" "${NFS_SERVER}" "${NFS_MOUNT}" 0
            fi
        fi
    fi

    captureDefaultConfigurations

    if [[ "${USE_GLOBAL_CONF}" -eq 1 ]] ; then
        logger "info" "CONFIG - USING GLOBAL GHETTOVCB CONFIGURATION FILE = ${GLOBAL_CONF}"
    fi

    if [[ "${USE_VM_CONF}" -eq 0 ]] ; then
        dumpVMConfigurations
    fi

    #dump out all virtual machines allowing for spaces now
    ${VMWARE_CMD} vmsvc/getallvms | sed 's/[[:blank:]]\{3,\}/   /g' | fgrep "[" | fgrep "vmx-" | fgrep ".vmx" | fgrep "/" | awk -F'   ' '{print "\""$1"\"\t\""$2"\"\t\""$3"\""}' |  sed 's/\] /\]\"\t\"/g' > ${WORKDIR}/vms_list
    cp ${WORKDIR}/vms_list /tmp/vms_list.bak

    if [[ "${BACKUP_ALL_VMS}" -eq 1 ]] ; then
        ${VMWARE_CMD} vmsvc/getallvms | sed 's/[[:blank:]]\{3,\}/   /g' | fgrep "[" | fgrep "vmx-" | fgrep ".vmx" | fgrep "/" | awk -F'   ' '{print ""$2""}' | sed '/^$/d' > "${VM_INPUT}"
        cp ${VM_INPUT} /tmp/vms_input.bak
    fi

##shutdown some VM listed in $VM_SHUTDOWN_ORDER
    ORIG_IFS=${IFS}
    IFS='
'
    if [[ ${#VM_SHUTDOWN_ORDER} -gt 0 ]] && [[ "${LOG_LEVEL}" != "dryrun" ]]; then
        logger "debug" "VM Shutdown Order: ${VM_SHUTDOWN_ORDER}\n"
        IFS2="${IFS}"
        IFS=","
        for VM_NAME in ${VM_SHUTDOWN_ORDER}; do
            VM_ID=$(grep -E "\"${VM_NAME}\"" ${WORKDIR}/vms_list | awk -F "\t" '{print $1}' | sed 's/"//g')
            powerOff "${VM_NAME}" "${VM_ID}"
            if [[ ${POWER_OFF_EC} -eq 1 ]]; then
                logger "debug" "Error unable to shutdown VM ${VM_NAME}\n"
                PROBLEM_VMS="${PROBLEM_VMS} ${VM_NAME}"
            fi
        done

        IFS="${IFS2}"
    fi

#prepare file level compression settings
    VM_COMPR_COPY=
    COMPRESSION_EXT_COPY=
    VM_COMPR_FILE=
    COMPRESSION_EXT_FILE=
    # we compress .vmsn and .vmdk files only
    # we test
    if [[ -n "${COMPRESSION_CMD_COPY}" ]]; then
        VM_COMPR_COPY="$(echo "${COMPRESSION_CMD_COPY}" | sed -re 's/%f/\"\${COMPR_X_FILE}\"/g; s/%d/\"\${COMPR_X_DIR}\"/g')"
        echo "Compression Test File." >"${WORKDIR}/cmpr.txt"
        mkdir "${WORKDIR}/comprtest"
        copyCompr "${WORKDIR}/cmpr.txt" "${WORKDIR}/comprtest"
        COMPR_X_FILE=$(ls "${WORKDIR}/comprtest")
        [[ -f "${WORKDIR}/cmpr.txt" ]] && [[ -f "${WORKDIR}/comprtest/${COMPR_X_FILE}" ]] && COMPRESSION_EXT_COPY="${COMPR_X_FILE##*.}"
        if ! echo "${COMPRESSION_EXT_COPY}" | grep -qiE '(lzo|gz|bz2|lzma|zip|7z)'; then
            COMPRESSION_CMD_COPY=
            VM_COMPR_COPY=
            COMPRESSION_EXT_COPY=
        fi
    fi
    if [[ -n "${COMPRESSION_CMD_FILE}" ]]; then
        VM_COMPR_FILE="$(echo "${COMPRESSION_CMD_FILE}" | sed -re 's/%f/\"${COMPR_X_FILE}\"/g')"
        mkdir "${WORKDIR}/comprtest2"
        echo "Compression Test File." >"${WORKDIR}/comprtest2/cmpr.txt"
        fileCompr "${WORKDIR}/comprtest2/cmpr.txt"
        ! rm 2>/dev/null "${WORKDIR}/comprtest2/cmpr.txt" && COMPR_X_FILE=$(ls "${WORKDIR}/comprtest2") && COMPRESSION_EXT_FILE="${COMPR_X_FILE##*.}"
        if ! echo "${COMPRESSION_EXT_FILE}" | grep -qiE '(lzo|gz|bz2|lzma|zip|7z)'; then
            COMPRESSION_CMD_FILE=
            VM_COMPR_FILE=
            COMPRESSION_EXT_FILE=
        fi
    fi

##do VMs listed in file $VM_INPUT
    for VM_NAME in $(cat "${VM_INPUT}" | grep -v "^#" | sed '/^$/d' | sed -e 's/^[[:blank:]]*//;s/[[:blank:]]*$//'); do
        S1_TIME=$(date +%s)
        IGNORE_VM=0
        VM_NAME_P=$(echo "$VM_NAME" | sed -re 's/[*?$]/_/g;')
## check VM on $EXCLUDE_SOME_VM list
        if [[ "${EXCLUDE_SOME_VMS}" -eq 1 ]] ; then
            grep -E "^${VM_NAME}\$" "${VM_EXCLUSION_FILE}" > /dev/null 2>&1
            if [[ $? -eq 0 ]] ; then
                IGNORE_VM=1
                #VM_FAILED=0   #Excluded VM is NOT a failure. No need to set here, but listed for clarity
            fi
        fi
## 
        if [[ "${IGNORE_VM}" -eq 0 ]] && [[ -n "${PROBLEM_VMS}" ]] ; then
            if [[ "$(echo $PROBLEM_VMS | sed "s:$VM_NAME::")" != "$PROBLEM_VMS" ]] ; then
                logger "info" "Ignoring ${VM_NAME} as a problem VM\n"
                IGNORE_VM=1
                #A VM ignored due to a problem, should be treated as a failure
                VM_FAILED=1
            fi
        fi

        VM_ID=$(grep -F "\"${VM_NAME}\"" ${WORKDIR}/vms_list | awk -F "\t" '{print $1}' | sed 's/"//g')

        #ensure default value if one is not selected or variable is null
        if [[ -z ${VM_BACKUP_DIR_NAMING_CONVENTION} ]] ; then
            VM_BACKUP_DIR_NAMING_CONVENTION="$(date +%F_%k-%M-%S)"
        fi

##read per VM config file if any
        if [[ "${USE_VM_CONF}" -eq 1 ]] && [[ ! -z ${VM_ID} ]]; then
            reConfigureBackupParam "${VM_NAME}"
            dumpVMConfigurations
        fi

        VMFS_VOLUME=$(grep -F "\"${VM_NAME}\"" ${WORKDIR}/vms_list | awk -F "\t" '{print $3}' | sed 's/\[//;s/\]//;s/"//g')
        VMX_CONF=$(grep -F "\"${VM_NAME}\"" ${WORKDIR}/vms_list | awk -F "\t" '{print $4}' | sed 's/\[//;s/\]//;s/"//g')
        VMX_PATH="/vmfs/volumes/${VMFS_VOLUME}/${VMX_CONF}"
        VMX_DIR=$(dirname "${VMX_PATH}")
        VMSD_PATH="${VMX_PATH%.*}.vmsd"
        [[ -r "${VMSD_PATH}" ]] || VMSD_PATH=
        NVRM_PATH="${VMX_DIR}/$(grep -iE "nvram\s*=\s*" "${VMX_PATH}" | awk -F "\"" '{print $2}')"

        #storage info
        if [[ ! -z ${VM_ID} ]] && [[ "${LOG_LEVEL}" != "dryrun" ]]; then
            storageInfo "before"
        fi
        #get VM excluded in .vmx file ghettoVCB.noBackup = True|Yes|1
        # we check .vmx file for noBackup unless already ignore, ignore vmx options (-x) or select a VM (-m)
        if [[ "${IGNORE_VM}" -ne 1 ]] && [[ "${IGNORE_VMX_OPTIONS}" -ne 1 ]] && [[ -z "${VM_ARG}" ]] ; then
            grep -iF 'ghettoVCB.noBackup' "${VMX_PATH}" | grep -q -iE '(True|Yes|1)' && IGNORE_VM=1
        fi

        #get compression override settings from .vmx file ghettoVCB.enableCompression = 0|1|2 or space separated list of
        # vmsn - memory snapshots, scsi:0 scsi:1 - disks
        # 0 - no compress this VM, 1 - tar.gz this VM, 2 - compress files (all .vmsn and .vmdk), list - compress only listed "files"
        # we check .vmx file for options unless already ignore, ignore vmx options (-x)
        ENABLE_THIS_COMPRESSION=${ENABLE_COMPRESSION}
        VM_COMPRESSION_SELECT=
        if [[ "${IGNORE_VM}" -ne 1 ]] && [[ "${IGNORE_VMX_OPTIONS}" -ne 1 ]] ; then
            if grep -qiF 'ghettoVCB.enableCompression' "${VMX_PATH}" ; then
                ENABLE_THIS_COMPRESSION="$(grep -iF 'ghettoVCB.enableCompression' "${VMX_PATH}" | awk -F "\"" '{$0 = $2; gsub(/ +/, "::"); print}')"
                if [[ -z "${ENABLE_THIS_COMPRESSION}" ]]; then
                    ENABLE_THIS_COMPRESSION=${ENABLE_COMPRESSION}
                elif echo "${ENABLE_THIS_COMPRESSION}" | grep -vqE '^(0|1|2)$'; then
                    VM_COMPRESSION_SELECT="::${ENABLE_THIS_COMPRESSION}::"
                    ENABLE_THIS_COMPRESSION=2
                fi
            fi
        fi

        #ignore VM as it's in the exclusion list or was on problem list
        if [[ "${IGNORE_VM}" -eq 1 ]] ; then
            logger "debug" "Ignoring ${VM_NAME} for backup since it is located in exclusion file or problem list\n"
        #checks to see if we can pull out the VM_ID
        elif [[ -z ${VM_ID} ]] ; then
            logger "info" "ERROR: failed to locate and extract VM_ID for ${VM_NAME}!\n"
            VM_FAILED=1

##if dryrun FIXME we shoud merge this code to real code!
        elif [[ "${LOG_LEVEL}" == "dryrun" ]] ; then
            logger "dryrun" "###############################################"
            logger "dryrun" "Virtual Machine: $VM_NAME"
            logger "dryrun" "VM_ID: $VM_ID"
            logger "dryrun" "VMX_PATH: $VMX_PATH"
            logger "dryrun" "VMX_DIR: $VMX_DIR"
            logger "dryrun" "VMX_CONF: $VMX_CONF"
            logger "dryrun" "VMSD_PATH: $VMSD_PATH"
            logger "dryrun" "VMFS_VOLUME: $VMFS_VOLUME"
            logger "dryrun" "VMDK(s): "

            TOTAL_VM_SIZE=0
            VMDK_N=0
            VMDK_XN=0
            INDEP_VMDKS=
            getVMDKs 2

            n=0
            while [[ $n -lt ${VMDK_N} ]]; do
                eval "J_VMDK=\"\${VMDK__$n}\""
                eval "J_VMDK_SIZE=\"\${VMDK_SIZE__$n}\""
                logger "dryrun" "\t${J_VMDK}\t${J_VMDK_SIZE} GB"
                let n++
            done
            logger "dryrun" "VMDK(s) excluded by config: "
            n=0
            while [[ $n -lt ${VMDK_XN} ]]; do
                eval "J_VMDK=\"\${VMDK_X__$n}\""
                eval "J_VMDK_SIZE=\"\${VMDK_SIZE_X__$n}\""
                logger "dryrun" "\t${J_VMDK}\t${J_VMDK_SIZE} GB"
                let n++
            done

            HAS_INDEPENDENT_DISKS=0
            logger "dryrun" "INDEPENDENT VMDK(s): "
            OLD_IFS="${IFS}"
            IFS=":"
            for k in ${INDEP_VMDKS}; do
                HAS_INDEPENDENT_DISKS=1
                K_VMDK=$(echo "${k}" | awk -F "###" '{print $1}')
                K_VMDK_SIZE=$(echo "${k}" | awk -F "###" '{print $2}')
                logger "dryrun" "\t${K_VMDK}\t${K_VMDK_SIZE} GB"
            done
            IFS="${OLD_IFS}"
            INDEP_VMDKS=""

            logger "dryrun" "TOTAL_VM_SIZE_TO_BACKUP: ${TOTAL_VM_SIZE} GB"
            if [[ ${HAS_INDEPENDENT_DISKS} -eq 1 ]] ; then
                logger "dryrun" "Snapshots can not be taken for independent disks!"
                logger "dryrun" "THIS VIRTUAL MACHINE WILL NOT HAVE ALL ITS VMDKS BACKED UP!"
            fi

            if ls "${VMX_DIR}" | grep -qF -- "-delta.vmdk" ; then
                if [ ${ALLOW_VMS_WITH_SNAPSHOTS_TO_BE_BACKEDUP} -eq 0 ]; then
                    logger "dryrun" "Snapshots found for this VM, please commit all snapshots before continuing!"
                    logger "dryrun" "THIS VIRTUAL MACHINE WILL NOT BE BACKED UP DUE TO EXISTING SNAPSHOTS!"
                elif [ ${ALLOW_VMS_WITH_SNAPSHOTS_TO_BE_BACKEDUP} -eq 2 ]; then
                    logger "dryrun" "Snapshots found for this VM, PRESERVE (experimental)!"
                else
                    logger "dryrun" "Snapshots found for this VM, ALL EXISTING SNAPSHOTS WILL BE CONSOLIDATED PRIOR TO BACKUP!"
                fi
            fi

            if [[ ${VMDK_N} -eq 0 ]] ; then
                logger "dryrun" "THIS VIRTUAL MACHINE WILL NOT BE BACKED UP DUE TO EMPTY VMDK LIST!"
            fi
            logger "dryrun" "###############################################\n"
### END-OF-DRYRUN

        #checks to see if the VM has any snapshots to start with
        # snapshot detection: grep .vmsd
        elif [[ -f "${VMX_PATH}" ]] && [[ ! -z "${VMX_PATH}" ]]; then
            NUM_SNAPS=$(cat "${VMSD_PATH}" 2>&1 | grep -iF "snapshot.numSnapshots" | awk -F "\"" '{ print $2}')
            [[ -z "${NUM_SNAPS}" ]] && NUM_SNAPS=0
            if [[ ${NUM_SNAPS} -gt 0 ]] || ls "${VMX_DIR}" | grep -qF -- "-delta.vmdk" ; then
                if [ ${ALLOW_VMS_WITH_SNAPSHOTS_TO_BE_BACKEDUP} -eq 0 ]; then
                    logger "error" "Snapshot found for ${VM_NAME}, backup will not take place\n"
                    VM_FAILED=1
                    continue
                elif [ ${ALLOW_VMS_WITH_SNAPSHOTS_TO_BE_BACKEDUP} -eq 1 ]; then
                    logger "info" "Snapshot found for ${VM_NAME}, consolidating ALL snapshots now (this can take awhile) ...\n"
                    $VMWARE_CMD vmsvc/snapshot.removeall ${VM_ID} > /dev/null 2>&1
                elif [ ${ALLOW_VMS_WITH_SNAPSHOTS_TO_BE_BACKEDUP} -eq 2 ]; then
                    #preserve snapshots
                    logger "info" "Snapshot found for ${VM_NAME}, preserving snapshots ...\n"
                fi
            fi
            #nfs case and backup to root path of your NFS mount
            if [[ ${ENABLE_NON_PERSISTENT_NFS} -eq 1 ]] ; then
                BACKUP_DIR="/vmfs/volumes/${NFS_LOCAL_NAME}/${NFS_VM_BACKUP_DIR}/${VM_NAME_P}"
                if [[ -z ${VM_NAME} ]] || [[ -z ${NFS_LOCAL_NAME} ]] || [[ -z ${NFS_VM_BACKUP_DIR} ]]; then
                    logger "info" "ERROR: Variable BACKUP_DIR was not set properly, please ensure all required variables for non-persistent NFS backup option has been defined"
                    exit 1
                fi

                #non-nfs (SAN,LOCAL)
            else
                BACKUP_DIR="${VM_BACKUP_VOLUME}/${VM_NAME_P}"
                if [[ -z ${VM_BACKUP_VOLUME} ]]; then
                    logger "info" "ERROR: Variable VM_BACKUP_VOLUME was not defined"
                    exit 1
                fi
            fi

            #initial root VM backup directory
            if [[ ! -d "${BACKUP_DIR}" ]] ; then
                mkdir -p "${BACKUP_DIR}"
                if [[ ! -d "${BACKUP_DIR}" ]] ; then
                    logger "info" "Unable to create \"${BACKUP_DIR}\"! - Ensure VM_BACKUP_VOLUME was defined correctly"
                    exit 1
                fi
            fi

            # directory name of the individual Virtual Machine backup followed by naming convention followed by count
            VM_BACKUP_DIR="${BACKUP_DIR}/${VM_NAME_P}-${VM_BACKUP_DIR_NAMING_CONVENTION}"

            # Rsync relative path variable if needed
            RSYNC_LINK_DIR="./${VM_NAME_P}-${VM_BACKUP_DIR_NAMING_CONVENTION}"

            # Do indexed rotation if naming convention is set for it
            if [[ ${VM_BACKUP_DIR_NAMING_CONVENTION} = "0" ]]; then
                indexedRotate "${BACKUP_DIR}" "${VM_NAME_P}"
            fi

            mkdir -p "${VM_BACKUP_DIR}"

##restore config file
            RSTR_PATH="${VM_BACKUP_DIR}/ghettovcb-restore.conf"
            VM_UUID=$(grep -iE "^uuid.bios\s*=" "${VMX_PATH}" | awk -F "\"" '{print $2}')
            [[ -r "${NVRM_PATH}" ]] && cp "${NVRM_PATH}" "${VM_BACKUP_DIR}"

            echo  >"${RSTR_PATH}" "###############################################################################"
            echo >>"${RSTR_PATH}" "#"
            echo >>"${RSTR_PATH}" "# ghettoVCB for ESX/ESXi 3.5, 4.x+, 5.x, 6.x, & 7.x"
            echo >>"${RSTR_PATH}" "# Author: William Lam"
            echo >>"${RSTR_PATH}" "# http://www.virtuallyghetto.com/"
            echo >>"${RSTR_PATH}" "# Documentation: http://communities.vmware.com/docs/DOC-8760"
            echo >>"${RSTR_PATH}" "# Created: 11/17/2008"
            echo >>"${RSTR_PATH}" "# Last modified: ${LAST_MODIFIED_DATE} Version ${VERSION}"
            echo >>"${RSTR_PATH}" "# restore configuration"
            echo >>"${RSTR_PATH}" "#"
            echo >>"${RSTR_PATH}" "###############################################################################"
            echo >>"${RSTR_PATH}" "# old restore definition"
            echo >>"${RSTR_PATH}" "# <DIRECTORY or .TGZ>;<DATASTORE_TO_RESTORE_TO>;<DISK_FORMAT_TO_RESTORE>"
            echo >>"${RSTR_PATH}" "${VM_BACKUP_DIR};${VMX_DIR};4"
            echo >>"${RSTR_PATH}" "#"
            if [[ ${ENABLE_NON_PERSISTENT_NFS} = 1 ]] ; then
                echo >>"${RSTR_PATH}" "#VAR: NFS_SERVER=\"${NFS_SERVER}\""
                echo >>"${RSTR_PATH}" "#VAR: NFS_VERSION=\"${NFS_VERSION}\""
                echo >>"${RSTR_PATH}" "#VAR: NFS_MOUNT=\"${NFS_MOUNT}\""
                echo >>"${RSTR_PATH}" "#VAR: NFS_LOCAL_NAME=\"${NFS_LOCAL_NAME}\""
                echo >>"${RSTR_PATH}" "#VAR: NFS_VM_BACKUP_DIR=\"${NFS_VM_BACKUP_DIR}\""
            fi
            echo >>"${RSTR_PATH}" "#VAR: COMPRESSION_CMD_COPY=\"${COMPRESSION_CMD_COPY}\""
            echo >>"${RSTR_PATH}" "#VAR: COMPRESSION_EXT_COPY=\"${COMPRESSION_EXT_COPY}\""
            echo >>"${RSTR_PATH}" "#VAR: COMPRESSION_CMD_FILE=\"${COMPRESSION_CMD_FILE}\""
            echo >>"${RSTR_PATH}" "#VAR: COMPRESSION_EXT_FILE=\"${COMPRESSION_EXT_FILE}\""
            echo >>"${RSTR_PATH}" "#VAR: VM_NAME=\"${VM_NAME}\""
            echo >>"${RSTR_PATH}" "#VAR: VM_UUID=\"${VM_UUID}\""
            echo >>"${RSTR_PATH}" "#VAR: VM_RESTORE_DIR=\"${VMX_DIR}\""
            echo >>"${RSTR_PATH}" "#INFO: thin|zeroedthick|eagerzeroedthick|thick"
            echo >>"${RSTR_PATH}" "#VAR: DISK_RESTORE_FORMAT=\"thin\""
            echo >>"${RSTR_PATH}" "#VAR: DISK_SNAPSHOT_RESTORE_FORMAT=\"original\""
            echo >>"${RSTR_PATH}" "#VAR: VM_BACKUP_DIR=\"${VM_BACKUP_DIR}\""
            echo >>"${RSTR_PATH}" "#VAR: VM_RESTORE_TO_NONEMPTY_DIR=\"0\""
            echo >>"${RSTR_PATH}" "#VAR: VM_REGISTER=\"1\""
            echo >>"${RSTR_PATH}" "#INFO: 0 - no, 1 - yes, 2 - if MAC duplicated"
            echo >>"${RSTR_PATH}" "#VAR: VM_MAC_REGENERATE=\"2\""
            echo >>"${RSTR_PATH}" "#VAR: VMX_FILE=\"${VMX_PATH##*/}\""
            [[ -r "${VMSD_PATH}" ]] && echo >>"${RSTR_PATH}" "#VAR: VMSD_FILE=\"${VMSD_PATH##*/}\""
            [[ -r "${NVRM_PATH}" ]] && echo >>"${RSTR_PATH}" "#VAR: NVRM_FILE=\"${NVRM_PATH##*/}\""
            echo >>"${RSTR_PATH}" "#VAR: VM_SNAPSHOT_MEMORY=\"${VM_SNAPSHOT_MEMORY}\""
            #new variable to keep track on whether VM has independent disks
            VM_HAS_INDEPENDENT_DISKS=0

            #extract all valid VMDK(s) from VM
            #if we want, we already remove all snapshots
            #we get config, BEFORE take backup snapshot
            VMDK_N=0
            VMDK_XN=0
            INDEP_VMDKS=
            LIVE_VM_BACKUP_SNAPSHOT_ID=
            WITH_SNAPS=0
            [[ ${ALLOW_VMS_WITH_SNAPSHOTS_TO_BE_BACKEDUP} -eq 2 ]] && WITH_SNAPS=1

            if [[ ! -z ${INDEP_VMDKS} ]] ; then
                VM_HAS_INDEPENDENT_DISKS=1
            fi

            ORGINAL_VM_POWER_STATE=$(${VMWARE_CMD} vmsvc/power.getstate ${VM_ID} | tail -1)
            CONTINUE_TO_BACKUP=1

            # get VM power off before backup in .vmx file ghettoVCB.powerOff = True|Yes|1 or False|No|0
            # we check .vmx file
            POWER_THIS_VM_DOWN_BEFORE_BACKUP=${POWER_VM_DOWN_BEFORE_BACKUP}
            if [[ "${IGNORE_VMX_OPTIONS}" -ne 1 ]]; then
                #override global option
                grep -iF 'ghettoVCB.poweOff' "${VMX_PATH}" | grep -q -iE '(False|No|0)' && POWER_THIS_VM_DOWN_BEFORE_BACKUP=0
                grep -iF 'ghettoVCB.poweOff' "${VMX_PATH}" | grep -q -iE '(True|Yes|1)' && POWER_THIS_VM_DOWN_BEFORE_BACKUP=1
            fi
            #section that will power down a VM prior to taking a snapshot and backup and power it back on
            if [[ ${POWER_THIS_VM_DOWN_BEFORE_BACKUP} = 1 ]] ; then
                powerOff "${VM_NAME}" "${VM_ID}"
                if [[ ${POWER_OFF_EC} -eq 1 ]]; then
                    VM_FAILED=1
                    CONTINUE_TO_BACKUP=0
                fi
            fi

            if [[ ${CONTINUE_TO_BACKUP} -eq 1 ]] ; then
                logger "info" "Initiate backup for ${VM_NAME}"
                startTimer

                SNAP_SUCCESS=1
                VM_VMDK_FAILED=0

## to "live" backup, we should create two snapshot
## snap1 - backup and restore state
## snap2 - to go on under backup
## remove snap2
## ...
## we restore with snap1
## start restored VM
## revert to snap1 or something and delete snap1
                # get VM power off before backup in .vmx file ghettoVCB.powerOff = True|Yes|1 or False|No|0
                # we check .vmx file
                LIVE_THIS_VM_BACKUP=${LIVE_VM_BACKUP}
                if [[ "${IGNORE_VMX_OPTIONS}" -ne 1 ]]; then
                    #override global option
                    grep -iF 'ghettoVCB.liveBackup' "${VMX_PATH}" | grep -q -iE '(False|No|0)' && LIVE_THIS_VM_BACKUP=0
                    grep -iF 'ghettoVCB.liveBackup' "${VMX_PATH}" | grep -q -iE '(True|Yes|1)' && LIVE_THIS_VM_BACKUP=1
                fi
#we record last snapshot uid to restore it after backup
                VM_LAST_SNAPSHOT_UID=
                [[ -r "${VMSD_PATH}" ]] && VM_LAST_SNAPSHOT_UID=$(grep -iE "^snapshot\.lastUID\s*=" "${VMSD_PATH}" | awk -F "\"" '{print $2}')
                [[ -n "${VM_LAST_SNAPSHOT_UID}" ]] && echo >>"${RSTR_PATH}" "#VAR: VM_LAST_SNAPSHOT_UID=\"${VM_LAST_SNAPSHOT_UID}\""
                #powered on VMs only
                if [[ ${LIVE_THIS_VM_BACKUP} = 1 ]] && [[ ! ${POWER_THIS_VM_DOWN_BEFORE_BACKUP} -eq 1 ]] && [[ "${ORGINAL_VM_POWER_STATE}" != "Powered off" ]]; then
                    #get current snapshot ID
                    SNAPSHOT_NAME="ghettoVCB-live-snapshot-$(date +%F)"
                    logger "info" "Creating Snapshot \"${SNAPSHOT_NAME}\" for ${VM_NAME}"
                    ${VMWARE_CMD} vmsvc/snapshot.create ${VM_ID} "${SNAPSHOT_NAME}" "${SNAPSHOT_NAME}" "1" "${VM_SNAPSHOT_QUIESCE}" > /dev/null 2>&1

                    logger "debug" "Waiting for snapshot \"${SNAPSHOT_NAME}\" to be created"
                    logger "debug" "Snapshot timeout set to: $((SNAPSHOT_TIMEOUT*60)) seconds"
                    START_ITERATION=0
                    while [[ $(${VMWARE_CMD} vmsvc/snapshot.get ${VM_ID} | grep -cF "\"${SNAPSHOT_NAME}\"") -ge 1 ]]; do
                        if [[ ${START_ITERATION} -ge ${SNAPSHOT_TIMEOUT} ]] ; then
                            logger "info" "Snapshot timed out, failed to create snapshot: \"${SNAPSHOT_NAME}\" for ${VM_NAME}"
                            SNAP_SUCCESS=0
                            echo "ERROR: Unable to backup ${VM_NAME} due to snapshot creation" >> ${VM_BACKUP_DIR}/STATUS.error
                            break
                        fi

                        logger "debug" "Waiting for snapshot creation to be completed - Iteration: ${START_ITERATION} - sleeping for 60secs (Duration: $((START_ITERATION*30)) seconds)"
                        sleep 60

                        START_ITERATION=$((START_ITERATION + 1))
                    done
                    WITH_SNAPS=2

                fi

                cp "${VMX_PATH}" "${VM_BACKUP_DIR}"
                [[ -r "${VMSD_PATH}" ]] && cp "${VMSD_PATH}" "${VM_BACKUP_DIR}"
                getVMDKs ${WITH_SNAPS}
                if [[ ${WITH_SNAPS} -eq 2 ]]; then
                    #add disks from current snap
                    echo >>"${RSTR_PATH}" "#VAR: LIVE_VM_BACKUP_SNAPSHOT_NAME=\"${SNAPSHOT_NAME}\""
                    echo >>"${RSTR_PATH}" "#VAR: LIVE_VM_BACKUP_SNAPSHOT_ID=\"${LIVE_VM_BACKUP_SNAPSHOT_ID}\""
                fi
##copy memory snapshots .vmsn
                n=0
                grep 2>/dev/null -qiE "^snapshot[0-9]+\.filename\s*=" "${VMSD_PATH}" && for snap in $(grep -iE "^snapshot[0-9]+\.filename\s*=" "${VMSD_PATH}" | awk -F "." '{print $1}'); do
                    vmsn="$(grep -iE "^${snap}\.filename\s*=" "${VMSD_PATH}"| awk -F "\"" '{print $2}')"
                    logger "info" "Backup VM snapshot memory: ${vmsn}"
                    echo >>"${RSTR_PATH}" "#"
                    echo >>"${RSTR_PATH}" "#INFO: SNAPSHOT MEMORY BACKUP START NO: $n"
                    echo >>"${RSTR_PATH}" "#VAR: VMSN_FILE__$n=\"${vmsn}\""
                    if [[ ${ENABLE_THIS_COMPRESSION} -eq 2 ]] && ( [[ -z "${VM_COMPRESSION_SELECT}" ]] || echo "${VM_COMPRESSION_SELECT}" | grep -iF "::vmsn::" ); then
                        copyCompr "${VMX_DIR}/${vmsn}" "${VM_BACKUP_DIR}"
                        echo >>"${RSTR_PATH}" "#VAR: VMSN_COMPRESSED__$n=\"${COMPRESSION_EXT_COPY}\""
                    else
                        cp "${VMX_DIR}/${vmsn}" "${VM_BACKUP_DIR}"
                    fi
                    let n++
                done

                #powered on VMs only
                if [[ ${SNAP_SUCCESS} -eq 1 ]] && [[ ! ${POWER_THIS_VM_DOWN_BEFORE_BACKUP} -eq 1 ]] && [[ "${ORGINAL_VM_POWER_STATE}" != "Powered off" ]]; then
                    #get current snapshot ID
                    SNAPSHOT_NAME="ghettoVCB-snapshot-$(date +%F)"
                    logger "info" "Creating Snapshot \"${SNAPSHOT_NAME}\" for ${VM_NAME}"
                    ${VMWARE_CMD} vmsvc/snapshot.create ${VM_ID} "${SNAPSHOT_NAME}" "${SNAPSHOT_NAME}" "${VM_SNAPSHOT_MEMORY}" "${VM_SNAPSHOT_QUIESCE}" > /dev/null 2>&1

                    logger "debug" "Waiting for snapshot \"${SNAPSHOT_NAME}\" to be created"
                    logger "debug" "Snapshot timeout set to: $((SNAPSHOT_TIMEOUT*60)) seconds"
                    START_ITERATION=0
                    while [[ $(${VMWARE_CMD} vmsvc/snapshot.get ${VM_ID} | grep -cF "\"${SNAPSHOT_NAME}\"") -ge 1 ]]; do
                        if [[ ${START_ITERATION} -ge ${SNAPSHOT_TIMEOUT} ]] ; then
                            logger "info" "Snapshot timed out, failed to create snapshot: \"${SNAPSHOT_NAME}\" for ${VM_NAME}"
                            SNAP_SUCCESS=0
                            echo "ERROR: Unable to backup ${VM_NAME} due to snapshot creation" >> ${VM_BACKUP_DIR}/STATUS.error
                            break
                        fi

                        logger "debug" "Waiting for snapshot creation to be completed - Iteration: ${START_ITERATION} - sleeping for 60secs (Duration: $((START_ITERATION*30)) seconds)"
                        sleep 60

                        START_ITERATION=$((START_ITERATION + 1))
                    done
                fi
                echo >>"${RSTR_PATH}" "#VAR: DISK_BACKUP_FORMAT=${DISK_BACKUP_FORMAT}"

## start to backup VMDKs
                if [[ ${SNAP_SUCCESS} -eq 1 ]] ; then
                    if [[ $NUM_SNAPS -gt 0 ]] && [[ ${ALLOW_VMS_WITH_SNAPSHOTS_TO_BE_BACKEDUP} -eq 2 ]]; then
                        echo >>"${RSTR_PATH}" "#INFO: BACKUP TYPE: ONLINE PRESERVE SNAPSHOTS"
                    elif [[ ${POWER_VM_DOWN_BEFORE_BACKUP} -eq 1 ]]; then
                        echo >>"${RSTR_PATH}" "#INFO: BACKUP TYPE: OFFLINE"
                    else
                        echo >>"${RSTR_PATH}" "#INFO: BACKUP TYPE: ONLINE"
                    fi

                    DISK_NO=0
                    n=0
                    while [[ $n -lt $VMDK_N ]]; do
                        eval "VMDK=\"\${VMDK__$n}\""
                        eval "VMDK_RID=\"\${VMDK_RID__$n}\""
                        eval "VMDK_NODE=\"\${VMDK_NODE__$n}\""

                        if [[ -z "${VMDK_FILES_TO_BACKUP}" ]] || echo "${VMDK_FILES_TO_BACKUP}" | grep -qF "${VMDK}"; then
                            #added this section to handle VMDK(s) stored in different datastore than the VM
                            if echo ${VMDK} | grep -q "^/vmfs/volumes" ; then
                                SOURCE_VMDK="${VMDK}"
                                DS_UUID=${VMDK#/vmfs/volumes/*}
                                DS_UUID=${DS_UUID%/*/*}/
                                VMDK_DISK=${VMDK##/*/}
                                mkdir -p "${VM_BACKUP_DIR}/${DS_UUID}"
                            else
                                SOURCE_VMDK="${VMX_DIR}/${VMDK}"
                                VMDK_DISK=${VMDK}
                                DS_UUID=
                            fi
                            DESTINATION_VMDK="${VM_BACKUP_DIR}/${DS_UUID}${VMDK_DISK}"
                            DESTINATION_VMDK_REL="${DS_UUID}${VMDK_DISK}"
                            #support for vRDM and deny pRDM
                            grep "vmfsPassthroughRawDeviceMap" "${SOURCE_VMDK}" > /dev/null 2>&1
                            if [[ $? -eq 1 ]] ; then
                                FORMAT_OPTION="UNKNOWN"
                                if [[ "${DISK_BACKUP_FORMAT}" == "zeroedthick" ]] ; then
                                    if [[ "${VER}" == "4" ]] || [[ "${VER}" == "5" ]] || [[ "${VER}" == "6" ]] || [[ "${VER}" == "7" ]] ; then
                                        FORMAT_OPTION="zeroedthick"
                                    else
                                        FORMAT_OPTION=""
                                    fi
                                elif [[ "${DISK_BACKUP_FORMAT}" == "2gbsparse" ]] ; then
                                    FORMAT_OPTION="-d 2gbsparse"
                                elif [[ "${DISK_BACKUP_FORMAT}" == "thin" ]] ; then
                                    FORMAT_OPTION="-d thin"
                                elif [[ "${DISK_BACKUP_FORMAT}" == "eagerzeroedthick" ]] ; then
                                    if [[ "${VER}" == "4" ]] || [[ "${VER}" == "5" ]] || [[ "${VER}" == "6" ]] || [[ "${VER}" == "7" ]]; then
                                        FORMAT_OPTION="-d eagerzeroedthick"
                                    else
                                        FORMAT_OPTION=""
                                    fi
                                fi

                                if  [[ "${FORMAT_OPTION}" == "UNKNOWN" ]] ; then
                                    logger "info" "ERROR: wrong DISK_BACKUP_FORMAT \"${DISK_BACKUP_FORMAT}\ specified for ${VM_NAME}"
                                    VM_VMDK_FAILED=1
                                else
                                    VMDK_OUTPUT=$(mktemp ${WORKDIR}/ghettovcb.XXXXXX)
                                    tail -f "${VMDK_OUTPUT}" &
                                    TAIL_PID=$!

                                    [[ -z "$ADAPTERTYPE_DEPRECATED" ]] && ADAPTER_FORMAT=$(grep -i "ddb.adapterType" "${SOURCE_VMDK}" | awk -F "=" '{print $2}' | sed -e 's/^[[:blank:]]*//;s/[[:blank:]]*$//;s/"//g')
                                    [[ -n "${ADAPTER_FORMAT}" ]] && ADAPTER_FORMAT="-a ${ADAPTER_FORMAT}"
                                    VMDK_TYPE=$(grep "^\s*createType\s*=\s*" "${SOURCE_VMDK}" | awk -F "\"" '{print tolower($2)}') #seSparse -> sesparse '

                                    echo >>"${RSTR_PATH}" "#"
                                    echo >>"${RSTR_PATH}" "#INFO: DISK BACKUP START NO: ${DISK_NO}"
                                    echo >>"${RSTR_PATH}" "#VAR: VMDK_RID__${DISK_NO}=\"${VMDK_RID}\""
                                    echo >>"${RSTR_PATH}" "#VAR: VMDK_NODE__${DISK_NO}=\"${VMDK_NODE}\""
                                    echo >>"${RSTR_PATH}" "#VAR: SOURCE_VMDK__${DISK_NO}=\"${SOURCE_VMDK#${VMX_DIR}/}\""
                                    echo >>"${RSTR_PATH}" "#VAR: SOURCE_VMDK_TYPE__${DISK_NO}=\"${VMDK_TYPE}\""
                                    echo >>"${RSTR_PATH}" "#VAR: ADAPTER_FORMAT__${DISK_NO}=\"${ADAPTER_FORMAT}\""
                                    echo >>"${RSTR_PATH}" "#VAR: FORMAT_OPTION__${DISK_NO}=\"${FORMAT_OPTION}\""
                                    echo >>"${RSTR_PATH}" "#VAR: DESTINATION_VMDK__${DISK_NO}=\"${DESTINATION_VMDK_REL}\""
                                    logger "debug" "${VMKFSTOOLS_CMD} -i \"${SOURCE_VMDK}\" ${ADAPTER_FORMAT} ${FORMAT_OPTION} \"${DESTINATION_VMDK}\""
                                    VMDK_COMPRESS=0
                                    [[ ${ENABLE_THIS_COMPRESSION} -eq 2 ]] && ( [[ -z "${VM_COMPRESSION_SELECT}" ]] || echo "${VM_COMPRESSION_SELECT}" | grep -iF "::${VMDK_NODE}::" ) && VMDK_COMPRESS=1
                                    if [[ ${VMDK_COMPRESS} -eq 1 ]] && [[ -n "${VMDK_TEMP_PATH}" ]] ; then
                                        DESTINATION_VMDK_ORIG="${DESTINATION_VMDK}"
                                        DESTINATION_VMDK="${VMDK_TEMP_PATH}/${DESTINATION_VMDK##*/}"
                                    fi
                                    eval "${VMKFSTOOLS_CMD} -i '$(echo "${SOURCE_VMDK}" | sed -re "s/'/'\"'\"'/g")' ${ADAPTER_FORMAT} ${FORMAT_OPTION} '$(echo "${DESTINATION_VMDK}" | sed -re "s/'/'\"'\"'/g")' > \"${VMDK_OUTPUT}\" 2>&1"
                                    VMDK_EXIT_CODE=$?
                                    kill "${TAIL_PID}"
                                    cat "${VMDK_OUTPUT}" >> "${REDIRECT}"
                                    echo >> "${REDIRECT}"
                                    echo
                                    rm "${VMDK_OUTPUT}"

                                    if [[ "${VMDK_EXIT_CODE}" != 0 ]] ; then
                                        logger "info" "ERROR: error in backing up of \"${SOURCE_VMDK}\" for ${VM_NAME}"
                                        VM_VMDK_FAILED=1
                                    elif [[ ${VMDK_COMPRESS} -eq 1 ]] ; then
                                        vmdkCompr
                                        echo >>"${RSTR_PATH}" "#VAR: VMDK_COMPRESSED__${DISK_NO}=\"${COMPRESSION_EXT_FILE}\""
                                    fi
                                fi
                            else
                                echo >>"${RSTR_PATH}" "#WARN: A physical RDM \"${SOURCE_VMDK}\" was found for ${VM_NAME}, which will not be backed up"
                                logger "info" "WARNING: A physical RDM \"${SOURCE_VMDK}\" was found for ${VM_NAME}, which will not be backed up"
                                VM_VMDK_FAILED=1
                            fi
                        fi
                        let DISK_NO++
                        let n++
                    done
                fi

                #powered on VMs only w/snapshots
                if [[ ${SNAP_SUCCESS} -eq 1 ]] && [[ ! ${POWER_THIS_VM_DOWN_BEFORE_BACKUP} -eq 1 ]] && [[ "${ORGINAL_VM_POWER_STATE}" == "Powered on" ]] || [[ "${ORGINAL_VM_POWER_STATE}" == "Suspended" ]]; then
                    if [[ "${NEW_VIMCMD_SNAPSHOT}" == "yes" ]] ; then
                        SNAPSHOT_ID=$(${VMWARE_CMD} vmsvc/snapshot.get ${VM_ID} | grep -E '(Snapshot Name|Snapshot Id)' | grep -A1 ${SNAPSHOT_NAME} | grep "Snapshot Id" | awk -F ":" '{print $2}' | sed -e 's/^[[:blank:]]*//;s/[[:blank:]]*$//') #'
                        ${VMWARE_CMD} vmsvc/snapshot.remove ${VM_ID} ${SNAPSHOT_ID} > /dev/null 2>&1
                    else
                        ${VMWARE_CMD} vmsvc/snapshot.remove ${VM_ID} > /dev/null 2>&1
                    fi

#we remove LIVE SNAPSHOT after backup
                    if [[ -n "${LIVE_VM_BACKUP_SNAPSHOT_ID}" ]]; then
                        if [[ "${NEW_VIMCMD_SNAPSHOT}" == "yes" ]] ; then
                            ${VMWARE_CMD} vmsvc/snapshot.remove ${VM_ID} ${LIVE_VM_BACKUP_SNAPSHOT_ID} > /dev/null 2>&1
                        else
                            ${VMWARE_CMD} vmsvc/snapshot.remove ${VM_ID} > /dev/null 2>&1
                        fi
                    fi
                    #do not continue until all snapshots have been committed
                    logger "info" "Removing snapshot from ${VM_NAME} ..."
                    while ls "${VMX_DIR}" | grep -qF -- '-delta.vmdk' ; do
                        sleep 5
                    done
#we write back last snapshot uid to clean up backup process traces
                    [[ -n "${VM_LAST_SNAPSHOT_UID}" ]] && sed -i -r "s/^snapshot\.lastUID\s*=.*/snapshot.lastUID = \"${VM_LAST_SNAPSHOT_UID}\"/" "${VMSD_PATH}"
                fi

                if [[ ${POWER_VM_DOWN_BEFORE_BACKUP} -eq 1 ]] && [[ "${ORGINAL_VM_POWER_STATE}" == "Powered on" ]]; then
                    #power on vm that was powered off prior to backup
                    logger "info" "Powering back on ${VM_NAME}"
                    ${VMWARE_CMD} vmsvc/power.on ${VM_ID} > /dev/null 2>&1
                fi

                TMP_IFS=${IFS}
                IFS=${ORIG_IFS}
                if [[ ${ENABLE_THIS_COMPRESSION} -eq 1 ]] ; then
                    COMPRESSED_ARCHIVE_FILE="${BACKUP_DIR}/${VM_NAME_P}-${VM_BACKUP_DIR_NAMING_CONVENTION}.gz"

                    logger "info" "Compressing VM backup \"${COMPRESSED_ARCHIVE_FILE}\"..."
                    ${TAR} -cz -C "${BACKUP_DIR}" "${VM_NAME_P}-${VM_BACKUP_DIR_NAMING_CONVENTION}" -f "${COMPRESSED_ARCHIVE_FILE}"

                    # verify compression
                    if [[ $? -eq 0 ]] && [[ -f "${COMPRESSED_ARCHIVE_FILE}" ]]; then
                        logger "info" "Successfully compressed backup for ${VM_NAME}!\n"
                        COMPRESSED_OK=1
                    else
                        logger "info" "Error in compressing ${VM_NAME}!\n"
                        COMPRESSED_OK=0
                    fi
                    rm -rf "${VM_BACKUP_DIR}"
                    checkVMBackupRotation "${BACKUP_DIR}" "${VM_NAME_P}"
                else
                    checkVMBackupRotation "${BACKUP_DIR}" "${VM_NAME_P}"
                fi
                IFS=${TMP_IFS}
#reset DISK LIST
                VMDKS=""
                n=0
                while [[ $n -lt $VMDK_N ]]; do
                    eval "VMDK__$n="
                    eval "VMDK_SIZE__$n="
                    eval "VMDK_RID__$n="
                    let n++
                done
                VMDK_N=
                while [[ $n -lt $VMDK_XN ]]; do
                    eval "VMDK_X__$n="
                    eval "VMDK_SIZE__$n="
                    let n++
                done
                VMDK_XN=
                INDEP_VMDKS=""

                endTimer
                if [[ ${SNAP_SUCCESS} -ne 1 ]] ; then
                    logger "info" "ERROR: Unable to backup ${VM_NAME} due to snapshot creation!\n"
                    [[ ${ENABLE_THIS_COMPRESSION} -eq 1 ]] && [[ $COMPRESSED_OK -eq 1 ]] || echo "ERROR: Unable to backup ${VM_NAME} due to snapshot creation" >> ${VM_BACKUP_DIR}/STATUS.error
                    VM_FAILED=1
                elif [[ ${VM_VMDK_FAILED} -ne 0 ]] ; then
                    logger "info" "ERROR: Unable to backup ${VM_NAME} due to error in VMDK backup!\n"
                    [[ ${ENABLE_THIS_COMPRESSION} -eq 1 ]] && [[ $COMPRESSED_OK -eq 1 ]] || echo "ERROR: Unable to backup ${VM_NAME} due to error in VMDK backup" >> ${VM_BACKUP_DIR}/STATUS.error
                    VMDK_FAILED=1
                elif [[ ${VM_HAS_INDEPENDENT_DISKS} -eq 1 ]] ; then
                    logger "info" "WARN: ${VM_NAME} has some Independent VMDKs that can not be backed up!\n";
                    [[ ${ENABLE_THIS_COMPRESSION} -eq 1 ]] && [[ $COMPRESSED_OK -eq 1 ]] || echo "WARN: ${VM_NAME} has some Independent VMDKs that can not be backed up" > ${VM_BACKUP_DIR}/STATUS.warn
                    VMDK_FAILED=1

                    #create symlink for the very last backup to support rsync functionality for additinal replication
                    if [[ "${RSYNC_LINK}" -eq 1 ]] ; then
                        SYMLINK_DST=${VM_BACKUP_DIR}
                        if [[ ${ENABLE_THIS_COMPRESSION} -eq 1 ]]; then
                            SYMLINK_DST1="${RSYNC_LINK_DIR}.gz"
                        else
                            SYMLINK_DST1="${RSYNC_LINK_DIR}"
                        fi
                        SYMLINK_SRC="${BACKUP_DIR}/${VM_NAME_P}-symlink"
                        logger "info" "Creating symlink \"${SYMLINK_SRC}\" to \"${SYMLINK_DST1}\""
                        rm -f "${SYMLINK_SRC}"
                        ln -sfn "${SYMLINK_DST1}" "${SYMLINK_SRC}"
                    fi

                    #storage info after backup
                    storageInfo "after"
                else
                    logger "info" "Successfully completed backup for ${VM_NAME}!\n"

                    [[ ${ENABLE_THIS_COMPRESSION} -eq 1 ]] && [[ $COMPRESSED_OK -eq 1 ]] || echo -e "Successfully completed backup\nDuration: $((E_TIME-S1_TIME))sec" > ${VM_BACKUP_DIR}/STATUS.ok
                    VM_OK=1

                    #create symlink for the very last backup to support rsync functionality for additinal replication
                    if [[ "${RSYNC_LINK}" -eq 1 ]] ; then
                        SYMLINK_DST=${VM_BACKUP_DIR}
                        if [[ ${ENABLE_THIS_COMPRESSION} -eq 1 ]] ; then
                            SYMLINK_DST1="${RSYNC_LINK_DIR}.gz"
                        else
                            SYMLINK_DST1="${RSYNC_LINK_DIR}"
                        fi
                        SYMLINK_SRC="${BACKUP_DIR}/${VM_NAME_P}-symlink"
                        logger "info" "Creating symlink \"${SYMLINK_SRC}\" to \"${SYMLINK_DST1}\""
                        rm -f "${SYMLINK_SRC}"
                        ln -sfn "${SYMLINK_DST1}" "${SYMLINK_SRC}"
                    fi

                    if [[ "${BACKUP_FILES_CHMOD}" != "" ]]
                    then
                        chmod -R "${BACKUP_FILES_CHMOD}" "${VM_BACKUP_DIR}"
                    fi

                    #storage info after backup
                    storageInfo "after"
                fi
            else
                if [[ ${CONTINUE_TO_BACKUP} -eq 0 ]] ; then
                    logger "info" "ERROR: Failed to backup ${VM_NAME}!\n"
                    VM_FAILED=1
                else
                    logger "info" "ERROR: Failed to lookup ${VM_NAME}!\n"
                    VM_FAILED=1
                fi
            fi
        fi

		# Added the NFS_IO_HACK check and function call here.  Some NAS devices slow during the write of the files.
		# Added the Brute-force delay in case it is needed.
		if [[ "${ENABLE_NFS_IO_HACK}" -eq 1 ]]; then
			NfsIoHack
			sleep "${NFS_BACKUP_DELAY}" 
		fi 
    done
    # UNTESTED CODE
    # Why is this outside of the main loop & it looks like checkVMBackupRotation() could be called twice?
    #if [[ -n ${ADDITIONAL_ROTATION_PATH} ]]; then
    #    for VM_NAME in $(cat "${VM_INPUT}" | grep -v "#" | sed '/^$/d' | sed -e 's/^[[:blank:]]*//;s/[[:blank:]]*$//'); do
    #        BACKUP_DIR="${ADDITIONAL_ROTATION_PATH}/${VM_NAME}"
    #        # Do indexed rotation if naming convention is set for it
    #        if [[ ${VM_BACKUP_DIR_NAMING_CONVENTION} = "0" ]]; then
    #            indexedRotate "${BACKUP_DIR}" "${VM_NAME}"
    #        else
    #            checkVMBackupRotation "${BACKUP_DIR}" "${VM_NAME}"
    #        fi
    #    done
    #fi
    unset IFS

    if [[ ${#VM_STARTUP_ORDER} -gt 0 ]] && [[ "${LOG_LEVEL}" != "dryrun" ]]; then
        logger "debug" "VM Startup Order: ${VM_STARTUP_ORDER}\n"
        IFS=","
        for VM_NAME in ${VM_STARTUP_ORDER}; do
            VM_ID=$(grep -E "\"${VM_NAME}\"" ${WORKDIR}/vms_list | awk -F "\t" '{print $1}' | sed 's/"//g')
            powerOn "${VM_NAME}" "${VM_ID}"
            if [[ ${POWER_ON_EC} -eq 1 ]]; then
                logger "info" "Unable to detect fully powered on VM ${VM_NAME}\n"
            fi
        done
        unset IFS
    fi

    if [[ ${ENABLE_NON_PERSISTENT_NFS} -eq 1 ]] && [[ ${UNMOUNT_NFS} -eq 1 ]] && [[ "${LOG_LEVEL}" != "dryrun" ]]; then
        logger "debug" "Sleeping for 30seconds before unmounting NFS volume"
        sleep 30
        ${VMWARE_CMD} hostsvc/datastore/destroy ${NFS_LOCAL_NAME}
    fi
}

getFinalStatus() {
    if [[ "${LOG_TYPE}" == "dryrun" ]]; then
        FINAL_STATUS="###### Final status: OK, only a dryrun. ######"
        LOG_STATUS="OK"
        EXIT=0
    elif [[ "${VM_OK}" == 1 ]] && [[ $VM_FAILED == 0 ]] && [[ $VMDK_FAILED == 0 ]]; then
        FINAL_STATUS="###### Final status: All VMs backed up OK! ######"
        LOG_STATUS="OK"
        EXIT=0
    elif [[ "${VM_OK}" == 1 ]] && [[ $VM_FAILED == 0 ]] && [[ $VMDK_FAILED == 1 ]]; then
        FINAL_STATUS="###### Final status: WARNING: All VMs backed up, but some disk(s) failed! ######"
        LOG_STATUS="WARNING"
        EXIT=3
    elif [[ "${VM_OK}" == 1 ]] && [[ $VM_FAILED == 1 ]] && [[ $VMDK_FAILED == 0 ]]; then
        FINAL_STATUS="###### Final status: ERROR: Only some of the VMs backed up! ######"
        LOG_STATUS="ERROR"
        EXIT=4
    elif [[ "${VM_OK}" == 1 ]] && [[ $VM_FAILED == 1 ]] && [[ $VMDK_FAILED == 1 ]]; then
        FINAL_STATUS="###### Final status: ERROR: Only some of the VMs backed up, and some disk(s) failed! ######"
        LOG_STATUS="ERROR"
        EXIT=5
    elif [[ "${VM_OK}" == 0 ]] && [[ $VM_FAILED == 1 ]]; then
        FINAL_STATUS="###### Final status: ERROR: All VMs failed! ######"
        LOG_STATUS="ERROR"
        EXIT=6
    elif [[ "${VM_OK}" == 0 ]]; then
        FINAL_STATUS="###### Final status: ERROR: No VMs backed up! ######"
        LOG_STATUS="ERROR"
        EXIT=7
    fi
    logger "info" "$FINAL_STATUS\n"
}

replaceTokens() {
    echo "${1}" | awk -vv0="$(basename "$0" .sh)" -vvh="$(hostname -s)" -vvS="${FINAL_STATUS}" -vvs="$(echo "${FINAL_STATUS}" | sed -re 's/^.*Final status: //; s/ #+$//')" '{gsub(/%%0/, v0); gsub(/%%h/, vh); gsub(/%%S/, vS); gsub(/%%s/, vs); print}'
}

buildHeaders() {
    EMAIL_MAIL_FROM="MAIL FROM: $(echo "${EMAIL_FROM_1}" | sed -re 's/^.*<//; s/>.*//')\r\n"
    EMAIL_RCPT_TO=
    addr="$(echo "${EMAIL_TO}" | sed -re 's/\s*[,;]\s*/\n/')"
    while [[ -n "${addr}" ]]
    do
        rcpt_to="$(echo "${addr}" | head -1 | sed -re 's/^.*<//; s/>.*//')"
        [[ -n "${rcpt_to}" ]] && EMAIL_RCPT_TO="${EMAIL_RCPT_TO}RCPT TO: ${rcpt_to}\r\n"
        addr="$(echo "${addr}" | sed -re '1d')"
    done

    echo -ne "HELO $(hostname -s)\r\n" > "${EMAIL_LOG_HEADER}"
    echo -ne "EHLO $(hostname -s)\r\n" >> "${EMAIL_LOG_HEADER}"
    if [[ "${EMAIL_AUTH}" = 'plain' ]] ; then
        echo -ne "AUTH PLAIN\r\n" >> "${EMAIL_LOG_HEADER}"
        echo -ne "$(echo -ne "\0${EMAIL_USER_NAME}\0${EMAIL_USER_PASSWORD}" | openssl base64 2>&1 |tail -1)\r\n" >> "${EMAIL_LOG_HEADER}"
    elif [[ "${EMAIL_AUTH}" = 'login' ]] ; then
        echo -ne "AUTH LOGIN\r\n" >> "${EMAIL_LOG_HEADER}"
        echo -ne "$(echo -n "${EMAIL_USER_NAME}" |openssl base64 2>&1 |tail -1)\r\n" >> "${EMAIL_LOG_HEADER}"
        echo -ne "$(echo -n "${EMAIL_USER_PASSWORD}" |openssl base64 2>&1 |tail -1)\r\n" >> "${EMAIL_LOG_HEADER}"
    fi
    echo -ne "${EMAIL_MAIL_FROM}" >> "${EMAIL_LOG_HEADER}"
    echo -ne "${EMAIL_RCPT_TO}" >> "${EMAIL_LOG_HEADER}"
    echo -ne "DATA\r\n" >> "${EMAIL_LOG_HEADER}"
    echo -ne "From: ${EMAIL_FROM_1}\r\n" >> "${EMAIL_LOG_HEADER}"
    echo -ne "To: ${EMAIL_TO}\r\n" >> "${EMAIL_LOG_HEADER}"
    echo -ne "Subject: $(replaceTokens "${EMAIL_SUBJ}")\r\n" >> "${EMAIL_LOG_HEADER}" #"
    echo -ne "Date: $( date +"%a, %d %b %Y %T %z" )\r\n" >> "${EMAIL_LOG_HEADER}"
    echo -ne "Message-Id: <$( date -u +%Y%m%d%H%M%S ).$( dd if=/dev/urandom bs=6 count=1 2>/dev/null | hexdump -e '/1 "%02X"' )@$( hostname -f )>\r\n" >> "${EMAIL_LOG_HEADER}"
    echo -ne "XMailer: ghettoVCB ${VERSION_STRING}\r\n" >> "${EMAIL_LOG_HEADER}"
    echo -en "\r\n" >> "${EMAIL_LOG_HEADER}"

    echo -en ".\r\n" >> "${EMAIL_LOG_OUTPUT}"
    echo -en "QUIT\r\n" >> "${EMAIL_LOG_OUTPUT}"

    cat "${EMAIL_LOG_HEADER}" > "${EMAIL_LOG_CONTENT}"
    cat "${EMAIL_LOG_OUTPUT}" >> "${EMAIL_LOG_CONTENT}"
}

sendDelay() {
    DELAY=1
    sleep $((4 * EMAIL_DELAY_INTERVAL))
    while read L; do
        [[ ${DELAY} = 1 ]] && sleep ${EMAIL_DELAY_INTERVAL}
        [[ -z "${L##DATA*}" ]] && DELAY=0
        echo "$L"
    done
    sleep $((4 * EMAIL_DELAY_INTERVAL))
}

sendMail() {
    SMTP=0
    #close email message
    if [[ "${EMAIL_LOG}" -eq 1 ]] || [[ "${EMAIL_ALERT}" -eq 1 ]] ; then
        SMTP=1
        #validate firewall has email port open for ESXi 5
        if [[ "${VER}" == "5" ]] || [[ "${VER}" == "6" ]] || [[ "${VER}" == "7" ]]; then
            /sbin/esxcli network firewall ruleset rule list | awk -F'[ ]{2,}' '{print $5}' | grep "^${EMAIL_SERVER_PORT}$" > /dev/null 2>&1
            if [[ $? -eq 1 ]] ; then
                logger "info" "ERROR: Please enable firewall rule for email traffic on port ${EMAIL_SERVER_PORT}\n"
                logger "info" "Please refer to ghettoVCB documentation for ESXi 5 firewall configuration\n"
                SMTP=0
            fi
        fi
    fi

    if [[ "${SMTP}" -eq 1 ]] ; then
        if [ "${EXIT}" -ne 0 ] && [ "${LOG_STATUS}" = "OK" ] ; then
            LOG_STATUS="ERROR"
        #    for i in ${EMAIL_TO}; do
        #        buildHeaders ${i}
        #        cat "${EMAIL_LOG_CONTENT}" | sendDelay| "${NC_BIN}" "${EMAIL_SERVER}" "${EMAIL_SERVER_PORT}" > /dev/null 2>&1
        #        #"${NC_BIN}" -i "${EMAIL_DELAY_INTERVAL}" "${EMAIL_SERVER}" "${EMAIL_SERVER_PORT}" < "${EMAIL_LOG_CONTENT}" > /dev/null 2>&1
        #        if [[ $? -eq 1 ]] ; then
        #            logger "info" "ERROR: Failed to email log output to ${EMAIL_SERVER}:${EMAIL_SERVER_PORT} to ${EMAIL_TO}\n"
        #        fi
        #    done
        fi

        EMAIL_FROM_1=$(replaceTokens "${EMAIL_FROM}")
        if [ "${EMAIL_ERRORS_TO}" != "" ] && [ "${LOG_STATUS}" != "OK" ] ; then
            if [ "${EMAIL_TO}" == "" ] ; then
                EMAIL_TO="${EMAIL_ERRORS_TO}"
            else
                EMAIL_TO="${EMAIL_TO},${EMAIL_ERRORS_TO}"
                EMAIL_SUBJ="${EMAIL_SUBJ_ERROR}"
            fi
        fi

        buildHeaders ${i}
        cat "${EMAIL_LOG_CONTENT}" >/tmp/smtp.txt
        if [[ ${EMAIL_STARTTLS} -eq 1 ]] ; then
            cat "${EMAIL_LOG_CONTENT}" | sendDelay | openssl s_client -connect "${EMAIL_SERVER}":"${EMAIL_SERVER_PORT}" -ign_eof -verify false -starttls smtp >/dev/null 2>&1
        else
            cat "${EMAIL_LOG_CONTENT}" | sendDelay | "${NC_BIN}" "${EMAIL_SERVER}" "${EMAIL_SERVER_PORT}" > /dev/null 2>&1
        fi
        #"${NC_BIN}" -i "${EMAIL_DELAY_INTERVAL}" "${EMAIL_SERVER}" "${EMAIL_SERVER_PORT}" < "${EMAIL_LOG_CONTENT}" > /dev/null 2>&1
        if [[ $? -eq 1 ]] ; then
            logger "info" "ERROR: Failed to email log output to ${EMAIL_SERVER}:${EMAIL_SERVER_PORT} to ${EMAIL_TO}\n"
        fi
    fi
}

#########################
#                       #
# Start of Main Script  #
#                       #
#########################

startTimer
AS_TIME=$S_TIME

# If the NFS_IO_HACK is disabled, this restores the original script settings.
if [[ "${ENABLE_NFS_IO_HACK}" -eq 0 ]]; then
    NFS_IO_HACK_LOOP_MAX=60
    NFS_IO_HACK_SLEEP_TIMER=1
fi

USE_VM_CONF=0
USE_GLOBAL_CONF=0
BACKUP_ALL_VMS=0
EXCLUDE_SOME_VMS=0

# quick sanity check on the number of arguments
if [[ $# -lt 1 ]] || [[ $# -gt 12 ]]; then
    printUsage
    LOG_TO_STDOUT=1 logger "info" "ERROR: Incorrect number of arguments!"
    exit 1
fi

#Quick sanity check for the VM_BACKUP_ROTATION_COUNT configuration setting.
if [[ "$VM_BACKUP_ROTATION_COUNT" -lt 1 ]]; then
	VM_BACKUP_ROTATION_COUNT=1
fi

#Sanity check for full qualified email and adjust EMAIL_FROM to be hostname@domain.com if username is missing.
if [[ "${EMAIL_FROM%%@*}" == "" ]] ; then
    EMAIL_FROM="`hostname -s`$EMAIL_FROM"
fi

#read user input
while getopts ":af:c:g:w:m:l:d:e:x" ARGS; do
    case $ARGS in
        w)
            WORKDIR="${OPTARG}"
            ;;
        a)
            BACKUP_ALL_VMS=1
            VM_FILE='${WORKDIR}/vm-input-list'
            ;;
        f)
            VM_FILE="${OPTARG}"
            ;;
        m)
            VM_FILE='${WORKDIR}/vm-input-list'
            VM_ARG="${OPTARG}"
            ;;
        e)
            VM_EXCLUSION_FILE="${OPTARG}"
            EXCLUDE_SOME_VMS=1
            ;;
        c)
            CONFIG_DIR="${OPTARG}"
            USE_VM_CONF=1
            ;;
        g)
            GLOBAL_CONF="${OPTARG}"
            USE_GLOBAL_CONF=1
            ;;
        l)
            LOG_OUTPUT="${OPTARG}"
            ;;
        d)
            LOG_LEVEL="${OPTARG}"
            ;;
        x)
            IGNORE_VMX_OPTIONS=1
            ;;
        :)
            echo "Option -${OPTARG} requires an argument."
            exit 1
            ;;
        *)
            printUsage
            ;;
    esac
done

WORKDIR=${WORKDIR:-"/tmp/ghettoVCB.work"}

EMAIL_LOG_HEADER=${WORKDIR}/ghettoVCB-email-$$.header
EMAIL_LOG_OUTPUT=${WORKDIR}/ghettoVCB-email-$$.log
EMAIL_LOG_CONTENT=${WORKDIR}/ghettoVCB-email-$$.content

#expand VM_FILE
[[ -n "${VM_FILE}" ]] && VM_FILE=$(eval "echo ${VM_FILE}")

# refuse to run with an unsafe workdir
if [[ "${WORKDIR}" == "/" ]]; then
    echo "ERROR: Refusing to run with unsafe workdir ${WORKDIR}"
    exit 1
fi

if mkdir "${WORKDIR}"; then
    # create VM_FILE if we're backing up everything/specified a vm on the command line
    [[ $BACKUP_ALL_VMS -eq 1 ]] && touch ${VM_FILE}
    [[ -n "${VM_ARG}" ]] && echo "${VM_ARG}" > "${VM_FILE}"

    if [[ "${WORKDIR_DEBUG}" -eq 1 ]] ; then
        LOG_TO_STDOUT=1 logger "info" "Workdir: ${WORKDIR} will not! be removed on exit"
    else
        # remove workdir when script finishes
        trap 'rm -rf "${WORKDIR}"' 0
    fi

    # verify that we're running in a sane environment
    sanityCheck

    GHETTOVCB_PID=$$
    echo $GHETTOVCB_PID > "${WORKDIR}/pid"

    logger "info" "============================== ghettoVCB LOG START ==============================\n"
    logger "debug" "Succesfully acquired lock directory - ${WORKDIR}\n"

    # terminate script and remove workdir when a signal is received
    trap 'rm -rf "${WORKDIR}" ; exit 2' 1 2 3 13 15

    ghettoVCB ${VM_FILE}

    AE_TIME=$(date +%s)
    DURATION=$((AE_TIME-AS_TIME))
    if [[ ${DURATION} -le 60 ]] ; then
        logger "info" "Full running time: ${DURATION} Seconds"
    else
        logger "info" "Full running time: $(awk 'BEGIN{ printf "%.2f\n", '${DURATION}'/60}') Minutes"
    fi
    Get_Final_Status_Sendemail

    # practically redundant
    [[ "${WORKDIR_DEBUG}" -eq 0 ]] && rm -rf "${WORKDIR}"
    exit $EXIT
else
    logger "info" "Failed to acquire lock, another instance of script may be running, giving up on ${WORKDIR}\n"
    Get_Final_Status_Sendemail
    exit 1
fi
