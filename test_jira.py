import os
from dotenv import dotenv_values, load_dotenv

# 1. Force load the .env file
load_dotenv()

# 2. Print all keys found (hiding values for security)
print("--- DEBUGGING .ENV FILE ---")
config = dotenv_values(".env") 
if not config:
    print("❌ ERROR: Could not read .env file. Is it definitely in this folder?")
    print(f"Current Folder: {os.getcwd()}")
else:
    print("✅ Found .env file! Keys inside:")
    for key in config.keys():
        print(f"   - {key}")

# 3. Check the specific token
token = os.getenv("JIRA_API_TOKEN")
print("\n--- CHECKING TOKEN ---")
if token:
    print(f"✅ Python sees JIRA_API_TOKEN (Length: {len(token)})")
else:
    print("❌ Python sees JIRA_API_TOKEN as EMPTY or NONE.")

# 4. Try hardcoded check (only if you want to test the token itself)
# jira = JIRA(server=..., basic_auth=(...))