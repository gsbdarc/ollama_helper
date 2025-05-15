import argparse
import requests

def main():
    # Set up argument parsing.
    parser = argparse.ArgumentParser(
        description="Send a request to an Ollama API endpoint on a given node hostname and port."
    )
    parser.add_argument("--host", type=str, help="The hostname of the server's GPU node)")
    parser.add_argument("--port", type=str, default="11434", help="The port number for the API (default: 11434)")
    
    args = parser.parse_args()
    
    # Construct the URL using the provided hostname and port.
    url = f"http://{args.host}:{args.port}/api/generate"
    print(f"Sending request to URL: {url}")
    
    payload = {
        "model": "deepseek-r1:7b",
        "prompt": (
            "With the upcoming 100-year celebration this fall, how do you envision Stanford GSB using "
            "this milestone to inspire the next generation of business leaders? Identify two specific "
            "initiatives or themes that should be highlighted during the celebration, and discuss how "
            "these can both honor the school’s century-long legacy and shape innovative approaches to business "
            "education going forward. Provide examples to support your recommendations."
        ),
        "stream": False  # Disable streaming to get one complete response
    }
    headers = {"Content-Type": "application/json"}
    
    try:
        # Make the POST request.
        response = requests.post(url, json=payload, headers=headers)
        response.raise_for_status()
        # Assuming the API returns a JSON response, print the result.
        data = response.json()
        print(data['response'])
    except requests.exceptions.RequestException as e:
        print(f"An error occurred: {e}")

if __name__ == '__main__':
    main()

