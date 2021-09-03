#!/bin/zsh
#
# Mac OS 11 CIS Benchmark Audit - Level 1
# Created by Kristian Decker
# Run script as sudo
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

# List of hot corners
HOTCORNERS=("wvous-tl-corner" "wvous-bl-corner" "wvous-tr-corner" "wvous-br-corner ")


################################################################################################################


# Section 1
echo "SECTION 1 Install Updates, Patches and Additional Security Software \n" >> $REPORT


# TODO: Add date check to ensure the response is within the last 30 days
# 1.1 Verify all Apple-provided software is current 
echo "1.1 Verify all Apple-provided software is current. The response should be in the last 30 days" >> $REPORT
defaults read /Library/Preferences/com.apple.SoftwareUpdate | grep -e LastFullSuccessfulDate >> $REPORT
echo "\n" >> $REPORT


# 1.2 Enable Auto Update
echo "1.2 Enable Auto Update" >> $REPORT
AUDIT1_2=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled)
echo "\t""AutomaticCheckEnabled" >> $REPORT
if [ $AUDIT1_2 = 1 ];
  then echo "\t""PASS - ENABLED \n" >> $REPORT
  else echo "\t""FAIL - DISABLED \n" >> $REPORT
fi


# 1.3 Enable Download new updates when available
echo "1.3 Enable Download new updates when available" >> $REPORT
AUDIT1_3=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload)
echo "\t""AutomaticDownload" >> $REPORT
if [ $AUDIT1_3 = 1 ];
  then echo "\t""PASS - ENABLED \n" >> $REPORT
  else echo "\t""FAIL - DISABLED \n" >> $REPORT
fi


# 1.4 Enable app update installs
echo "1.4 Enable app update installs" >> $REPORT
AUDIT1_4=$(defaults read /Library/Preferences/com.apple.commerce AutoUpdate)
echo "\t""AutoUpdate" >> $REPORT
if [ $AUDIT1_4 = 1 ];
  then echo "\t""PASS - ENABLED \n" >> $REPORT
  else echo "\t""FAIL - DISABLED \n" >> $REPORT
fi


# 1.5 Enable system data files and security updates install
echo "1.5 Enable system data files and security updates install" >> $REPORT
# First check
AUDIT1_5a=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall)
echo "\t""ConfigDataInstall" >> $REPORT
if [ $AUDIT1_5a = 1 ];
  then echo "\t""PASS - ENABLED" >> $REPORT
  else echo "\t""FAIL - DISABLED" >> $REPORT
fi
# Second Check
AUDIT1_5b=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall)
echo "\t""CriticalUpdateInstall" >> $REPORT
if [ $AUDIT1_5b = 1 ];
  then echo "\t""PASS - ENABLED \n" >> $REPORT
  else echo "\t""FAIL - DISABLED \n" >> $REPORT
fi


# 1.6 Enable macOS update installs
echo "1.6 Enable macOS update installs" >> $REPORT
AUDIT1_6=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates)
echo "\t""AutomaticallyInstallMacOSUpdates" >> $REPORT
if [ $AUDIT1_6 = 1 ];
  then echo "\t""PASS - ENABLED \n" >> $REPORT
  else echo "\t""AIL - DISABLED \n" >> $REPORT
fi


################################################################################################################


# Section 2
echo "SECTION 2 System Preferences \n" >> $REPORT


# 2.1.1 Turn off Bluetooth, if no paired devices exist
echo "2.1.1 Turn off Bluetooth, if no paired devices exist" >> $REPORT
AUDIT2_1_1=$(defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState)
if [ $AUDIT2_1_1 = 0 ];
  then echo "\t""PASS - DISABLED \n" >> $REPORT
  else 
  # If Bluetooth is enabled, check if there are paired devices
    BT=$(system_profiler SPBluetoothDataType | grep "Bluetooth:" -A 20 | grep Connectable)

    # Remove string "Connectable: Yes"
    BT1=${BT//"Connectable: Yes"/}

    # Remove whitespace
    BT2=${BT1//" "/}

    # If BT2 variable is null (-z) there are no paired Bluetooth devices, otherwise bluetooth devices have been paired
    if [ -z "$BT2" ];
      then echo "\t""FAIL - ENABLED with no paired Bluetooth devices \n" >> $REPORT
      else echo "\t""PASS - ENABLED with paired Bluetooth devices \n" >> $REPORT
    fi
fi


# 2.1.2 Show Bluetooth status in menu bar
echo "2.1.2 Show Bluetooth status in menu bar" >> $REPORT
echo "\t""User accounts and Status" >> $REPORT
for i in $USERS
  do
    AUDIT2_1_2=$(sudo -u $i defaults -currentHost read com.apple.controlcenter.plist Bluetooth)
    if [ $AUDIT2_1_2 = 18 ]
      then echo "\t"$i" PASS - ENABLED" >> $REPORT
      else echo "\t"$i" FAIL - DISABLED" >> $REPORT
    fi
  done
echo "\n" >> $REPORT


# 2.2.1 Enable Set time and date automatically
echo "2.2.1 Enable Set time and date automatically" >> $REPORT
AUDIT2_2_1=$(systemsetup -getusingnetworktime)
if [[ $AUDIT2_2_1 =~ "On" ]]
  then echo "\t""PASS - ENABLED \n" >> $REPORT
  else echo "\t""FAIL - DISABLED \n" >> $REPORT
fi


# 2.2.2 Ensure time set is within appropriate limits 
echo "2.2.2 Ensure time set is within appropriate limits" >> $REPORT
# Get Network time server
AUDIT2_2_2a=$(systemsetup -getnetworktimeserver)
AUDIT2_2_2a_value=${AUDIT2_2_2a//"Network Time Server: "/}
echo "\t""Network Time Server:" $AUDIT2_2_2a_value >> $REPORT

# TODO: Calculate network time difference and provide PASS / FAIL Notification
# Ensure Network time is within +/- 270 seconds
echo "\tNTP_TOLERANCE = +/- 270" >> $REPORT
AUDIT2_2_2b=$(sntp $AUDIT2_2_2a_value | grep +/-)
echo "\t"$AUDIT2_2_2b"\n" >> $REPORT


# TODO: FIX THIS AUDIT
# 2.3.1 Set an inactivity interval of 20 minutes or less for the screen saver 
# echo "2.3.1 Set an inactivity interval of 20 minutes or less for the screen saver" >> $REPORT
# echo "\t""User accounts and Status" >> $REPORT
# UUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep "IOPlatformUUID" | sed -e 's/^.* "\(.*\)"$/\1/'`
# for i in $USERS
# do 
#  echo $(defaults -currentHost read com.apple.screensaver idleTime)

#   AUDIT2_3_1=$i/Library/Preferences/ByHost/com.apple.screensaver.$UUID 
#   if [[ AUDIT2_3_1 =~ "exist" ]] 
#     then echo "\t""FAIL - Default Inactivity Interval in use"
#     else 
#       # AUDIT2_3_1_idletime=$(defaults read $AUDIT2_3_1.plist idleTime)
#       # echo $AUDIT2_3_1_idletime
#   fi 
# done


# 2.3.2 Secure screen saver corners
echo "2.3.2 Secure screen saver corners" >> $REPORT
echo "\t""User accounts and Status" >> $REPORT


for i in $USERS
  do
    AUDIT2_3_2_count=0
    echo $AUDIT2_3_2_count
    for j in ${HOTCORNERS[@]}
      do
        AUDIT2_3_2=$(sudo -u $i defaults read com.apple.dock $j)
        if [ $AUDIT2_3_2 = 6 ]
          then AUDIT2_3_2_count=$((AUDIT2_3_2_count + 1))
          echo $AUDIT2_3_2_count
        fi
      done
    if (( $AUDIT2_3_2_count >= 1 ))
      then echo "\t"$i" FAIL - Hot Corner set to Disable Screen Saver" >> $REPORT
      else echo "\t"$i" PASS - No Hot Corner set to Disable Screen Saver" >> $REPORT
      AUDIT2_3_2_count=0
    fi
  done

echo "\n" >> $REPORT


# 2.3.3 Familiarize users with screen lock tools or corner to Start Screen Saver
echo "Familiarize users with screen lock tools or corner to Start Screen Saver" >> $REPORT
echo "\t""User accounts and Status" >> $REPORT


for i in $USERS
  do
    AUDIT2_3_2_count=0
    echo $AUDIT2_3_3_count
    for j in ${HOTCORNERS[@]}
      do
        AUDIT2_3_3=$(sudo -u $i defaults read com.apple.dock $j)
        if [ $AUDIT2_3_3 = 5 ]
          then AUDIT2_3_3_count=$((AUDIT2_3_2_count + 1))
          echo $AUDIT2_3_3_count
        fi
        if [ $AUDIT2_3_3 = 10 ]
          then AUDIT2_3_3_count=$((AUDIT2_3_2_count + 1))
          echo $AUDIT2_3_3_count
        fi
      done
    if (( $AUDIT2_3_3_count >= 1 ))
      then echo "\t"$i" PASS - Hot Corner set to Start Screen Saver" >> $REPORT
      else echo "\t"$i" FAIL - No Hot Corner set to Start Screen Saver" >> $REPORT
      AUDIT2_3_3_count=0
    fi
  done

echo "\n" >> $REPORT

# 2.4.1 Disable Remote Apple Events
echo "2.4.1 Disable Remote Apple Events" >> $REPORT

AUDIT2_4_1=$(systemsetup -getremoteappleevents)
if [[ $AUDIT2_4_1 =~ "Off" ]] 
  then echo "\t""PASS - DISABLED \n" >> $REPORT
  else echo "\t""FAIL - ENABLED \n" >> $REPORT
fi