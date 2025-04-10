import argparse
import requests

# Set up argument parsing
parser = argparse.ArgumentParser(description="Send a request to an Ollama API endpoint on a given node hostname.")
parser.add_argument("hostname", type=str, help="The hostname of the node (e.g., sh04-01n07)")
args = parser.parse_args()

# Construct the URL using the provided hostname
url = f"http://{args.hostname}:11434/api/generate"

payload = {
    "model": "deepseek-r1:70b",
    "prompt": "With the upcoming 100-year celebration this fall, how do you envision Stanford GSB using this milestone to inspire the next generation of business leaders? Identify two specific initiatives or themes that should be highlighted during the celebration, and discuss how these can both honor the school’s century-long legacy and shape innovative approaches to business education going forward. Provide examples to support your recommendations.",
    "stream": False  # Disable streaming to get one complete response
}
headers = {"Content-Type": "application/json"}

# Make the POST request
response = requests.post(url, json=payload, headers=headers)

# Assuming the API returns a JSON response, print the result.
data = response.json()
print(data)

