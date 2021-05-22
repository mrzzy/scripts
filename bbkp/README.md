# Borgmatic Backup
Borg/Borgmatic Backup configuration &amp; makefile.
- :warning: Currently on supports backup on PopOS / Ubuntu Linux with Systemd.


## Setup / Removal
Install `borgmatic` and configs using:
```sh
sudo make install BORG_REPO=/path/to/repo BORG_PASSPHRASE=some_passphrase
```
> now `borgmatic` will be triggered via systemd everyday to perform a backuP

Uninstall `borgmatic` and configs the same way:
```sh
sudo make uninstall BORG_REPO=/path/to/repo BORG_PASSPHRASE=some_passphrase
```
