#!/bin/sh
# Audi RVC fullscreen, P0916-specific resource installer v1.2 radar recovery.
# Prepared from the user's live export and mrfixpl's AU37x resource changes.
# No IFS, EEPROM, FEC or CarPlay modifications.
PATH=/proc/boot:/bin:/usr/bin:/sbin:/usr/sbin:/mnt/app/armle/bin:/mnt/app/armle/usr/bin:/net/mmx/bin:/net/mmx/usr/bin:/net/mmx/mnt/app/armle/bin:/net/mmx/mnt/app/armle/usr/bin
export PATH
SD=/net/mmx/fs/sda0
MMX=/net/mmx
RCC=/net/rcc
BASE="$SD/mod/rvc_p0916"
MANIFEST="$BASE/manifest.txt"
SHA1="$SD/apps/sbin/sha1sum"
LOCK="$MMX/dev/shmem/rvc-p0916.lock"
LOG=
RUN=
CHANGED=0
COMMITTED=0
STAGING=0
APP_RW=0
SYS_RW=0

say() {
    echo "$*"
    if [ -n "$LOG" ]; then
        echo "$*" >> "$LOG" || echo "WARNING: could not append to SD log."
    fi
}
fail() { say "ERROR: $*"; exit 1; }
hash_file() {
    HASH_LINE=$("$SHA1" "$1") || return 1
    HASH_VALUE=${HASH_LINE%% *}
    [ ${#HASH_VALUE} -eq 40 ] || return 1
    case "$HASH_VALUE" in *[!0-9a-f]*) return 1;; esac
    echo "$HASH_VALUE"
}
matches() {
    ACTUAL=$(hash_file "$1") || return 1
    [ "$ACTUAL" = "$2" ]
}

# Called only after a complete per-run backup has been verified and synced.
rollback() {
    say "An update failed. Restoring the verified pre-run snapshot..."
    ROLLBACK_OK=1
    while read -r OLDHASH REL; do
        TARGET="$MMX/mnt/$REL"
        TEMP="$TARGET.rvc-stage-$$"
        if cp -p "$TARGET" "$TEMP" && cp "$RUN/before/$REL" "$TEMP" && matches "$TEMP" "$OLDHASH" && mv -f "$TEMP" "$TARGET" && matches "$TARGET" "$OLDHASH"; then
            say "ROLLED BACK: $REL"
        else
            ROLLBACK_OK=0
            say "ROLLBACK FAILED: $REL"
        fi
    done < "$RUN/before.txt"
    sync || ROLLBACK_OK=0
    if [ "$ROLLBACK_OK" = 1 ]; then
        say "ROLLBACK COMPLETE. Previous files restored."
    else
        say "Recovery needs attention. Keep SD inserted and save this log."
    fi
}
cleanup() {
    RESULT=$?
    trap - 0 1 2 15
    if [ "$CHANGED" = 1 ] && [ "$COMMITTED" = 0 ]; then
        rollback
    fi
    if [ "$STAGING" = 1 ]; then
        while read -r ORIGINAL PREVIOUS PATCHED REL; do
            rm -f "$MMX/mnt/$REL.rvc-stage-$$"
        done < "$MANIFEST"
    fi
    if [ "$SYS_RW" = 1 ]; then
        mount -ur "$MMX/mnt/system" || { say "WARNING: system read-only remount failed."; RESULT=1; }
    fi
    if [ "$APP_RW" = 1 ]; then
        mount -ur "$MMX/mnt/app" || { say "WARNING: app read-only remount failed."; RESULT=1; }
    fi
    rm -f "$LOCK" || say "WARNING: lock removal failed."
    exit "$RESULT"
}

say "Audi RVC fullscreen - CN AU37x P0916 - installer v1.2 radar recovery"
for TOOL in cp mv rm mkdir mount sync cat; do
    command -v "$TOOL" >/dev/null 2>&1 || fail "Required command missing: $TOOL"
done
[ -x "$SHA1" ] || fail "M.I.B. apps/sbin/sha1sum is missing or not executable."
matches /dev/null da39a3ee5e6b4b0d3255bfef95601890afd80709 || fail "M.I.B. SHA-1 tool self-test failed."
matches "$MANIFEST" 367e0fb4dba969fb52e68074c8e17567b4b73e44 || fail "Manifest is missing or damaged. Re-extract the package."

ACTION=
IFS= read -r ACTION < "$BASE/ACTION.txt" || [ -n "$ACTION" ] || fail "Cannot read ACTION.txt."
CR=$(printf '\r')
ACTION=${ACTION%$CR}
case "$ACTION" in CHECK|INSTALL|RESTORE) ;; *) fail "ACTION.txt must contain CHECK, INSTALL or RESTORE.";; esac
say "Action: $ACTION"
VERSION=
IFS= read -r VERSION < "$SD/VERSION" || [ -n "$VERSION" ] || fail "Cannot read M.I.B. VERSION."
case "$VERSION" in 'V3.7.3 '*) ;; *) fail "This package is prepared for M.I.B. 3.7.3.";; esac
TRAIN=
IFS= read -r TRAIN < "$RCC/mnt/efs-persist/SWDL/CachedTrain.txt" || [ -n "$TRAIN" ] || fail "Cannot read vehicle software train."
TRAIN=${TRAIN%$CR}
[ "$TRAIN" = MHI2_CN_AU37x_P0916 ] || fail "Unsupported software train: $TRAIN"

# Exclusive lock file in RAM. noclobber refuses an existing lock atomically.
# Cleanup uses the available rm command; no directory-removal utility needed.
( set -C; : > "$LOCK" ) || fail "Another RVC run is active or an interrupted run left a lock."
trap cleanup 0
trap 'exit 1' 1 2 15

ORIGINAL_COUNT=0
PATCHED_COUNT=0
FILE_COUNT=0
while read -r ORIGINAL PREVIOUS PATCHED REL; do
    matches "$BASE/originals/$REL" "$ORIGINAL" || fail "Damaged original payload: $REL"
    matches "$BASE/patched/$REL" "$PATCHED" || fail "Damaged patched payload: $REL"
    TARGET="$MMX/mnt/$REL"
    [ -f "$TARGET" ] && [ ! -L "$TARGET" ] || fail "Target is missing or a symbolic link: $REL"
    CURRENT=$(hash_file "$TARGET") || fail "Cannot hash target: $REL"
    case "$CURRENT" in
        "$ORIGINAL"|"$PREVIOUS"|"$PATCHED") ;;
        *) fail "Target differs from all known versions: $REL. Nothing has been installed.";;
    esac
    FILE_COUNT=$((FILE_COUNT + 1))
    if [ "$CURRENT" = "$ORIGINAL" ]; then ORIGINAL_COUNT=$((ORIGINAL_COUNT + 1)); fi
    if [ "$CURRENT" = "$PATCHED" ]; then PATCHED_COUNT=$((PATCHED_COUNT + 1)); fi
    [ ! -e "$TARGET.rvc-stage-$$" ] || fail "Staging path already exists: $REL"
done < "$MANIFEST"
[ "$FILE_COUNT" -eq 20 ] || fail "Unexpected file count."
say "SHA-1 preflight passed: $FILE_COUNT known files. Stock matches: $ORIGINAL_COUNT/20; radar recovery matches: $PATCHED_COUNT/20."
if [ "$ACTION" = CHECK ]; then
    say "CHECK COMPLETE. No resource files changed."
    exit 0
fi
if [ "$ACTION" = INSTALL ]; then
    if [ "$PATCHED_COUNT" -eq 20 ]; then say "ALREADY INSTALLED. No files changed."; exit 0; fi
    SOURCE="$BASE/patched"
else
    if [ "$ORIGINAL_COUNT" -eq 20 ]; then say "ALREADY ORIGINAL. No files changed."; exit 0; fi
    SOURCE="$BASE/originals"
fi

mount -uw "$SD" || say "SD remount failed; actual SD writes will be checked."
BACKUPS="$SD/backup/RVC_P0916_FULLSCREEN"
mkdir -p "$BACKUPS" || fail "Cannot create SD backup directory. See the command error."
NUMBER=1
while [ -e "$BACKUPS/run-$NUMBER" ]; do NUMBER=$((NUMBER + 1)); done
RUN="$BACKUPS/run-$NUMBER"
mkdir "$RUN" || fail "Cannot create a fresh run directory."
LOG="$RUN/run.log"
echo "RVC v1.2 radar recovery $ACTION $TRAIN" > "$LOG" || fail "Cannot write SD log."
: > "$RUN/before.txt" || fail "Cannot initialize backup manifest."
say "Saving pre-run files to $RUN/before"
while read -r ORIGINAL PREVIOUS PATCHED REL; do
    TARGET="$MMX/mnt/$REL"
    CURRENT=$(hash_file "$TARGET") || fail "Cannot recheck source: $REL"
    case "$CURRENT" in "$ORIGINAL"|"$PREVIOUS"|"$PATCHED") ;; *) fail "Target changed during preflight: $REL";; esac
    mkdir -p "$RUN/before/${REL%/*}" || fail "Cannot create backup folder."
    cp "$TARGET" "$RUN/before/$REL" || fail "Backup copy failed: $REL"
    matches "$RUN/before/$REL" "$CURRENT" || fail "Backup hash mismatch: $REL"
    echo "$CURRENT $REL" >> "$RUN/before.txt" || fail "Cannot update backup manifest."
done < "$MANIFEST"
sync || fail "Backup sync failed."
say "All 20 pre-run files backed up and SHA-1 verified."

mount -uw "$MMX/mnt/app" || fail "Cannot make app partition writable."
APP_RW=1
mount -uw "$MMX/mnt/system" || fail "Cannot make system partition writable."
SYS_RW=1
STAGING=1
while read -r ORIGINAL PREVIOUS PATCHED REL; do
    TARGET="$MMX/mnt/$REL"
    TEMP="$TARGET.rvc-stage-$$"
    if [ "$ACTION" = INSTALL ]; then EXPECTED=$PATCHED; else EXPECTED=$ORIGINAL; fi
    # Preserve owner/mode from the current file, then replace only its contents.
    cp -p "$TARGET" "$TEMP" || fail "Cannot prepare staging file: $REL"
    cp "$SOURCE/$REL" "$TEMP" || fail "Cannot stage payload: $REL"
    matches "$TEMP" "$EXPECTED" || fail "Staged payload checksum mismatch: $REL"
done < "$MANIFEST"
sync || fail "Staging sync failed."

# Ensure current resources still match the snapshot before the first rename.
while read -r OLDHASH REL; do
    matches "$MMX/mnt/$REL" "$OLDHASH" || fail "Live file changed after backup: $REL"
done < "$RUN/before.txt"
CHANGED=1
while read -r ORIGINAL PREVIOUS PATCHED REL; do
    TARGET="$MMX/mnt/$REL"
    if [ "$ACTION" = INSTALL ]; then EXPECTED=$PATCHED; else EXPECTED=$ORIGINAL; fi
    mv -f "$TARGET.rvc-stage-$$" "$TARGET" || fail "Replace failed: $REL"
    matches "$TARGET" "$EXPECTED" || fail "Post-write checksum mismatch: $REL"
    say "VERIFIED: $REL"
done < "$MANIFEST"
sync || fail "Final sync failed."
COMMITTED=1
mount -ur "$MMX/mnt/system" || fail "Files updated, but system read-only remount failed."
SYS_RW=0
mount -ur "$MMX/mnt/app" || fail "Files updated, but app read-only remount failed."
APP_RW=0
say "$ACTION COMPLETE. All 20 resource files SHA-1 verified."
say "Backup and log: $RUN"
say "You can go back and manually restart the MMI to load the resources."
exit 0
