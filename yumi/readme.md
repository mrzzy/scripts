# YUMI - YoUrls Manipulation Interface
---
*YUMI* is Comamnd Line Interface for manipulating a YoUrls installation, 
allowing you to:
* Create Shortlinks  
`yumi -m really.long.url rlu`
* Delete Shortlinks  
`yumi -d really.long.url rlu`
* Expand Shortlinks  
`yumi -x rlu` or `yumi -x your_url_server.com/rlu`

from the command line interface.

**Highlights**
1. Persistent saving of YoURLs server and access signature, alowing you to 
	configure once and forget when using **YUMI**
2. Force option allows you to forcefully redefine a shortlink without the hassle
	of checking if the link already exists or not.
3. Portable accross most Unix-like OS's (Linux,macOS,...)
	Only depends on the POSIX standard and `curl`.

## Install
1. Retrieve this git repository & change directory to repository
2. Run `make install`
> During the installation, the installer would prompt you for the YoURLs server
> to use and the signature used to access the server.
3. Profit.

## Remove
1. Change directory to repository
2. Run `make remove`

## Usage
* Create Shortlinks  
`yumi -m really.long.url rlu`
* Create Shortlink forcefully, deleting previous shortlinks if necessary.  
`yumi -mf really.long.url rlu` 
* Expand Shortlinks  
`yumi -x rlu` or `yumi -x your_url_server.com/rlp`
* Delete Shortlinks  
`yumi -d really.long.url rlu`
> The [Delete](https://github.com/claytondaley/yourls-api-delete) plugin has 
to be installed YouURLs server for deletion to work using YUMI

```
yumi [-fdx] [-t <server>] [-s <signature>] [-m <destination>] <keyword/shorturl>
-f - force action, even if it means that the action is destructive, 
not necessary for delete operation
-x - expand shortened url by 'keyword' or 'shorturl' to its long form.
-d - delete url shortcut by the name of 'keyword' or 'shorturl'
-m - map 'destination' url to shortened url by 'keyword' or 'shorturl'
-s - set persitent signature key to use when querying the YourURL server
-t - set persitent target yourURL server to query.
-h - print this usage infomation
```

## Misc
* YUMI is named after Yumi in
[Yumi's Cells](http://www.webtoons.com/en/romance/yumi-cell/list?title_no=478)
* Inspired by simliar tool [shorten.fish](https://github.com/jethrokuan/fish-yourls),
for the `fish` shell. Just that, most people don't `fish`, ya know?
