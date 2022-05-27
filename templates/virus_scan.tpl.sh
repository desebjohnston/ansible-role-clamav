#!/bin/bash
# Managed by ansible role clamscan

set -o nounset
set -o pipefail

LAST_SCAN_LOG_FILENAME='/var/log/clamav/lastscan.log'
LAST_DETECTION_FILENAME='/var/log/clamav/last_detection'

# Scan the entire file system (modulo excluded trees)
# and write to the log
clamscan \
{% if clamav_scan_copy %}
  --copy={{ clamav_scan_quarantine_dir }} \
{% endif %}
{% for dir in clamav_scan_exclude_directories %}
  --exclude-dir={{ dir }} \
{% endfor %}
  --infected \
  --log=${LAST_SCAN_LOG_FILENAME} \
{% if clamav_scan_move %}
  --move={{ clamav_scan_quarantine_dir }} \
{% endif %}
  --recursive \
{% for flag in clamav_scan_extra_flags %}
  {{ flag }} \
{% endfor %}
  /

# if any infections are found, touch the detection file
if ! grep --quiet "^Infected files: 0$" ${LAST_SCAN_LOG_FILENAME}; then
  touch ${LAST_DETECTION_FILENAME}
fi
