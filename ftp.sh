#!/usr/bin/env bash

currentdirname=$(dirname "$0")
source $(dirname "$0")/config.sh


if [[ -z "${name}" ]]; then
  name="$(cat /dev/urandom \
    | tr -dc 'a-zA-Z0-9' \
    | fold -w "${FILE_NAME_LENGTH}" \
    | head -n 1)"
fi

flameshot gui --raw > "$name.png"
getimgsize=$(cat "$name.png" | wc -c)

if [[ $getimgsize == 0 ]]; then
  echo "No image found on clipboard!"
  rm "$name.png"
  exit 1
fi

declare name
declare -i opt_quiet
declare -i opt_new_window

while (($#)); do
  case "$1" in
    -q)
      opt_quiet=1
      ;;
    -w)
      opt_new_window=1
      ;;
    *)
      printf "error: unrecognized argument '$1'\n" >&2
      exit 1
      ;;
  esac
  shift
done

upload_dir=$(echo "$UPLOAD_PATH/$name.png" | tr -s /)
echo "$upload_dir"

export SSHPASS="$PASSWORD"
sshpass -e sftp -oPort=22 "$HOST" <<END_SCRIPT
  put "$name.png" "$upload_dir"
END_SCRIPT

mv "$name.png" "$currentdirname/screenshots/$name.png"

url="$BASE_REDIRECT_URL/$name.png"

echo -n $url | xclip -i -selection clipboard

if ((! opt_quiet)); then
  echo "$url"
fi

if ((opt_new_window)); then
  xdg-open "$url"
fi

notify-send 'Done!'
