#!/usr/bin/env bash
set -euo pipefail

# --- helpers ---
have() { command -v "$1" >/dev/null 2>&1; }

# Choose hasher (Linux usually has sha256sum; macOS has shasum)
if have sha256sum; then
  HASH_CMD=(sha256sum)
elif have shasum; then
  HASH_CMD=(shasum -a 256)
else
  echo "❌ Need 'sha256sum' or 'shasum' installed." >&2
  exit 1
fi

# Ask for folder path (loop until valid)
while :; do
  read -rp "Enter the folder path to scan: " folder
  if [ -d "$folder" ]; then
    break
  fi
  echo "❌ Folder does not exist. Please try another path."
done

# Ask for extra extensions (optional), comma or space separated
read -rp "Enter additional extensions (comma separated, e.g. txt,log) or press Enter to skip: " extra_ext

# Base extensions
base_exts=(jar exe zip pdf docx xls dll bat)

# Build final extension list
exts=("${base_exts[@]}")       # start with base
user_exts=()                   # <-- pre-initialize to avoid 'unbound variable'

if [ -n "${extra_ext:-}" ]; then
  # split on comma or space
  IFS=' ,'
  read -r -a user_exts <<< "$extra_ext"
  unset IFS

  # normalize and append
  for e in "${user_exts[@]}"; do
    [ -n "${e:-}" ] || continue
    e="${e#.}"                 # strip leading dot if provided
    e="${e//[[:space:]]/}"     # trim any stray spaces
    [ -n "$e" ] && exts+=("$e")
  done
fi

echo "🔎 Scanning: $folder"
echo "🔎 Extensions: ${exts[*]}"

# Prepare outputs
csv_out="hashes.csv"
txt_out="hashes.txt"
echo "File,Hash" > "$csv_out"
: > "$txt_out"

# Build find command safely
find_args=( "$folder" -type f \( )
for i in "${!exts[@]}"; do
  pat="*.${exts[$i]}"
  if [ "$i" -eq 0 ]; then
    find_args+=( -iname "$pat" )
  else
    find_args+=( -o -iname "$pat" )
  fi
done
find_args+=( \) -print0 )

# Walk files and hash them
count=0
while IFS= read -r -d '' file; do
  hash="$("${HASH_CMD[@]}" "$file" | awk '{print $1}')"

  # CSV-escape path (quote, double any embedded quotes)
  file_escaped=${file//\"/\"\"}
  printf '"%s",%s\n' "$file_escaped" "$hash" >> "$csv_out"
  printf '%s\n' "$hash" >> "$txt_out"

  count=$((count+1))
done < <(find "${find_args[@]}")

echo "✅ Done: $count files processed"
echo "📄 CSV : $csv_out"
echo "📄 TXT : $txt_out"
