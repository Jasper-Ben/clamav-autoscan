# CLAMAV-AUTOSCAN

clamav-autoscan provides a ClamAV Docker image which automatically scans any new files added to a specified folder for viruses.

### Run

You can use the provided docker-compose file or something like this:
`docker run --tty=true -v /folder/to/scan:/data -v /folder/for/clean:/clean [-v /folder/for/infected:/infected] jasperben/clamav-autoscan`

### Usage

Any file with a size of up to 4GB placed in `/folder/to/scan` will be automatically scanned by clamav and moved into the appropriate folder. 
