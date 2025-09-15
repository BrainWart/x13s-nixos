#!/usr/bin/env sh

curl --silent --fail \
	--header 'Referer: https://pcsupport.lenovo.com/us/en/products/laptops-and-netbooks/thinkpad-x-series-laptops/thinkpad-x13s-type-21bx-21by/downloads/driver-list/' \
	--header 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 Edg/140.0.0.0' \
	'https://pcsupport.lenovo.com/us/en/api/v4/downloads/drivers?productId=laptops-and-netbooks%2Fthinkpad-x-series-laptops%2Fthinkpad-x13s-type-21bx-21by' \
| jq '[ .body.DownloadItems[] | { Summary, Title, Files: [.Files | sort_by(.Version) | .[] | { Name, TypeString, SHA256, Priority, URL, Version, Date }] } ]'
