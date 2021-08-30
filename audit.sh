#!/bin/zsh

# Mac OS 11 CIS Benchmark Audit - Level 1
# Run as root using $ sudo su

# Audit date
TIMESTAMP=$(date +%F)

# Output variable with timestamp in YYYY-MM-DD format
REPORT="./${TIMESTAMP}_cis_benchmark.txt"

# Remove any previous Report file with the same name
rm -f $REPORT

# Create Output file with title and date
echo "Mac OS CIS Benchmark ${TIMESTAMP} \n" >> $REPORT


# Section 1
echo "SECTION 1 Install Updates, Patches and Additional Security Software \n" >> $REPORT

# 1.1 Verify all Apple-provided software is current 
# TODO: Add date check to ensure the response is within the last 30 days
echo "1.1 Verify all Apple-provided software is current. The response should be in the last 30 days" >> $REPORT
defaults read /Library/Preferences/com.apple.SoftwareUpdate | grep -e LastFullSuccessfulDate >> $REPORT
echo '\n' >> $REPORT


# 1.2 Enable Auto Update
echo "1.2 Enable Auto Update" >> $REPORT
VALUE=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled)
echo "AutomaticCheckEnabled" >> $REPORT
if [ $VALUE = 1 ];
then echo "PASS - ENABLED \n" >> $REPORT
else echo "FAIL - DISABLED \n" >> $REPORT
fi
VALUE=""

# 1.3 Enable Download new updates when available
echo "1.3 Enable Download new updates when available" >> $REPORT
VALUE=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload)
echo "AutomaticDownload" >> $REPORT
if [ $VALUE = 1 ];
then echo "PASS - ENABLED \n" >> $REPORT
else echo "FAIL - DISABLED \n" >> $REPORT
fi
VALUE=""

# 1.4 Enable app update installs
echo "1.4 Enable app update installs" >> $REPORT
VALUE=$(defaults read /Library/Preferences/com.apple.commerce AutoUpdate)
echo "AutoUpdate" >> $REPORT
if [ $VALUE = 1 ];
then echo "PASS - ENABLED \n" >> $REPORT
else echo "FAIL - DISABLED \n" >> $REPORT
fi
VALUE=""

# 1.5 Enable system data files and security updates install
echo "1.5 Enable system data files and security updates install" >> $REPORT
VALUE=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall)
echo "ConfigDataInstall" >> $REPORT
if [ $VALUE = 1 ];
then echo "PASS - ENABLED" >> $REPORT
else echo "FAIL - DISABLED" >> $REPORT
fi
VALUE=""

VALUE=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall)
echo "CriticalUpdateInstall" >> $REPORT
if [ $VALUE = 1 ];
then echo "PASS - ENABLED \n" >> $REPORT
else echo "FAIL - DISABLED \n" >> $REPORT
fi
VALUE=""

# 1.6 Enable macOS update installs
echo "1.6 Enable macOS update installs" >> $REPORT
VALUE=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates)
echo "AutomaticallyInstallMacOSUpdates" >> $REPORT
if [ $VALUE = 1 ];
then echo "PASS - ENABLED \n" >> $REPORT
else echo "FAIL - DISABLED \n" >> $REPORT
fi
VALUE=""

# Section 2
echo "SECTION 2 System Preferences \n" >> $REPORT

# 2.1.1 Turn off Bluetooth, if no paired devices exist
echo "2.1.1 Turn off Bluetooth, if no paired devices exist" >> $REPORT
VALUE=$(defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState)
if [ $VALUE = 0 ];
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
VALUE=""