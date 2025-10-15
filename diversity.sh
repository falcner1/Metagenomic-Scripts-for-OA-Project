#!/bin/bash

# Directory containing Bracken output files
INPUT_DIR="/mnt/d/Bioinformatics/bracken_outputs"
OUTPUT_FILE="/mnt/d/Bioinformatics/diversity_summary.tsv"

# Clear or create the output file with header
echo -e "Sample\tMetric\tValue" > "$OUTPUT_FILE"

# Loop through all Bracken output files
for FILE in "$INPUT_DIR"/*_boutput.bracken; do
    SAMPLE=$(basename "$FILE" _boutput.bracken)

    # Define the metrics to run
    for METRIC in BP Sh F Si ISi; do
        # Run diversity analysis and capture output
        RESULT=$(python /mnt/d/KrakenTools-master/DiversityTools/alpha_diversity.py \
            -f "$FILE" \
            -a "$METRIC" | tail -n 1 | awk -F': ' '{print $2}')

        # Append result to summary table
        echo -e "${SAMPLE}\t${METRIC}\t${RESULT}" >> "$OUTPUT_FILE"
    done
done

echo "Diversity analysis complete. Results saved to $OUTPUT_FILE"
