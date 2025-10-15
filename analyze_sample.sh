#!/bin/bash

# Check for sample name input
if [ -z "$1" ]; then
  echo "Usage: $0 <sample_name>"
  exit 1
fi

# Sample and config
SAMPLE=$1
THREADS=12
DB="minikraken2_v1_8GB"
READ_LEN=150

# Define color codes
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Paths
RAW_DIR="/mnt/d/Oxonic_Acid_Project_Files/In_Vivo_OA_Microbiome_Affects_Metagenomic_Data/Data/01.RawData/${SAMPLE}"
CLEANED_DIR="/mnt/d/Bioinformatics/cleaned_reads"
KRAKEN2_OUT_DIR="/mnt/d/Bioinformatics/kraken2_outputs"
KRAKEN2_REPORT_DIR="/mnt/d/Bioinformatics/kraken2_reports"
BRACKEN_OUT_DIR="/mnt/d/Bioinformatics/bracken_outputs"
BRACKEN_REPORT_DIR="/mnt/d/Bioinformatics/bracken_reports"

R1="${RAW_DIR}/${SAMPLE}_L2_1.fq.gz"
R2="${RAW_DIR}/${SAMPLE}_L2_2.fq.gz"

CLEANED_R1="${CLEANED_DIR}/${SAMPLE}_cleaned_R1.fastq.gz"
CLEANED_R2="${CLEANED_DIR}/${SAMPLE}_cleaned_R2.fastq.gz"
KRAKEN2_REPORT="${KRAKEN2_REPORT_DIR}/${SAMPLE}_report.k2report"
KRAKEN2_OUTPUT="${KRAKEN2_OUT_DIR}/${SAMPLE}.kraken2"
BRACKEN_OUTPUT="${BRACKEN_OUT_DIR}/${SAMPLE}_boutput.bracken"
BRACKEN_REPORT="${BRACKEN_REPORT_DIR}/${SAMPLE}_breports.breports"

# ------------------ Bowtie2 + Samtools ------------------
echo -e "${YELLOW}Bowtie2 started at:${NC} ${BLUE}$(date)${NC}"
SECONDS=0

bowtie2 --threads $THREADS -x mouse_index -1 $R1 -2 $R2 --very-sensitive | \
samtools view -@ $THREADS -b -f 12 -F 256 - | \
samtools collate -@ $THREADS -o - - | \
samtools fastq -@ $THREADS \
  -1 >(pigz -p $THREADS > $CLEANED_R1) \
  -2 >(pigz -p $THREADS > $CLEANED_R2) \
  -n -

echo -e "${YELLOW}Bowtie2 completed at:${NC} ${BLUE}$(date)${NC}"
echo -e "${GREEN}Bowtie2 elapsed time:${NC} ${SECONDS} seconds"
echo ""

# ------------------ Kraken2 ------------------
echo -e "${YELLOW}Kraken2 started at:${NC} ${BLUE}$(date)${NC}"
SECONDS=0

kraken2 --db $DB --threads $THREADS \
  --report $KRAKEN2_REPORT \
  --paired --minimum-hit-groups 2 \
  $CLEANED_R1 $CLEANED_R2 > $KRAKEN2_OUTPUT

echo -e "${YELLOW}Kraken2 completed at:${NC} ${BLUE}$(date)${NC}"
echo -e "${GREEN}Kraken2 elapsed time:${NC} ${SECONDS} seconds"
echo ""

# ------------------ Bracken ------------------
echo -e "${YELLOW}Bracken started at:${NC} ${BLUE}$(date)${NC}"
SECONDS=0

bracken -d $DB -i $KRAKEN2_REPORT -r $READ_LEN -l F -t $THREADS \
  -o $BRACKEN_OUTPUT -w $BRACKEN_REPORT

echo -e "${YELLOW}Bracken completed at:${NC} ${BLUE}$(date)${NC}"
echo -e "${GREEN}Bracken elapsed time:${NC} ${SECONDS} seconds"
