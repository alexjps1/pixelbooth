# Pixelbooth

## About
A set of scripts for running a photo booth at club rush! It automates a photomosaic script, uploading, QR codes, and more!

## Instructions
Install all of the necessary dependencies listed below.  
Then, clone the repository.  
`git clone https://github.com/mchspc/pixelbooth`  
Make the shell script executable.  
`chmod +x ./main.sh`  
Then, edit the `config.txt` file with your favorite text editor, such as `vim`.  
`vim config.txt`  
Fill out lines 1-5 with the instructions contained in the file.

## Dependencies
In addition to the scripts used here, you need the dependencies listed here.
All of them are provided under freedom-respecting licenses and available via package managers such as `pacman` or `pip`.

- Linux (any distro with GNU coreutils)  
- Python 3+ (https://python.org)  
- Python qrcode module (https://pypi.org/project/qrcode/)  
- Rsync (https://rsync.samba.org)  
- SSH Pass (https://sourceforge.net/projects/sshpass/)

## Security
Pixelation, QR code generation, and HTML generation are performed entirely offline.
However, pictures are uploaded with SSH encryption to a remote server so they can be downloaded via link or QR code.

## Contact

Nathan  
Available on Slack

Alex  
mchspc@alexjps.com

PGP Public Key  
https://alexjps.com/pubkey  
72280122083ECEDE31EAC32C22BD48E34FA00D44  
Tutanota emails will be encrypted properly
