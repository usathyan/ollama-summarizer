#!/bin/bash

# Check for required dependencies
check_dependencies() {
    if ! command -v pdftotext &> /dev/null; then
        echo "Error: pdftotext is not installed. Please install poppler-utils:"
        echo "  On macOS: brew install poppler"
        echo "  On Ubuntu/Debian: sudo apt-get install poppler-utils"
        exit 1
    fi
    if ! command -v lynx &> /dev/null; then
        echo "Error: lynx is not installed. Please install lynx:"
        echo "  On macOS: brew install lynx"
        echo "  On Ubuntu/Debian: sudo apt-get install lynx"
        exit 1
    fi
}

# Validate URL
if [ -z "$1" ]; then
    echo "Usage: $0 <url>"
    exit 1
fi

URL=$1
check_dependencies

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Function to extract text from PDF
process_pdf() {
    local pdf_file=$1
    local text
    
    # Check if file exists and is not empty
    if [ ! -s "$pdf_file" ]; then
        echo "Error: PDF file is empty or could not be downloaded"
        return 1
    fi
    
    # Try to extract text
    text=$(pdftotext "$pdf_file" - 2>/dev/null)
    
    # Check if text extraction was successful
    if [ -z "$text" ]; then
        echo "Error: Could not extract text from PDF. The file might be:"
        echo "1. Password protected"
        echo "2. Scanned images without OCR"
        echo "3. Corrupted or invalid PDF"
        return 1
    fi
    
    echo "$text"
}

# Function to extract text from webpage
process_webpage() {
    local url=$1
    local output
    
    # First try to fetch headers to check if the URL is accessible
    if ! curl -sI "$url" >/dev/null 2>&1; then
        echo "Error: Unable to access URL. The page might require authentication or JavaScript to load content."
        echo "Please try:"
        echo "1. Copy the text content directly from the webpage"
        echo "2. Save the page as PDF and use the PDF URL"
        echo "3. Use a public URL that doesn't require authentication"
        return 1
    fi
    
    # Use lynx to properly extract readable text from webpages
    output=$(lynx -dump -nolist -width=1000 "$url" 2>/dev/null | grep -v "^$" | sed 's/^[ \t]*//')
    
    # Check if we got meaningful content
    if [ -z "$output" ] || [[ "$output" =~ "400 Bad Request" ]] || [[ "$output" =~ "403 Forbidden" ]]; then
        echo "Error: Could not extract content from the URL. The page might:"
        echo "1. Require authentication"
        echo "2. Need JavaScript to load content"
        echo "3. Be blocking automated access"
        echo ""
        echo "Please try:"
        echo "1. Copy the text content directly from the webpage"
        echo "2. Save the page as PDF and use the PDF URL"
        echo "3. Use a public URL that doesn't require authentication"
        return 1
    fi
    
    echo "$output"
}

# Function to download PDF with proper headers
download_pdf() {
    local url=$1
    local output_file=$2
    local max_retries=3
    local retry=0
    local success=false
    
    while [ $retry -lt $max_retries ] && [ "$success" = false ]; do
        # Use curl with appropriate headers for PDF download
        if curl -L \
            -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" \
            -H "Accept: application/pdf,application/x-pdf" \
            -H "Accept-Language: en-US,en;q=0.9" \
            --connect-timeout 10 \
            -o "$output_file" \
            "$url"; then
            # Verify it's actually a PDF
            if file "$output_file" | grep -i "PDF document" >/dev/null; then
                success=true
            else
                rm -f "$output_file"  # Remove invalid file
                echo "Warning: Downloaded file is not a valid PDF, retrying..."
            fi
        fi
        retry=$((retry + 1))
        [ "$success" = false ] && [ $retry -lt $max_retries ] && sleep 2
    done
    
    [ "$success" = true ]
    return $?
}

# Function to handle arxiv URLs
process_arxiv_url() {
    local url=$1
    
    # Check if it's an arxiv URL
    if [[ "$url" =~ arxiv\.org ]]; then
        # If it's already a PDF URL, return as is
        if [[ "$url" =~ \.pdf$ ]]; then
            echo "$url"
            return 0
        fi
        
        # Extract the arxiv ID
        local arxiv_id
        if [[ "$url" =~ arxiv\.org/abs/([0-9]+\.[0-9]+) ]]; then
            arxiv_id="${BASH_REMATCH[1]}"
        elif [[ "$url" =~ arxiv\.org/pdf/([0-9]+\.[0-9]+) ]]; then
            arxiv_id="${BASH_REMATCH[1]}"
        else
            echo "Error: Could not extract arXiv ID from URL"
            return 1
        fi
        
        # Construct the direct PDF URL
        echo "https://arxiv.org/pdf/${arxiv_id}.pdf"
        return 0
    fi
    
    # Not an arxiv URL, return as is
    echo "$url"
    return 0
}

# Process the URL
PROCESSED_URL=$(process_arxiv_url "$URL")
if [ $? -ne 0 ]; then
    exit 1
fi

# Download and process the URL
if [[ "$PROCESSED_URL" == *".pdf" ]]; then
    # Handle PDF URL
    PDF_FILE="$TEMP_DIR/document.pdf"
    echo "Downloading PDF file from $PROCESSED_URL..."
    if download_pdf "$PROCESSED_URL" "$PDF_FILE"; then
        echo "Extracting text from PDF..."
        TEXT=$(process_pdf "$PDF_FILE")
        if [ $? -ne 0 ]; then
            # Error message already printed by process_pdf
            exit 1
        fi
    else
        echo "Error: Failed to download PDF from $PROCESSED_URL"
        echo "The URL might:"
        echo "1. Require authentication"
        echo "2. Be temporarily unavailable"
        echo "3. Have moved or been deleted"
        exit 1
    fi
else
    # Handle webpage URL
    TEXT=$(process_webpage "$PROCESSED_URL")
    if [ $? -ne 0 ]; then
        # Error message already printed by process_webpage
        exit 1
    fi
fi

# Validate we have content before passing to ollama
if [ -z "$TEXT" ]; then
    echo "Error: No content could be extracted from the URL"
    exit 1
fi

# Run ollama with the extracted text
printf '%s' "$TEXT" | ollama run gemma3 "Summarize the main points of this document in a bulleted list, followed by a brief overall summary. Include key quotes where relevant."