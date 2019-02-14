#!/usr/bin/env bash

source $(dirname "$0")/config.sh

clipboard=$(xclip -o -selection clipboard -t image/png 2> /dev/null)

if [[ "target image/png not available" == *"$clipboard"* ]]; then
  echo "No image found on clipboard!"
  exit 1
fi

emojis=(😀 😁 😂 🤣 😃 😄 😅 😆 😉 😊 😋 😎 😍 😘 🥰 😗 😙 😚 ☺ 🙂 🤗 🤩 🤔 🤨 😐 😑 😶 🙄 😏 😣 😥 😮 🤐 😯 😪 😫 😴 😌 😛 😜 😝 🤤 😒 😓 😔 😕 🙃 🤑 😲 ☹ 🙁 😖 😞 😟 😤 😢 😭 😦 😧 😨 😩 🤯 😬 😰 😱 🥵 🥶 😳 🤪 😵 😡 😠 🤬 😷 🤒 🤕 🤢 🤮 🤧 😇 🤠 🤡 🥳 🥴 🥺 🤥 🤫 🤭 🧐 🤓 😈 👿 👹 👺 💀 ☠ 👻 👽 👾 🤖 💩 😺 😸 😹 😻 😼 😽 🙀 😿 😾 👶 👦 👧 👨 👩 👴 👵 👮 🕵 💂 👷 🤴 👸 👳 👲 🧕 🧔 👱 🤵 👰 🤰 🤱 👼 🎅 🤶 🦸 🦹 🧙 🧛 🧜 🧝 🧞 🧟 🙍 🙎 🙅 🙆 💁 🙋 🙇 🤦 🤷 💆 💇 🚶 🏃 💃 🕺 👯 🧖 🧘 🕴 🗣 👤 👥 👫 👬 👭 💏 💑 👪 🤳 💪 🦵 🦶 👈 👉 ☝ 👆 🖕 👇 ✌ 🤞 🖖 🤘 🤙 🖐 ✋ 👌 👍 👎 ✊ 👊 🤛 🤜 🤚 👋 🤟 ✍ 👏 👐 🙌 🤲 🙏 🤝 💅 👂 👃 👣 👀 👁 🧠 🦴 🦷 👅 👄 💋 👓 🕶 🥽 🥼 👔 👕 👖 🧣 🧤 🧥 🧦 👗 👘 👙 👚 👛 👜 👝 🎒 👞 👟 🥾 🥿 👠 👡 👢 👑 👒 🎩 🎓 🧢 ⛑ 💄 💍 🧳 🌂 ☂ 💼 🧵 🧶)

name=""

if [[ "$@" == *"-e"* ]]; then
  i=0
  while [ "$i" -le 5 ]; do
    index=$(($RANDOM % 256))
    name="$name${emojis[index]}"
    i=$(($i + 1))
  done
else 
  name=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $FILE_NAME_LENGTH | head -n 1)
fi

xclip -o -selection clipboard -t image/png -o > "$name.png"

ftp -n "$HOST" <<END_SCRIPT
  quote USER "$USERNAME"
  quote PASS "$PASSWORD"
  passive
  binary
  put "$name.png"
END_SCRIPT

rm "$name.png"

url="$BASE_REDIRECT_URL/$name.png"

echo -n $url | xclip -i -selection clipboard

if [[ "$@" != *"-q"* ]]; then
  echo "$url"
fi

if [[ "$@" == *"-w"* ]]; then
  xdg-open "$url"
fi
