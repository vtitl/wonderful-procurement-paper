/* 
   This file provides functions for saving and reading scalar values from a LaTeX file.
   The intended use case is for each sub-folder to have its own scalar file as scalars.tex
   in the corresponding "results" folder.
*/

// Function to save a scalar value to LaTeX file
capture program drop save_scalar
program define save_scalar
    args key value filename comment
    local date    = c(current_date)
    local time    = c(current_time)
    local user    = c(username)
    local meta    = "written by `user' running STATA on `date' at `time'"
    if "`comment'" != "" {
        local fullcom = "`comment' --- `meta'"
    }
    else {
        local fullcom = "`meta'"
    }

    // Create directory if it doesn't exist
    local dirname = substr("`filename'", 1, strrpos("`filename'", "/") - 1)
    shell mkdir -p "`dirname'"
    
    // Check if the file exists
    capture confirm file "`filename'"
    if _rc == 0 {
        // File exists, remove any line with the current key and append new line
        tempfile tempfile
        shell grep -v "^\\\\newcommand{\\\\`key'}" "`filename'" > "`tempfile'"
        shell cp "`tempfile'" "`filename'"
        
        // Append the new key-value pair
        file open fh using "`filename'", write append
        file write fh "\newcommand{\\`key'}{`value'} % `fullcom'" _n
        file close fh
    }
    else {
        // File doesn't exist, create it with initial content
        file open fh using "`filename'", write
        file write fh "\newcommand{\\`key'}{`value'} % `fullcom'" _n
        file close fh
    }
    shell sort -o "`filename'" "`filename'"
    display "Scalar '`key'' saved with value '`value''"
end

// Function to read a scalar value from LaTeX file
capture program drop read_scalar
program define read_scalar, rclass
    args key filename
    
    // Check if the file exists
    capture confirm file "`filename'"
    if _rc != 0 {
        display "File not found"
        exit
    }
    
    // Use grep to find the line with the key
    tempfile keyline
    shell grep "^\\\\newcommand{\\\\`key'}" "`filename'" > "`keyline'"
    
    // Read the line from the temp file
    file open fh using "`keyline'", read
    local line_found = 0
    if _rc == 0 {
        file read fh line
        if r(eof) == 0 {
            local line_found = 1
        }
        file close fh
    }
    
    if `line_found' == 1 {
        // Parse the value using string functions

        local start = strpos("`line'", "}{") + 1
        local rest  = substr("`line'", `start'+1, .)
        local end   = strpos("`rest'", "}") 
        local value = substr("`rest'", 1, `end' - 1)

        // Return the value
        return local value = `value' 
        display "Value for key '`key'': `value'"
    }
    else {
        display as error "Key '`key'' not found in `filename'"
        exit 198
    }
end

// Example usage:
// save_scalar "myKey" "42.5" "results/scalars.tex"
// read_scalar "myKey" "results/scalars.tex"
// local value = r(value)