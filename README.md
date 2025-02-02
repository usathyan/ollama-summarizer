hn-news.sh - A script to summarize the themes of opinions expressed in a Hacker News discussion.

Dependencies: Make sure you have ollama installed. The script uses gemma2, change it if you want to use a different model.

Usage:
- Run the script with an integer argument representing the Hacker News item ID.
- You can get the news iD when you navigate to the topic discussion.

Example:
- `./hn-news.sh 42910829`

Installation:
- Just clone this repo, or copy the shell script to your PATH
- chmod +x hn-news.sh

The script will output a summary of the themes and quotes from the discussion, formatted as follows:

```
Themes:
- Scientific Fraud & Misconduct
- Alzheimer's Research
- Ethical Considerations

Quotes:
- "This research is fraudulent and should be retracted."
- "I'm concerned about the validity of this study."
- "Ethical issues in Alzheimer's research need to be addressed."
```

Note: The script uses the ollama summarizer to generate the summary. Ensure that ollama is installed and available in your PATH.

Notes: This is a modified script based on https://til.simonwillison.net/llms/claude-hacker-news-themes#user-content-adding-a--m-model-option for my personal use only. If this helps anyone else - please thank Simon for sharing his knowledge. You can enhance the script to accept a model parameter, I dont - I have no interest in evaluating models, I needed this to just summarize articles!
