#!/usr/bin/env bash

URL="$(curl -s "https://github.com/jhovold/linux/wiki/X13s" | grep -Po '(?<=href=")https://github.com/jhovold/[a-zA-Z0-9:/\.\-]+(?=")')"

if [[ "$URL" =~ https://github.com/([^/]+)/([^/]+)/tree/(.+)$ ]] ; then
  OWNER="${BASH_REMATCH[1]}"
  REPO="${BASH_REMATCH[2]}"
  REVISION="${BASH_REMATCH[3]}"
  MAKEFILE_URL="https://raw.githubusercontent.com/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}/refs/heads/${BASH_REMATCH[3]}/Makefile"
  while IFS=$'\n' read line
  do
    if [[ "$line" =~ ^([A-Z]+)\ =\ ?(.*)$ ]] ; then
      case "${BASH_REMATCH[1]}" in
        VERSION)
          VERSION="${BASH_REMATCH[2]}"
          ;;
        PATCHLEVEL)
          PATCHLEVEL="${BASH_REMATCH[2]}"
          ;;
        SUBLEVEL)
          SUBLEVEL="${BASH_REMATCH[2]}"
          ;;
        EXTRAVERSION)
          EXTRAVERSION="${BASH_REMATCH[2]}"
          ;;
      esac
    fi
  done < <( curl -s "$MAKEFILE_URL" )
  FULL_VERSION="$VERSION.$PATCHLEVEL.$SUBLEVEL$EXTRAVERSION"
fi

HASH="$(nix-prefetch-url --unpack "https://codeload.github.com/$OWNER/$REPO/zip/refs/heads/$REVISION")"
SRI_HASH="$(nix-hash --type sha256 --to-sri "$HASH")"

jq --arg owner "$OWNER" --arg repo "$REPO" --arg rev "$REVISION" --arg version "$FULL_VERSION" --arg hash "$SRI_HASH" '$ARGS.named' -n
