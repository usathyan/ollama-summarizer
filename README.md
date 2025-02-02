hn-news.sh - A script to summarize the themes of opinions expressed in a Hacker News discussion.

Dependencies: Make sure you have ollama installed. The script uses gemma2, change it if you want to use a different model.

Usage:
- Run the script with an integer argument representing the Hacker News item ID.
- You can get the news iD when you navigate to the topic discussion.

Example:
- `./hn-news.sh 42910829`

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

