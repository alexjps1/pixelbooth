# TODO: DWM integration and desktop switching

# Interrupt sequence
trap cleanup INT
function cleanup() {
    echo "[!] Script interrupted"
    pkill ${BROWSER}
    rm actions/*
    rm workspace/*
    echo "[ ] Cleared workspace"
    echo "[ ] Goodbye!"
    echo "TIP: Run manage.sh to copy/move/delete archived data"
    exit
}

# Set variables from config file
SERVER=$(sed -n 1p config.txt)
DIRECTORY=$(sed -n 2p config.txt)
LINK=$(sed -n 3p config.txt)
PASSWORD=$(sed -n 4p config.txt)
BROWSER=$(sed -n 5p config.txt)
PIXELATION=$(sed -n 6p config.txt)
SOCIAL=$(sed -n 7p config.txt)
MODE=$(sed -n 8p config.txt)
DIMENSIONS=$(sed -n 9p config.txt)

# Handle variable errors or show definitions
if [ -z "${SERVER}" ]; then echo "[!] \$SERVER variable error" && VAR_ERROR=true ; else echo "[ ] \$SERVER set to \"${SERVER}\"" ; fi
if [ -z "${DIRECTORY}" ]; then echo "[!] \$DIRECTORY variable error" && VAR_ERROR=true ; else echo "[ ] \$DIRECTORY set to \"${DIRECTORY}\"" ; fi
if [ -z "${LINK}" ]; then echo "[!] \$LINK variable error" && VAR_ERROR=true ; else echo "[ ] \$LINK set to \"${LINK}\"" ; fi
if [ -z "${PASSWORD}" ]; then echo "[!] \$PASSWORD variable error" && VAR_ERROR=true ; else echo "[ ] \$PASSWORD set and omitted" ; fi
if [ -z "${BROWSER}" ]; then echo "[!] \$BROWSER variable error" && VAR_ERROR=true ; else echo "[ ] \$BROWSER set to \"${BROWSER}\"" ; fi
if [ -z "${PIXELATION}" ]; then echo "[!] \$PIXELATION variable error" && VAR_ERROR=true ; else echo "[ ] \$PIXELATION set to \"${PIXELATION}\"" ; fi
if [ -z "${SOCIAL}" ]; then echo "[!] \$SOCIAL variable error" && VAR_ERROR=true ; else echo "[ ] \$SOCIAL set to \"${SOCIAL}\"" ; fi
if [ -z "${MODE}" ]; then echo "[!] \$MODE variable error" && VAR_ERROR=true ; else echo "[ ] \$MODE set to \"${MODE}\"" ; fi
if [ -z "${DIMENSIONS}" ]; then echo "[!] \$DIMENSIONS variable error" && VAR_ERROR=true ; else echo "[ ] \$DIMENSIONS set to \"${DIMENSIONS}\"" ; fi

if [ ! -z "${VAR_ERROR}" ]; then echo "[!] Check definitions in config.txt" && exit ; fi

# Prepare based on selected mode
if [ "$MODE" == "mosaic" ]
then
    # Make sure there are images to process
    [[ -z $(ls collage-images) ]] && echo "[!] No images in collage-images" && exit

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
elif [ "$MODE" == "overlay" ]
then
    # Make sure there are images to overlay
    [[ -z $(ls overlay-images) ]] && echo "[!] No images in overlay-images" && exit
    echo "[ ] Overlay images found"
else
    echo "[!] \$MODE not set to a valid mode"
    exit
fi

# Main loop
# Setup is done, so everything from hereon out will repeat indefinitely
while :
do
    OFFLINE=false

    echo "[ ] Waiting for new picture"

    while :
    do
        # Check for file in workspace directory
        [[ $(ls workspace) ]] && echo "[ ] New picture detected" && break
        sleep 0.5
    done

    # Will select what to do based on mode
    if [ "$MODE" == "mosaic" ]
    then
        while :
        do
            # Pixelate image with pixelate.py
            (python3 pixelate.py workspace/* workspace/output.png ${PIXELATION}) && echo "[ ] Image pixelated" && break
            echo "[!] Pixelation failed"
            rm workspace/output.png
        done
    elif [ "$MODE" == "overlay" ]
    then
        while :
        do
            # Overlay image with overlay.py
            (python3 overlay.py workspace/* ${DIMENSIONS}) && echo "[ ] Image overlaid" && break
            echo "[!] Overlaying failed"
            rm workspace/output.png
        done
    else
        echo "[!] \$MODE not set to a valid mode"
        exit
    fi

    while :
    do
        [[ $(ls workspace | grep "output.png") ]] && echo "[ ] Output image detected" && break
        sleep 0.5
    done

    # Check for internet
    if $(wget -O /dev/null "${SERVER}" &> /dev/null)
    then
        # Actions with working internet
        echo "[ ] Internet connection detected"
        while : 
        do
            # Gen random code
            CODE=$(shuf -n 1 -i 1000-9999)
            echo "[ ] Code ${CODE} generated"

            # Regen if pic with code already existing online or in archive
            wget "${LINK}/${CODE}" &> /dev/null && echo "[!] Code already in use" && continue
            [[ $(ls archive/images | grep ${CODE}) ]] && echo "[!] Code already in use" && continue
            echo "[ ] Code verified as unique"
            break
        done

        # Rename file to its code
        mv workspace/output.png workspace/${CODE}.png
        
        while :
        do
            # Upload to server
            sshpass -p "${PASSWORD}" rsync -avzP ./workspace/${CODE}.png ${SERVER}:${DIRECTORY}/${CODE}.png && echo "[ ] Image uploaded" && echo "[ ] Made accessible at ${LINK}/${CODE}" && break
            echo "[!] Upload failed"

            # Note file as not uploaded on fail
            echo "$(date -R -u)" > archive/not-uploaded/${CODE}.txt
            OFFLINE=true
            echo "[ ] Marked ${CODE} as not uploaded"
            break
        done
    else
        # Actions when working offline
        echo "[!] Working offline"
        OFFLINE=true
        while : 
        do
            # Gen random code with extra entropy
            CODE=$(shuf -n 1 -i 100000-999999)
            echo "[ ] Extra entropy code ${CODE} generated"

            # Regen if pic with code already existing online or in archive
            [[ $(ls archive/images | grep ${CODE}) ]] && echo "[!] Code already in use locally" && continue
            echo "[ ] Code verified as unique locally"
            break
        done

        # Rename file to its code
        mv workspace/output.png workspace/${CODE}.png

        # Note file as not upladed
        echo "$(date -R -u)" > archive/not-uploaded/${CODE}.txt
        OFFLINE=true
        echo "[ ] Marked ${CODE} as not uploaded"
    fi

    # Generate QR code
    qr "${LINK}/${CODE}" > workspace/qr.png

    # Generate HTML page
    TITLE=$(shuf -n 1 titles.txt)
    cp webpage/instagram.png workspace/instagram.png
    cp webpage/camera.png workspace/camera.png
    cp webpage/template.html workspace/page.html
    cp webpage/styles.css workspace/styles.css
    sed -i s\#\(TITLEHERE\)\#"${TITLE}"\#g workspace/page.html
    sed -i s\#\(LINKHERE\)\#"${LINK}/${CODE}"\#g workspace/page.html
    sed -i s\#\(SOCIALHERE\)\#"${SOCIAL}"\#g workspace/page.html
    sed -i s\#\(CODEHERE\)\#"${CODE}"\#g workspace/page.html
    if $OFFLINE
    then
        sed -i s\#\(DOWNLOADMSGHERE\)\#"(Working offline, download later)"\#g workspace/page.html
    else
        sed -i s\#\(DOWNLOADMSGHERE\)\#""\#g workspace/page.html
    fi
    echo "[ ] HTML generated"

    # Create receipt and exit action files
    touch actions/exit-action.raw
    echo "$(date -R -u)" > actions/${CODE}-receipt.raw

    # Display page
    ${BROWSER} workspace/page.html &> /dev/null &
    echo "[ ] Displaying page"

    # Check whether approve or return button pressed
    while :
    do
        [[ $(ls workspace | grep ${CODE}-receipt.raw) ]] && mv workspace/${CODE}-receipt.raw archive/receipts && echo "[ ] Allow receipt collected for image ${CODE}" 
        [[ $(ls workspace | grep exit-action.raw) ]] && pkill ${BROWSER} && echo "[ ] Browser closed" && break
    done

    # Clear out workspace directory so it's ready for next time
    mv workspace/${CODE}.png archive/images
    rm actions/*
    rm workspace/*
    echo "[ ] Cleared workspace"

done