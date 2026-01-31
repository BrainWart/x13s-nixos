#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq

COOKIE_FILE="$(mktemp)"
trap "rm -f $COOKIE_FILE" EXIT

curl --silent --cookie "$COOKIE_FILE" --cookie-jar "$COOKIE_FILE" --fail --http1.1 \
  --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  --user-agent 'Mozilla/5.0 (X11; Linux x86_64; rv:58.0) Gecko/20100101 Firefox/58.0' \
  'https://pcsupport.lenovo.com/us/en/products/laptops-and-netbooks/thinkpad-x-series-laptops/thinkpad-x13s-type-21bx-21by/downloads/driver-list/' \
> /dev/null

# cSpell: ignore Referer
curl --silent --fail \
  --cookie-jar "$COOKIE_FILE" \
  --header 'Referer: https://pcsupport.lenovo.com/us/en/products/laptops-and-netbooks/thinkpad-x-series-laptops/thinkpad-x13s-type-21bx-21by/downloads/driver-list/' \
  --header 'Accept: application/json, text/plain, */*' \
  --user-agent 'Mozilla/5.0 (X11; Linux x86_64; rv:58.0) Gecko/20100101 Firefox/58.0' \
  'https://pcsupport.lenovo.com/us/en/api/v4/downloads/drivers?productId=laptops-and-netbooks%2Fthinkpad-x-series-laptops%2Fthinkpad-x13s-type-21bx-21by' \
| jq '[ .body.DownloadItems[] | { Summary, Title, Files: [.Files | sort_by(.Version) | .[] | { Name, TypeString, SHA256, Priority, URL, Version, Date }] } ]'
