#!/bin/bash

source_file=$1
target_file=$2
diff_file=$3

LOG_FILE="/tmp/diff_count_comparison_summary.log"

{
  echo "-------------------------------------------------"
  echo "          DATABASE COUNT COMPARISON REPORT      "
  echo "-------------------------------------------------"
  echo ""
} >"$LOG_FILE"

compare_files() {
  local src="$1"
  local tgt="$2"
  local diff="$3"

  if [[ -f "$src" && -f "$tgt" ]]; then
    diff --side-by-side --suppress-common-lines "$src" "$tgt" >"$diff"

    if [[ -s "$diff" ]]; then
      echo "[DIFFERENCES FOUND] - See: $diff" | tee -a "$LOG_FILE"
    else
      echo "[MATCH] - No differences detected." | tee -a "$LOG_FILE"
    fi
  else
    echo "[SKIPPED] - One or both files are missing." | tee -a "$LOG_FILE"
  fi
  echo "" | tee -a "$LOG_FILE"
}

compare_files "$source_file" "$target_file" "$diff_file"

{
  echo "-------------------------------------------------"
  echo "    COMPARISON PROCESS COMPLETED SUCCESSFULLY    "
  echo "-------------------------------------------------"
  echo "Review the log file at: $LOG_FILE"
} | tee -a "$LOG_FILE"
