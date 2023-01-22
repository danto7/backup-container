#!/usr/bin/env bash
set -eo pipefail

CYN='\e[36m'
YLW='\x1B[33m'
RED='\x1B[31m'
END='\e[0m'

eae(){
  echo -e "${YLW}> $*${END}"
  "$@"
  echo ""
}
info(){
  echo -e "${CYN}[INFO]${END} $*"
}
fail(){
  echo -e "${RED}[FAIL]${END} $*"
  exit 1
}

variables=(BACKUP_DIR RESTIC_REPOSITORY RESTIC_PASSWORD)
if [[ "${RESTIC_REPOSITORY:0:3}" = "b2:" ]]; then
  variables=("${variables[@]}" B2_ACCOUNT_ID B2_ACCOUNT_KEY)
fi
if [[ "${RESTIC_REPOSITORY:0:3}" = "s3:" ]]; then
  variables=("${variables[@]}" AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY)
fi

for var in "${variables[@]}"; do
  if [[ -z "$var" ]]; then
    echo "$var is not defined. Define it first and run this container again. "
    exit 1
  fi
done

if ! restic snapshots > /dev/null 2>&1 ; then
  info "Detected new repository. Initializing ..."
  eae restic --verbose init 
fi

find_cmd=(find "$BACKUP_DIR" -maxdepth 1 -mindepth 1)
backups="$("${find_cmd[@]}")"

if [[ "$("${find_cmd[@]}" | wc -l)" -eq 0 ]]; then
  fail "nothing to backup"
fi

info "backing up directorys: " ${backups[@]}
eae restic --verbose backup ${backups[@]}

info "forgetting snapshots"
eae restic --verbose forget --keep-daily 7 --keep-weekly 4 --keep-monthly 3
