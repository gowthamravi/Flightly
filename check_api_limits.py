import os
import requests
import json
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("AI_PROXY_KEY") or os.getenv("OPENAI_API_KEY")
BASE_URL = os.getenv("AI_PROXY_URL", "https://ai-proxy.lab.epam.com")

if not API_KEY:
    print("❌ Error: AI_PROXY_KEY or OPENAI_API_KEY not found in environment.")
    exit(1)

HEADERS = {"Api-Key": API_KEY}

def get_available_models():
    print("🔍 Fetching available models...")
    try:
        url = f"{BASE_URL}/openai/models"
        response = requests.get(url, headers=HEADERS)
        response.raise_for_status()
        return response.json().get("data", [])
    except Exception as e:
        print(f"❌ Error fetching models: {e}")
        return []

def get_model_limits(model_id):
    try:
        url = f"{BASE_URL}/v1/deployments/{model_id}/limits"
        response = requests.get(url, headers=HEADERS)
        
        if response.status_code == 200:
            return response.json()
        else:
            return None
    except:
        return None

def main():
    models = get_available_models()
    print(f"✅ Found {len(models)} models.")

    print("\n🔍 Checking limits for each model...")
    results = {}

    for model in models:
        model_id = model['id']
        limits = get_model_limits(model_id)
        
        if limits:
            minute_limit = limits.get("minuteTokenStats", {}).get("total", 0)
            day_limit = limits.get("dayTokenStats", {}).get("total", 0)
            
            # Filter to show only models where we have some allowance
            if minute_limit > 0 or day_limit > 0:
                results[model_id] = {
                    "limits": {
                        "minute_tokens": minute_limit,
                        "day_tokens": day_limit
                    }
                }
                print(f"  - {model_id}: {minute_limit} TPM / {day_limit} TPD")

    print("\n📊 Summary of Available Models with Limits:")
    print(json.dumps(results, indent=4))

if __name__ == "__main__":
    main()
