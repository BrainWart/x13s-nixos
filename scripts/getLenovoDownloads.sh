#!/bin/sh

curl --silent --fail \
	--header 'Referer: https://pcsupport.lenovo.com/us/en/products/laptops-and-netbooks/thinkpad-x-series-laptops/thinkpad-x13s-type-21bx-21by/downloads/driver-list/' \
	'https://pcsupport.lenovo.com/us/en/api/v4/downloads/drivers?productId=laptops-and-netbooks%2Fthinkpad-x-series-laptops%2Fthinkpad-x13s-type-21bx-21by'
