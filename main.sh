while :
do
    if [[ $(ls pics) ]]
    # Check whether there is a file in the pics directory
    then
        echo "File detected in pics directory"

        # Need to adjust numbers for optimal results
        # Arguments: input, output, square size, scale, threshold
        python3 pixelbooth.py pics/* pics/output.png 1 1 1

        while :
            if [[ $(ls pics | grep "output.png")]]
            # Check if output has been generated
            then
                # Put rsync & HTML generation commands here

        done
done