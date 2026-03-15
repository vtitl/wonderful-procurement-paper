#!/usr/bin/env bash
#
# refresh_output.sh
# ------------------------------------------------------------
# (i)  Find every file under writing/paper/output/ (recursively)
#      *except* those ending in “_tabonly.tex”.
# (ii) Delete those files, keeping the list.
# (iii) Copy the correspondingly-named files from ./output/ to
#       writing/paper/output/, creating sub-directories as needed.
# (iv) Run the “tab-only” sed filter on some files to create "_tabonly" versions.
# ------------------------------------------------------------

set -euo pipefail                                # safest Bash defaults

SRC_DIR="output"                                 # where the fresh files live
DST_DIR="writeup/output"                   # where they should end up
LIST_FILE="$(mktemp)"                            # temp file to hold the list

##############################################################################
# helper: make a _tabonly copy of one file (path *relative* to $DST_DIR)
##############################################################################
make_tabonly () {
  local rel="$1"                       # e.g. "foo/bar/ABC.tex"
  local tex="$DST_DIR/$rel"
  local out="${tex%.tex}_tabonly.tex"

  if [[ -f $tex ]]; then
    printf '  ↳ extracting tabular from %s → %s\n' "$rel" "${out##*/}"
    sed -n '/\\begin{tabular}/,/\\end{tabular}/{
              /\\end{tabular}/ s/\\end{tabular}.*/\\end{tabular}/
              p
            }' "$tex" > "$out"
  else
    printf '  ⚠️  %s not found — skipped\n' "$rel" >&2
  fi
}


# ------------------------------------------------------------
# Step (i)  – gather every *non-tabonly* file presently in DST_DIR
# ------------------------------------------------------------
find "$DST_DIR" -type f ! -name '*_tabonly.tex' > "$LIST_FILE"

# ------------------------------------------------------------
# Step (ii) – delete every file on the list
#             (xargs is faster & copes with long lists safely)
# ------------------------------------------------------------
if [[ -s "$LIST_FILE" ]]; then
    printf 'Deleting %s file(s)…\n' "$(wc -l < "$LIST_FILE")"
    xargs -0 rm -f < <(tr '\n' '\0' < "$LIST_FILE")
else
    echo "Nothing to delete."
fi

# ------------------------------------------------------------
# Step (iii) – copy the matching fresh files across
# ------------------------------------------------------------
echo "Copying replacements from \"$SRC_DIR/\"…"
while IFS= read -r dst_path; do
    # Strip the leading destination prefix to get the relative path
    rel_path="${dst_path#"$DST_DIR"/}"
    src_path="$SRC_DIR/$rel_path"

    if [[ -e "$src_path" ]]; then
        mkdir -p "$(dirname "$dst_path")"       # create sub-dirs if needed
        cp "$src_path" "$dst_path"
    else
        echo "⚠️  Source missing: $src_path" >&2
    fi
done < "$LIST_FILE"

# ------------------------------------------------------------
# Tidy up
# ------------------------------------------------------------
rm -f "$LIST_FILE"
echo "Done."
