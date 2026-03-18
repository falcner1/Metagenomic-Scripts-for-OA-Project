#!/usr/bin/env bash
set -euo pipefail

# ---- USER SETTINGS ----
DB="minikraken2_v1_8GB"                           # Bracken/Kraken database basename (folder with database150mers.kmer_distrib)
READ_LEN=150                                      # -r
LEVEL="F"                                         # -l F : family
THRESH=10                                         # -t
IN_DIR="/mnt/d/Bioinformatics/kraken2_reports"    # where the *.k2report files live
OUT_TSV_DIR="/mnt/d/Bioinformatics/bracken_outputs_family"
OUT_W_DIR="/mnt/d/Bioinformatics/bracken_reports_family" # kreport-like outputs from Bracken
LOG_DIR="/mnt/d/Bioinformatics/bracken_logs_family"
# -----------------------

mkdir -p "$OUT_TSV_DIR" "$OUT_W_DIR" "$LOG_DIR"

shopt -s nullglob
mapfile -t REPORTS < <(find "$IN_DIR" -maxdepth 1 -type f -name "*_report.k2report" | sort)
shopt -u nullglob

if (( ${#REPORTS[@]} == 0 )); then
  echo "No files matching '*_report.k2report' in $IN_DIR"
  exit 1
fi

echo "Found ${#REPORTS[@]} Kraken2 report(s). Starting Bracken..."

for rpt in "${REPORTS[@]}"; do
  # Example file: /mnt/d/.../ctrl1_3_report.k2report  -> sample=ctrl1_3
  base=$(basename "$rpt")
  sample="${base%_report.k2report}"

  out_tsv="$OUT_TSV_DIR/${sample}_boutput.bracken"
  out_w="$OUT_W_DIR/${sample}_breports.kreport"
  log="$LOG_DIR/${sample}.log"

  echo "[$(date +'%F %T')] Running Bracken for sample: $sample"
  {
    set -x
    bracken \
      -d "$DB" \
      -i "$rpt" \
      -r "$READ_LEN" \
      -l "$LEVEL" \
      -t "$THRESH" \
      -o "$out_tsv" \
      -w "$out_w"
    set +x
    echo "[$(date +'%F %T')] Done: $sample"
  } &> "$log"

done

echo "All jobs complete. Logs in: $LOG_DIR"
echo "Tables: $OUT_TSV_DIR"
echo "Bracken kreports: $OUT_W_DIR"