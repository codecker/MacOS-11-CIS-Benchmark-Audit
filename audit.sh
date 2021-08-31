#!/bin/zsh
#
# Mac OS 11 CIS Benchmark Audit - Level 1
# Created by Kristian Decker
# Run Audit as root to minimize permissions issues. Run $ sudo su
################################################################################################################

# Audit Setup

# Audit date
TIMESTAMP=$(date +%F)

# Output variable with timestamp in YYYY-MM-DD format
REPORT="./${TIMESTAMP}_cis_benchmark.txt"

# Remove any previous Report file with the same name
rm -f $REPORT

# Create Output file with title and date
echo "Mac OS CIS Benchmark ${TIMESTAMP} \n" >> $REPORT

# List of all users. Removed all users starting with _, and daemon, nobody, and root users from list
USERS=$(dscl . list /Users | grep -v -e '_' -e 'root' -e 'nobody' -e 'daemon')


################################################################################################################


# Section 1
echo "SECTION 1 Install Updates, Patches and Additional Security Software \n" >> $REPORT


# 1.1 Verify all Apple-provided software is current 
# TODO: Add date check to ensure the response is within the last 30 days
echo "1.1 Verify all Apple-provided software is current. The response should be in the last 30 days" >> $REPORT
defaults read /Library/Preferences/com.apple.SoftwareUpdate | grep -e LastFullSuccessfulDate >> $REPORT
echo '\n' >> $REPORT


# 1.2 Enable Auto Update
echo "1.2 Enable Auto Update" >> $REPORT
AUDIT1_2=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled)
echo "AutomaticCheckEnabled" >> $REPORT
if [ $AUDIT1_2 = 1 ];
  then echo "PASS - ENABLED \n" >> $REPORT
  else echo "FAIL - DISABLED \n" >> $REPORT
fi


# 1.3 Enable Download new updates when available
echo "1.3 Enable Download new updates when available" >> $REPORT
AUDIT1_3=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload)
echo "AutomaticDownload" >> $REPORT
if [ $AUDIT1_3 = 1 ];
  then echo "PASS - ENABLED \n" >> $REPORT
  else echo "FAIL - DISABLED \n" >> $REPORT
fi


# 1.4 Enable app update installs
echo "1.4 Enable app update installs" >> $REPORT
AUDIT1_4=$(defaults read /Library/Preferences/com.apple.commerce AutoUpdate)
echo "AutoUpdate" >> $REPORT
if [ $AUDIT1_4 = 1 ];
  then echo "PASS - ENABLED \n" >> $REPORT
  else echo "FAIL - DISABLED \n" >> $REPORT
fi


# 1.5 Enable system data files and security updates install
echo "1.5 Enable system data files and security updates install" >> $REPORT
# First check
AUDIT1_5a=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall)
echo "ConfigDataInstall" >> $REPORT
if [ $AUDIT1_5a = 1 ];
  then echo "PASS - ENABLED" >> $REPORT
  else echo "FAIL - DISABLED" >> $REPORT
fi
# Second Check
AUDIT1_5b=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall)
echo "CriticalUpdateInstall" >> $REPORT
if [ $AUDIT1_5b = 1 ];
  then echo "PASS - ENABLED \n" >> $REPORT
  else echo "FAIL - DISABLED \n" >> $REPORT
fi


# 1.6 Enable macOS update installs
echo "1.6 Enable macOS update installs" >> $REPORT
AUDIT1_6=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates)
echo "AutomaticallyInstallMacOSUpdates" >> $REPORT
if [ $AUDIT1_6 = 1 ];
  then echo "PASS - ENABLED \n" >> $REPORT
  else echo "FAIL - DISABLED \n" >> $REPORT
fi


################################################################################################################


# Section 2
echo "SECTION 2 System Preferences \n" >> $REPORT


# 2.1.1 Turn off Bluetooth, if no paired devices exist
echo "2.1.1 Turn off Bluetooth, if no paired devices exist" >> $REPORT
AUDIT2_1_1=$(defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState)
if [ $AUDIT2_1_1 = 0 ];
  then echo "PASS - DISABLED \n" >> $REPORT
  else 
  # If Bluetooth is enabled, check if there are paired devices
    BT=$(system_profiler SPBluetoothDataType | grep "Bluetooth:" -A 20 | grep Connectable)

    # Remove string "Connectable: Yes"
    BT1=${BT//"Connectable: Yes"/}

    # Remove whitespace
    BT2=${BT1//" "/}

    # If BT2 variable is null (-z) there are no paired Bluetooth devices, otherwise bluetooth devices have been paired
    if [ -z "$BT2" ];
      then echo "FAIL - ENABLED with no paired Bluetooth devices \n" >> $REPORT
      else echo "PASS - ENABLED with paired Bluetooth devices \n" >> $REPORT
    fi
fi


# 2.1.2 Show Bluetooth status in menu bar
echo "2.1.2 Show Bluetooth status in menu bar" >> $REPORT
echo "User accounts and Status" >> $REPORT
for i in $USERS
  do
    AUDIT2_1_2=$(sudo -u $i defaults -currentHost read com.apple.controlcenter.plist Bluetooth)
    if [ $AUDIT2_1_2 = 18 ]
      then echo $i " PASS - ENABLED" >> $REPORT
      else echo $i " FAIL - DISABLED" >> $REPORT
    fi
  done
echo "\n" >> $REPORT

# 2.2.1 Enable "Set time and date automatically"
echo "2.2.1 Enable Set time and date automatically" >> $REPORT
AUDIT2_2_1=$(systemsetup -getusingnetworktime)
if [[ $AUDIT2_2_1 =~ "On" ]]
  then echo "PASS - ENABLED \n" >> $REPORT
  else echo "FAIL - DISABLED \n" >> $REPORT
fi