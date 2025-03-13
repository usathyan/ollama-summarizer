# Ollama Summarizer Scripts

A collection of scripts for summarizing content using Ollama's local LLMs.

## Dependencies

- **ollama**: Required for all scripts. Used for text summarization.
- **lynx**: Required for webpage text extraction (for summarize-url.sh)
- **poppler-utils**: Required for PDF processing (for summarize-url.sh)

### Installation

On macOS:
```bash
# Install required tools
brew install ollama lynx poppler

# Pull the required Ollama model
ollama pull gemma3
```

On Ubuntu/Debian:
```bash
# Install required tools
sudo apt-get install lynx poppler-utils

# Install Ollama (follow instructions from their website)
curl https://ollama.ai/install.sh | sh

# Pull the required Ollama model
ollama pull gemma3
```

## Scripts

### hn-news.sh

Summarizes themes and opinions from Hacker News discussions.

#### Usage
```bash
./hn-news.sh <item_id>
```
Where `<item_id>` is the Hacker News item ID (found in the URL of the discussion).

#### Example
```bash
./hn-news.sh 42910829
```

The script will output a summary of discussion themes with relevant quotes.

### summarize-url.sh

Summarizes content from webpages and PDF documents, including special handling for arXiv papers.

#### Usage
```bash
./summarize-url.sh <url>
```
Where `<url>` can be:
- A webpage URL
- A PDF document URL
- An arXiv paper URL (both abstract and PDF URLs are supported)

#### Examples
```bash
# Summarize a webpage
./summarize-url.sh https://example.com

# Summarize a PDF
./summarize-url.sh https://example.com/document.pdf

# Summarize an arXiv paper
./summarize-url.sh https://arxiv.org/abs/2501.00148
```

#### Features
- Automatic handling of arXiv URLs
- PDF text extraction
- Webpage content extraction
- Error handling for various scenarios (authentication required, JavaScript-heavy sites, etc.)
- Retry mechanism for PDF downloads
- Temporary file cleanup

## Notes

- Both scripts use gemma3 as the default model. You can modify the scripts to use a different Ollama model if desired.
- The hn-news.sh script is based on Simon Willison's work (https://til.simonwillison.net/llms/claude-hacker-news-themes), modified for use with Ollama.
- For websites requiring authentication or heavy JavaScript, summarize-url.sh may not be able to extract content directly. In such cases, you can:
  1. Copy the text content directly from the webpage
  2. Save the page as PDF and use the PDF URL
  3. Use a public URL that doesn't require authentication