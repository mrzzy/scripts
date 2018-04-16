#
# yumi_config.sh
# YUMI Config setup script
#

printf "Setup Configuration for YUMI\n"
printf 'YoURLs Server: '
read SERVER
printf 'YoURLs Signature: '
read SIGNATURE
printf 'server: %s\nsignature: %s\n' "$SERVER" "$SIGNATURE" >"$HOME/.yumi.conf"
printf "Done. To reconfigure yumi, run 'make remove && make config'\n"

