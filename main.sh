# TODO: detect config.txt file with line 1 $SERVER, line 2 $DIRECTORY

while :
do
    if [[ $(ls pics) ]]
    # Check for file in pics dir
    then
        echo "File detected in pics directory"

        # TODO: fix square size, scale, threshold
        python3 pixelbooth.py pics/* pics/output.png 1 1 1

        while :
            if [[ $(ls pics | grep "output.png")]]
            # Check for generated output
            then
                echo "Output image detected"

                # Gen random code for file
                while : 
                    CODE=$(shuf -n 1 -i 1000-9999)

                    # Regen if pic with code already existing
                    wget "${SERVER}/${DIRECTORY}/${CODE}.png" && continue

                    # Put rsync & HTML generation commands here
                    # TODO: input root password to server
                    rsync -avzP ./pics/output.png root@${SERVER}:${DIRECTORY}/${CODE}.png

                    sleep 1
                done
            sleep 1
        done
    sleep 1
done