# Set variables from config file
SERVER=$(sed -n 1p config.txt)
DIRECTORY=$(sed -n 2p config.txt)
LINK=$(sed -n 3p config.txt)
PASSWORD=$(sed -n 4p config.txt)

# Handle variable errors or show definitions
if [ -z "${SERVER}" ]; then echo "[!] \$SERVER variable error" && VAR_ERROR=true ; else echo "[ ] \$SERVER set to \"${SERVER}\"" ; fi
if [ -z "${DIRECTORY}" ]; then echo "[!] \$DIRECTORY variable error" && VAR_ERROR=true ; else echo "[ ] \$DIRECTORY set to \"${DIRECTORY}\"" ; fi
if [ -z "${LINK}" ]; then echo "[!] \$LINK variable error" && VAR_ERROR=true ; else echo "[ ] \$LINK set to \"${LINK}\"" ; fi
if [ -z "${PASSWORD}" ]; then echo "[!] \$PASSWORD variable error" && VAR_ERROR=true ; else echo "[ ] \$PASSWORD set and omitted" ; fi
if [ ! -z "${VAR_ERROR}" ]; then echo "[!] Check definitions in config.txt" && exit ; fi

# Make sure there are some images in 'processed'
while : 
do
    if [[ $(ls processed) ]] 
    then
        echo "[ ] Processed images found"
        break
    else
        echo "[!] No processed images"
        python3 process.py || echo "[!] Processing images failed" && continue
        echo "[ ] Images processed"
    fi
done

# Make sure processed images are up-to-date with collage
# 'processed' should not be last modified at a time before 'collage-images'
# 'processed' should have the same file count as 'collage-images'
while :
do
    if [ $(stat -c %Y collage-images) -gt $(stat -c %Y processed) ] || [ $(ls -1 collage-images | wc -l) -ne $(ls -1 processed | wc -l) ]
    then
        echo "[!] Processed images appear out-of-date"
        python3 process.py || echo "[!] Processing images failed" && continue
        echo "[ ] Images processed"
    else
        echo "[ ] Processed images appear up-to-date"
        break
    fi
done

# Main loop
# Setup is done, so everything from hereon out will repeat indefinitely
while :
do

    echo "[ ] Waiting for new picture"

    while :
    do
        # Check for file in pics directory
        [[ $(ls pics) ]] && echo "[ ] New picture detected" && break
        sleep 0.5
    done

    while :
    do
        # Pixelate image with pixelate.py
        # TODO: fix square size, scale, threshold
        # TODO: make sure there are no files except .info and input file
        (python3 pixelate.py pics/* pics/output.png 1 1 1) && echo "[ ] Image pixelated" && break
        echo "[!] Pixelation failed"
        rm pics/output.png
    done

    while :
    do
        [[ $(ls pics | grep "output.png") ]] && echo "[ ] Output image detected" && break
        sleep 0.5
    done

    while : 
    do
        # Gen random code
        CODE=$(shuf -n 1 -i 1000-9999)
        echo "[ ] Code ${CODE} generated"

        # Regen if pic with code already existing
        # TODO: Hide output of wget if possible
        wget "${LINK}/${CODE}" && echo "[!] Code already in use" && continue
        echo "[ ] Code verified as unique"
        break
    done

    while :
    do
        # Upload to server
        sshpass -p "${PASSWORD}" rsync -avzP ./pics/output.png ${SERVER}:${DIRECTORY}/${CODE}.png && echo "[ ] Image uploaded" && echo "[ ] Image accessible at ${LINK}/${CODE}" && break
        echo "[!] Upload failed"
    done

    # TODO: QR code generation
    # TODO: HTML page generation & display
    # TODO: DWM integration and desktop switching

    # Clear out pictures directory so it's ready for next time
    rm pics/*

done