#!/bin/bash

# VERSION 1.3

# Exit on error and error on pipeline failure
set -e
set -o pipefail

# Check if the correct number of arguments is given
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 SOURCE_IMAGE_PATH PAN_IMAGE_PATH SUBJECT_IMAGE_PATH OUTPUT_IMAGE_PATH"
    exit 1
fi

SOURCE=$1
PAN=$2
SUBJECT=$3
OUTPUT=$4
CAL_SUBJECT="CAL_${SUBJECT##*/}"
RES_SUBJECT="RES_${SUBJECT##*/}"
PRODUCT_BGR="BGR_${SUBJECT##*/}"

# Function to extract and normalize mean values using otbcli_ComputeImagesStatistics
extract_and_normalize_means() {
    local image_path=$1
    local divisor=$2
    # Extract means and normalize
    echo $(otbcli_ComputeImagesStatistics -il "$image_path" | \
           awk '/Mean:/ {print; getline; print; getline; print}' | \
           grep -o '[0-9]\+\.[0-9]\+' | \
           awk -v div="$divisor" '{print $1/div}' | \
           xargs)
}

# Compute and normalize means for SOURCE (divided by 255) and SUBJECT (divided by 2047)
means_source=$(extract_and_normalize_means "$SOURCE" 255)       # SOURCE is uint8
means_subject=$(extract_and_normalize_means "$SUBJECT" 2047)    # SUBJECT is uint16 but max value is always 2047

# Read into arrays
read -r -a source_means <<< "$means_source"
read -r -a subject_means <<< "$means_subject"

# Compute calibration factors
# SOURCE is RGB while SUBJECT is BGR
factorR=$(echo "${source_means[0]} / ${subject_means[0]}" | bc -l)
factorG=$(echo "${source_means[1]} / ${subject_means[1]}" | bc -l)
factorB=$(echo "${source_means[2]} / ${subject_means[2]}" | bc -l)

# Apply calibration factors to SUBJECT image
otbcli_BandMathX -il "$SUBJECT" -out "$CAL_SUBJECT" uint16 -exp "(im1b1 * $factorR) ; (im1b2 * $factorG) ; (im1b3 * $factorB); (im1b4)"

# Upscale the calibrated image to match the PAN image
otbcli_Superimpose -inr "$PAN" -inm "$CAL_SUBJECT" -out "$RES_SUBJECT" uint16

# Pansharpen the upscaled image
otbcli Pansharpening -inp "$PAN" -inxs "$RES_SUBJECT" -method bayes -out "$PRODUCT_BGR" uint16

otbcli_BandMathX -il "$PRODUCT_BGR" -out "$OUTPUT" uint8 -exp "min(im1b3, 1024) / 4; min(im1b2, 1024) / 4; min(im1b1, 1024) / 4"

# Clean up intermediate files
rm "$RES_SUBJECT" "$PRODUCT_BGR"

echo "Process completed. The pansharpened image is saved as $OUTPUT."
