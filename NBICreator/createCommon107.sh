# createCommon.sh
# 
# Common functionality for the Image creation process.
# sourced in by the various SIU scripts
#
# Copyright © 2007-2011 Apple Inc. All rights reserved.


##
# Using dscl, create a user account
##
AddLocalUser()
{
	# $1 volume whose local node database to modify
	# $2 long name
	# $3 short name
	# $4 isAdminUser key
	# $5 password data
	# $6 password hint
	# $7 user picture path
	# $8 Language string

	local databasePath="/Local/Default/Users/${3}"
	local targetVol="${1}"

	# Find a free UID between 501 and 599
	for ((i=501; i<600; i++)); do
		output=`/usr/bin/dscl -f "${targetVol}/var/db/dslocal/nodes/Default" localonly -search /Local/Default/Users UniqueID $i`
		# If there is already an account dscl returns it, so we're looking for an empty return value.
		if [ "$output" == "" ]; then
			break
		fi
	done

	# Create the user record
	/usr/bin/dscl -f "${targetVol}/var/db/dslocal/nodes/Default" localonly -create $databasePath
	if [ $? != 0 ]; then
		echo "Failed to create '${databasePath}'."
		return 1
	fi

	# Add long name
	/usr/bin/dscl -f "${targetVol}/var/db/dslocal/nodes/Default" localonly -append $databasePath RealName "${2}"
	if [ $? != 0 ]; then
		echo "Failed to set the RealName."
		return 1
	fi

	# Add PrimaryGroupID
	if [ "${4}" == 1 ]; then 
		/usr/bin/dscl -f "${targetVol}/var/db/dslocal/nodes/Default" localonly -append $databasePath PrimaryGroupID 80
	else
		/usr/bin/dscl -f "${targetVol}/var/db/dslocal/nodes/Default" localonly -append $databasePath PrimaryGroupID 20
	fi
	if [ $? != 0 ]; then
		echo "Failed to set the PrimaryGroupID."
		return 1
	fi

	# Add UniqueID
	/usr/bin/dscl -f "${targetVol}/var/db/dslocal/nodes/Default" localonly -append $databasePath UniqueID ${i}
	if [ $? != 0 ]; then
		echo "Failed to set the UniqueID."
		return 1
	fi

	# Add Home Directory entry
	/usr/bin/dscl -f "${targetVol}/var/db/dslocal/nodes/Default" localonly -append $databasePath NFSHomeDirectory /Users/${3}
	if [ $? != 0 ]; then
		echo "Failed to set the NFSHomeDirectory."
	fi

	if [ "${6}" != "" ]; then 
		/usr/bin/dscl -f "${targetVol}/var/db/dslocal/nodes/Default" localonly -append $databasePath AuthenticationHint "${6}"
		if [ $? != 0 ]; then
			echo "Failed to set the AuthenticationHint."
			return 1
		fi
	fi

	/usr/bin/dscl -f "${targetVol}/var/db/dslocal/nodes/Default" localonly -append $databasePath picture "${7}"
	if [ $? != 0 ]; then
		echo "Failed to set the picture."
		return 1
	fi

	/usr/bin/dscl -f "${targetVol}/var/db/dslocal/nodes/Default" localonly -passwd $databasePath "${5}"
	if [ $? != 0 ]; then
		echo "Failed to set the passwd."
		return 1
	fi

	# Add shell
	/usr/bin/dscl -f "${targetVol}/var/db/dslocal/nodes/Default" localonly -append $databasePath UserShell "/bin/bash"
	if [ $? != 0 ]; then
		echo "Failed to set the UserShell."
		return 1
	fi

	# Create Home directory
	if [ -e "/System/Library/User Template/${8}.lproj/" ]; then
		/usr/bin/ditto "/System/Library/User Template/${8}.lproj/" "${targetVol}/Users/${3}"
	else
		/usr/bin/ditto "/System/Library/User Template/English.lproj/" "${targetVol}/Users/${3}"
	fi
	if [ $? != 0 ]; then
		echo "Failed to copy the User Template."
		return 1
	fi

	/usr/sbin/chown -R $i:$i "${targetVol}/Users/${3}"
	if [ $? != 0 ]; then
		echo "Failed to set ownership on the User folder."
		return 1
	fi
}


##
# Copies a list of files (full paths contained in the file at $1) from source to the path specified in $2
##
CopyEntriesFromFileToPath()
{
	local theFile="$1"
	local theDest="$2"
	local opt=""

	if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
		opt="-v"
	fi

	while read FILE
	do
		if [ -e "${FILE}" ]; then
			local leafName=`basename "${FILE}"`

			if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then 
				echo "Copying ${FILE}."
			fi

			/usr/bin/ditto $opt "${FILE}" "${theDest}/${leafName}" || return 1
		fi
	done < "${theFile}"

	return 0
}


##
# Copies a list of packages (full path, destination pairs contained in the file at $1) from source to .../System/Installation/Packages/
##
CopyPackagesWithDestinationsFromFile()
{
	local theFile="$1"
	local opt=""

	if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
		opt="-v"
	fi

	while read FILE
	do
		if [ -e "${FILE}" ]; then
			local leafName=`basename "${FILE}"`

			if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
				echo "Copying ${FILE}."
			fi

			read SUB_PATH
			/usr/bin/ditto $opt "${FILE}" "${mountPoint}/Packages/${SUB_PATH}${leafName}" || return 1
		fi
	done < "${theFile}"

	return 0
}


##
# Create an installer package in ${1} wrapping the supplied script ${2}
##
CreateInstallPackageForScript()
{
	local tempDir="$1"
	local scriptPath="$2"
	local scriptName=`basename "${scriptPath}"`
	local entryDir=`pwd`
	local opt=""

	if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
		echo "Create installer for script ${scriptName}"

		if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
			opt="-v"
		fi
	fi

	# shouldn't exist on entry...
	if [ -e "${tempDir}/emptyDir" ]; then
		/bin/rm -rf "${tempDir}/emptyDir"
	fi

	# make some directories to work in
	/bin/mkdir $opt -p "${tempDir}/${scriptName}.pkg/Contents/Resources" || return 1
	/bin/mkdir $opt "${tempDir}/emptyDir" || return 1

	# Create Archive.pax.gz
	cd "${tempDir}/emptyDir"
	/bin/pax -w -x cpio -f "${tempDir}/${scriptName}.pkg/Contents/Archive.pax" .
	/usr/bin/gzip "${tempDir}/${scriptName}.pkg/Contents/Archive.pax"
	cd "${entryDir}"

	# Create the Archive.bom file
	/usr/bin/mkbom "${tempDir}/emptyDir/" "${tempDir}/${scriptName}.pkg/Contents/Archive.bom" || return 1

	# Create the Info.plist
	/bin/cat > "${tempDir}/${scriptName}.pkg/Contents/Info.plist" << END
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
		<key>CFBundleIdentifier</key>
		<string>com.apple.server.SystemImageUtility.${scriptName}</string>
		<key>CFBundleShortVersionString</key>
		<string>1</string>
		<key>IFMajorVersion</key>
		<integer>1</integer>
		<key>IFMinorVersion</key>
		<integer>0</integer>
		<key>IFPkgFlagDefaultLocation</key>
		<string>/tmp</string>
		<key>IFPkgFlagInstallFat</key>
		<false/>
		<key>IFPkgFlagIsRequired</key>
		<false/>
		<key>IFPkgFormatVersion</key>
		<real>0.10000000149011612</real>
	</dict>
	</plist>
END

	echo "pkmkrpkg1" > "${tempDir}/${scriptName}.pkg/Contents/PkgInfo"
	echo "major: 1\nminor: 0" > "${tempDir}/${scriptName}.pkg/Contents/Resources/package_version"
	# Copy the script
	/bin/cp "$scriptPath" "${tempDir}/${scriptName}.pkg/Contents/Resources/postflight"

	# clean up
	/bin/rm -r "${tempDir}/emptyDir"

	return 0
}


##
# Validate or create the requested directory
##
CreateOrValidatePath()
{
	local targetDir="$1"

	if [ ! -d "${targetDir}" ]; then
		if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
			echo "Creating working path at ${targetDir}"
		fi
		/bin/mkdir -p "${targetDir}" || return 1
	fi
}


##
# If any exist, apply any user accounts
##
CreateUserAccounts()
{
	# $1 volume whose local node database to modify

	local count="${#userFullName[*]}"
	local targetVol="${1}"

	if [ $count -gt 0 ]; then
		if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
			echo "Adding $count user account(s) to the image"
		fi

		for ((index=0; index<$count; index++)); do
			if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
				echo "Adding user ${userFullName[$index]}"
			fi

			#lay down user here
			AddLocalUser "${targetVol}" "${userFullName[$index]}" "${userUnixName[$index]}" "${userIsAdmin[$index]}" "${userPassword[$index]}" "${userPassHint[$index]}" "${userImagePath[$index]}" "${userLanguage[$index]}"
			if [ $? != 0 ]; then
				echo "Failed to create the User '${userUnixName[$index]}'."
				return 1
			fi
		done

		# "touch"
		/usr/bin/touch "${targetVol}/private/var/db/.AppleSetupDone" 
		/usr/bin/touch "${targetVol}/Library/Receipts/.SetupRegComplete"
	fi
}


##
# retry the hdiutil detach until we either time out or it succeeds
##
retry_hdiutil_detach() 
{
	local mount_point="${1}"
	local tries=0
	local forceAt=0
	local limit=24
	local opt=""

	forceAt=$(($limit - 1))
	while [ $tries -lt $limit ]; do
		tries=$(( tries + 1 ))
		/bin/sleep 5
		echo "Attempting to detach the disk image again..."
		/usr/bin/hdiutil detach "${mount_point}" $opt
		if [ $? -ne 0 ]; then
			# Dump a list of any still open files on the mountPoint
			if [ "${scriptsDebugKey}" == "DEBUG" ]; then
				/usr/sbin/lsof +fg "${mount_point}"
			fi

			if [ $tries -eq $forceAt ]; then
				echo "Failed to detach disk image at '${mount_point}' normally, adding -force."
				opt="-force"
			fi

			if [ $tries -eq $limit ]; then
				echo "Failed to detach disk image at '${mount_point}'."
				exit 1
			fi
		else
			tries=$limit
		fi
	done
}
 

##
# Create the dyld shared cache files
##
DetachAndRemoveMount()
{
	local theMount="${1}"

	if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
		echo "Detaching disk image"

		# Dump a list of any still open files on the mountPoint
		if [ "${scriptsDebugKey}" == "DEBUG" ]; then
			/usr/sbin/lsof +fg "${theMount}"
		fi
	fi

	# Finally detach the image and dispose the mountPoint directory
	/usr/bin/hdiutil detach "${theMount}" || retry_hdiutil_detach "${theMount}" || return 1
	/bin/rmdir "${theMount}" || return 1

	return 0
}


##
# If the pieces exist, enable remote access for the shell image
##
EnableRemoteAccess()
{
	local srcVol="${1}"
	local opt=""

	if [ -e "${srcVol}/usr/lib/pam/pam_serialnumber.so.2" ]; then
		if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
			echo "Enabling shell image remote access support"

			if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
				opt="-v"
			fi
		fi

		# install some things (again which aren't part of BaseSystem) needed for remote ASR installs
		/usr/bin/ditto $opt "${srcVol}/usr/lib/pam/pam_serialnumber.so.2" "${mountPoint}/usr/lib/pam/pam_serialnumber.so.2" || return 1

		if [ -e "${srcVol}/usr/sbin/installer" ]; then
			/usr/bin/ditto $opt "${srcVol}/usr/sbin/installer" "${mountPoint}/usr/sbin/installer" || return 1
		fi

		# copy the sshd config and add our keys to the end of it
		if [ -e "${srcVol}/etc/sshd_config" ]; then
			/bin/cat "${srcVol}/etc/sshd_config" - > "${mountPoint}/etc/sshd_config" << END

HostKey /private/var/tmp/ssh_host_key
HostKey /private/var/tmp/ssh_host_rsa_key
HostKey /private/var/tmp/ssh_host_dsa_key
END
		fi
	fi

	return 0
}


##
# If it exists, install the sharing names and/or directory binding support to the install image
##
HandleNetBootClientHelper()
{
	local tempDir="${1}"
	local targetVol="${2}"
	local opt=""

	if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
		opt="-v"
	fi

	if [ -e  "${tempDir}/bindingNames.plist" ]; then
		if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
			echo "Installing Directory Service binding information"
		fi

		/usr/bin/ditto $opt "${tempDir}/bindingNames.plist" "${targetVol}/etc/bindingNames.plist" || return 1
		/usr/sbin/chown root:wheel "${targetVol}/etc/bindingNames.plist"
		/bin/chmod 644 "${targetVol}/etc/bindingNames.plist"
	fi

	if [ -e  "${tempDir}/sharingNames.plist" ]; then
		if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
			echo "Installing Sharing Names support"
		fi

		/usr/bin/ditto $opt "${tempDir}/sharingNames.plist" "${targetVol}/etc/sharingNames.plist" || return 1
		/usr/sbin/chown root:wheel "${targetVol}/etc/sharingNames.plist"
		/bin/chmod 644 "${targetVol}/etc/sharingNames.plist"
	fi

	if [ -e  "${tempDir}/NetBootClientHelper" ]; then
		/usr/bin/ditto $opt "${tempDir}/NetBootClientHelper" "${targetVol}/usr/sbin/NetBootClientHelper" || return 1
		/usr/sbin/chown root:wheel "${targetVol}/usr/sbin/NetBootClientHelper"
		/bin/chmod 555 "${targetVol}/usr/sbin/NetBootClientHelper"
		/usr/bin/ditto $opt "${tempDir}/com.apple.NetBootClientHelper.plist" "${targetVol}/System/Library/LaunchDaemons/com.apple.NetBootClientHelper.plist" || return 1
		/usr/sbin/chown root:wheel "${targetVol}/System/Library/LaunchDaemons/com.apple.NetBootClientHelper.plist"
		/bin/chmod 644 "${targetVol}/System/Library/LaunchDaemons/com.apple.NetBootClientHelper.plist"

		# finally, make sure it isn't disabled...
		/usr/libexec/PlistBuddy -c "Delete :com.apple.NetBootClientHelper" "${targetVol}/var/db/launchd.db/com.apple.launchd/overrides.plist" > /dev/null 2>&1
	fi

	return 0
}


##
# If any exist, install configuration profiles to the install image
##
InstallConfigurationProfiles()
{
	local tempDir="${1}"
	local targetVol="${2}"
	local profilesDir="${targetVol}/var/db/ConfigurationProfiles"
	local opt=""

	if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
		opt="-v"
	fi

	if [ -e  "${tempDir}/configProfiles.txt" ]; then
		if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
			echo "Installing Configuration Profiles"
		fi

		/bin/mkdir -p "${profilesDir}/Setup" || return 1
		# Make sure the perms are correct
		/usr/sbin/chown root:wheel "${profilesDir}"
		/bin/chmod 755 "${profilesDir}"
		/usr/sbin/chown root:wheel "${profilesDir}/Setup"
		/bin/chmod 755 "${profilesDir}/Setup"

		/usr/bin/touch "${profilesDir}/.profilesAreInstalled"
		CopyEntriesFromFileToPath "${tempDir}/configProfiles.txt" "${profilesDir}/Setup" || return 1

		# Enable MCX debugging
		if [ 1 == 1 ]; then
			if [ -e  "${targetVol}/Library/Preferences/com.apple.MCXDebug.plist" ]; then
				/usr/libexec/PlistBuddy -c "Delete :debugOutput" "${targetVol}/Library/Preferences/com.apple.MCXDebug.plist" > /dev/null 2>&1
				/usr/libexec/PlistBuddy -c "Delete :collateLogs" "${targetVol}/Library/Preferences/com.apple.MCXDebug.plist" > /dev/null 2>&1
			fi

			/usr/libexec/PlistBuddy -c "Add :debugOutput string -2" "${targetVol}/Library/Preferences/com.apple.MCXDebug.plist" > /dev/null 2>&1
			/usr/libexec/PlistBuddy -c "Add :collateLogs string 1" "${targetVol}/Library/Preferences/com.apple.MCXDebug.plist" > /dev/null 2>&1
		fi
	fi
}


##
# Converts a list of scripts (full paths contained in the file at $1) into packages in $3
##
InstallScriptsFromFile()
{
	local tempDir="${1}"
	local theFile="${2}"
	local targetDir="${3}"

	if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then 
		echo "Converting scripts into install packages"
	fi

	while read FILE
	do
		if [ -e "${FILE}" ]; then
			# make an installer package out of the script
			CreateInstallPackageForScript "$tempDir" "${FILE}" || return 1

			# copy the resulting package to the Packages directory
			local leafName=`basename "${FILE}"`
			/usr/bin/ditto $opt "${tempDir}/${leafName}.pkg" "${targetDir}/${leafName}.pkg" || return 1

			# clean up
			/bin/rm -r "${tempDir}/${leafName}.pkg"
		fi
	done < "${theFile}"

	return 0
}


##
# Prepare the source by deleting stuff we don't want to copy if sourcing a volume
##
PostFlightDestination()
{
	local tempDir="${1}"
	local destDir="${2}"
	local opt=""

	if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
		echo "Performing post install cleanup"
		if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ] ; then 
			opt="-v"
		fi
	fi

	# delete the DS indices to force reindexing...
	if [ -e "${mountPoint}/var/db/dslocal/indices/Default/index" ]; then
		/bin/rm $opt "${mountPoint}/var/db/dslocal/indices/Default/index"
	fi

	# detach the disk and remove the mount folder
	DetachAndRemoveMount "${mountPoint}"
	if [ $? != 0 ]; then
		echo "Failed to detach and clean up the mount at '${mountPoint}'."
		return 1
	fi

	echo "Correcting permissions. ${ownershipInfoKey} $destDir"
	/usr/sbin/chown -R "${ownershipInfoKey}" "$destDir"
}


##
# Prepare the source by deleting stuff we don't want to copy if sourcing a volume
##
PreCleanSource()
{
	local srcVol="$1"
	local opt=""

	if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
		if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ] ; then 
			opt="-v"
		fi
	fi

	if [ -e "$srcVol/private/var/vm/swapfile*" ]; then
		if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
			echo "Removing swapfiles on $1"
		fi
		/bin/rm $opt "$srcVol/private/var/vm/swapfile*"
	fi

	if [ -d "$srcVol/private/tmp" ]; then
		if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
			echo "Cleaning out /private/tmp on $1"
		fi
		/bin/rm -r $opt "$srcVol/private/tmp/*"
	fi

	if [ -d "$srcVol/private/var/tmp" ]; then
		if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
			echo "Cleaning out /private/var/tmp on $1"
		fi
		/bin/rm -r $opt "$srcVol/private/var/tmp/*"
	fi

	if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
		echo "Cleaning out devices and volumes on $1"
	fi
	if [ -d "$srcVol/Volumes" ]; then
		/bin/rm -r $opt "$srcVol/Volumes/*"
	fi
	if [ -d "$srcVol/dev" ]; then
		/bin/rm $opt "$srcVol/dev/*"
	fi
	if [ -d "$srcVol/private/var/run" ]; then
		/bin/rm -r $opt "$srcVol/private/var/run/*"
	fi
}


##
# Copy kernel and build the kext cache on the boot image
##
PrepareKernelAndKextCache()
{
	local srcDir="$1"
	local destDir="$2"
	local opt=""

	if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
		echo "Preparing the kernel and kext cache for the boot image"

		if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
			opt="-v"
		fi
	fi

	# Insure the kext cache on our source volume (the boot shell) is up to date
	if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
		echo "Updating kext cache on source volume"
	fi
	/usr/sbin/kextcache -update-volume "${srcDir}" || return 1

	# Copy the i386 and, if it exists, the x86_64 architecture
	if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
		echo "Installing the kext cache to the boot image"
	fi

	# make sure this doesn't exist
	if [ -e "${destDir}/i386" ]; then
		/bin/rm -rf "${destDir}/i386"
	fi

	# Install kextcaches to the nbi folder
	if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
		echo "Creating a kernelcache for the boot shell"
	fi

	/bin/mkdir -p $opt "${destDir}/i386/x86_64" || return 1
	/usr/sbin/kextcache -arch i386 -L -N -S -z -K "${srcDir}/mach_kernel" -c "${destDir}/i386/kernelcache" "${srcDir}/System/Library/Extensions" || return 1
	/usr/sbin/kextcache -arch x86_64 -L -N -S -z -K "${srcDir}/mach_kernel" -c "${destDir}/i386/x86_64/kernelcache" "${srcDir}/System/Library/Extensions" || return 1
}


##
# Create the i386 and x86_64 boot loaders on the boot image
##
PrepareBootLoader()
{
	local srcVol="$1"
	local destDir="$2"
	local opt=""

	if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
		echo "Preparing boot loader"

		if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
			opt="-v"
		fi
	fi

	# Copy the i386 and, by default, the x86_64 architecture
	if [ -e "${mountPoint}/usr/standalone/i386/boot.efi" ]; then
		/usr/bin/ditto $opt "${mountPoint}/usr/standalone/i386/boot.efi" "${destDir}/i386/booter" || return 1
	else
		/usr/bin/ditto $opt "${srcVol}/usr/standalone/i386/boot.efi" "${destDir}/i386/booter" || return 1
	fi

	# Copy the PlatformSupport.plist file
	if [ -e "${mountPoint}/System/Library/CoreServices/PlatformSupport.plist" ]; then
		/usr/bin/ditto $opt "${mountPoint}/System/Library/CoreServices/PlatformSupport.plist" "${destDir}/i386/PlatformSupport.plist" || return 1
	else
		/usr/bin/ditto $opt "${srcVol}/System/Library/CoreServices/PlatformSupport.plist" "${destDir}/i386/PlatformSupport.plist" || return 1
	fi
}


##
# If it exists, install the partitioning application and data onto the install image
##
ProcessAutoPartition()
{
	local tempDir="$1"
	local opt=""
	local targetDir=""

	if [ -e "$tempDir/PartitionInfo.plist" ]; then
		if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
			opt="-v"
		fi

		# Determine if this is an install source, or a restore source
		if [ -d "${mountPoint}/Packages" ]; then
			if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
				echo "Installing Partitioning application and data to install image"
			fi
			targetDir="${mountPoint}/Packages"
		elif [ -d "${mountPoint}/System/Installation/Packages" ]; then
			if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
				echo "Installing Partitioning application and data to restore image"
			fi
			targetDir="${mountPoint}/System/Installation/Packages"
		else
			echo "There doesn't appear to be either an install or restore source mounted at ${mountPoint}"
			return 1
		fi

		# Create the Extras directory if it doesn't exist
		if [ ! -d "${targetDir}/Extras" ]; then
			/bin/mkdir "${targetDir}/Extras"
		fi
		targetDir="${targetDir}/Extras"

		/usr/bin/ditto $opt "$tempDir/PartitionInfo.plist" "${targetDir}/PartitionInfo.plist" || return 1
		/usr/bin/ditto $opt "$tempDir/AutoPartition.app" "${targetDir}/AutoPartition.app" || return 1
	fi

	return 0
}


##
# If it exists, install the minstallconfig.xml onto the install image
##
ProcessMinInstall()
{
	local tempDir="$1"
	local opt=""
	local targetDir="${mountPoint}/Packages/Extras"

	if [ -e "$tempDir/minstallconfig.xml" ]; then
		if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
			echo "Installing minstallconfig.xml to install image"
			opt="-v"
		fi

		/usr/bin/ditto $opt "$tempDir/minstallconfig.xml" "${targetDir}/minstallconfig.xml" || return 1
		/usr/sbin/chown root:wheel "${targetDir}/minstallconfig.xml"
		/bin/chmod 644 "${targetDir}/minstallconfig.xml"
	fi

	return 0
}


##
# untar the OSInstall.mpkg so it can be modified
##
untarOSInstallMpkg()
{
	local tempDir="$1"
	local opt=""

	# we might have already done this, so check for it first
	if [ ! -d "${tempDir}/OSInstall_pkg" ]; then
		if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
			echo "uncompressing OSInstall.mpkg"

			if [ "${scriptsDebugKey}" == "VERBOSE" -o "${scriptsDebugKey}" == "DEBUG" ]; then
				opt="-v"
			fi
		fi

		/bin/mkdir "${tempDir}/OSInstall_pkg"
		cd "${tempDir}/OSInstall_pkg"

		/usr/bin/xar $opt -xf "${mountPoint}/System/Installation/Packages/OSInstall.mpkg"

		# make Distribution writeable
		/bin/chmod 777 "${tempDir}/OSInstall_pkg"
		/bin/chmod 666 "${tempDir}/OSInstall_pkg/Distribution"
	fi
}

