# Pixelbooth

## About
A set of scripts for an automated photobooth with effects, QR codes, and more!

## Clean Repository
Please delete local copies of of this repository cloned prior to Sep 30, 2021.  
The repository has been de-bloated by removing large image files, and there is a risk of bringing the back by pushing commits from an old cloned version.
Re-clone the repository using `git clone`, as `git pull` won't do the job.

## Instructions
Install all of the necessary dependencies listed below.  
Then, clone the repository.  
`git clone https://github.com/mchspc/pixelbooth`  
Make the shell script executable.  
`chmod +x ./main.sh`  
Then, edit the `config.txt` file with your favorite text editor, such as `vim`.  
`vim config.txt`  
Fill out lines 1-5 with the instructions contained in the file.  
Then run the main shell script.  
`./main.sh`

## Dependencies
In addition to the scripts used here, you need the dependencies listed here.
Any Linux distro with the GNU coreutils should work, but the project has been tested on Arch Linux specifically.
All of them are provided under freedom-respecting licenses and available via package managers such as `pacman` or `pip`.

- [Linux](https://archlinux.org)
- [Python 3+](https://python.org)  
- [Python qrcode module](https://pypi.org/project/qrcode/)  
- [Python pillow module](https://pypi.org/project/pillow/)
- [Rsync](https://rsync.samba.org)  
- [SSH Pass](https://sourceforge.net/projects/sshpass/)

## Security
Pixelation, QR code generation, and HTML generation are performed entirely offline.
However, pictures are uploaded with SSH encryption to a remote server so they can be downloaded via link or QR code.

## Contact

Nathan, Harnoor, Anish
See respective GitHub profiles

Alex JPS
[git@alexjps.com](mailto:git@alexjps.com)
[alexjps.com/pubkey](https://alexjps.com/pubkey)  
