# CLAMAV-AUTOSCAN

clamav-autoscan provides a ClamAV Docker image which automatically scans any new files added to a specified folder for viruses.

### Run

docker run --tty=true -v /folder/to/scan:/data clamav-autoscan
