#!/sbin/sh

# Custom installer actions

TMPDIR=/dev/tmp
MOUNTPATH=/dev/magisk_img

umask 022

# Initial cleanup
rm -rf $TMPDIR 2>/dev/null
mkdir -p $TMPDIR

ui_print() { echo "$1"; }

# Check Magisk version
if [ $MAGISK_VER_CODE -lt 20000 ]; then
  ui_print "***********************************"
  ui_print " Magisk 20.0+ required! "
  ui_print "***********************************"
  exit 1
fi

# Preparation for flashable zips
setup_flashable

# Detect version and architecture
api_level_arch_detect

# Extract common files
unzip -oj "$ZIPFILE" module.prop install.sh uninstall.sh 'common/*' -d $TMPDIR >&2

[ ! -f $TMPDIR/install.sh ] && abort "! Unable to extract zip file!"
# Load install script
. $TMPDIR/install.sh

# Set module paths
MODULEROOT=$NVBASE/modules
MODID=$(grep_prop id $TMPDIR/module.prop)
MODPATH=$MODULEROOT/$MODID

print_modname

# Create mod paths
rm -rf $MODPATH 2>/dev/null
mkdir -p $MODPATH

# Remove placeholder
rm -f $MODPATH/system/placeholder 2>/dev/null

# Custom uninstaller
[ -f $TMPDIR/uninstall.sh ] && cp -af $TMPDIR/uninstall.sh $MODPATH/uninstall.sh

# Auto Mount
$SKIPMOUNT && touch $MODPATH/skip_mount

# Prop files
$PROPFILE && cp -af $TMPDIR/system.prop $MODPATH/system.prop

# Module info
cp -af $TMPDIR/module.prop $MODPATH/module.prop

# Update info for Magisk Manager
mktouch $NVBASE/modules/$MODID/update
cp -af $TMPDIR/module.prop $NVBASE/modules/$MODID/module.prop

# post-fs-data mode scripts
$POSTFSDATA && cp -af $TMPDIR/post-fs-data.sh $MODPATH/post-fs-data.sh

# service mode scripts
$LATESTARTSERVICE && cp -af $TMPDIR/service.sh $MODPATH/service.sh

on_install

# Handle replace folders
for TARGET in $REPLACE; do
  mktouch $MODPATH$TARGET/.replace
done

ui_print "- Setting permissions"
set_permissions

# Final cleanup
rm -rf $TMPDIR $MOUNTPATH

ui_print "For more Updates of the Systemless Lawnchair Launcher"
ui_print "https://github.com/Unofficial-Life/Lawnchair-Launcher-Module"
ui_print "- Done"
exit 0