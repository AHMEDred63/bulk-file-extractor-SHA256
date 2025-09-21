# bulk-file-extractor-SHA256(tested on MacOS terminal)
This script is designed to extract hash values from all files within a specified folder. If you want to extract all the hashes inside a particular directory, simply run this script. It will generate two output files:

A CSV file containing both the file path (or filename) and the corresponding hash.

A text file containing only the hash values, one per line.

Details about the Script:

Purpose: To help you quickly gather hash values for files in a specific folder, which can be useful for threat intelligence, malware analysis, and verification purposes.

Functionality: The script searches for files with specified extensions (like .jar, .exe, .zip, .pdf, .docx, .xls, .dll, and .bat), calculates their SHA-256 hash, and then saves the results in both a CSV and a TXT file.

Usage: Simply specify the folder path in the script, run it, and it will automatically generate the output files.(to run --> bash getBulkHash256.sh)

Output: You will get a CSV file with columns for the file path and the hash, and a TXT file with just the hash values.

For VT bulk Uploder --> https://github.com/AHMEDred63/VT-api-with-time-out.git
