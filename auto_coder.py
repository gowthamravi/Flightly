
import os
import sys
import argparse
import time
import threading
import json
import subprocess
import requests
import re
from github import Github, Auth
from jira import JIRA
from git import Repo
from dotenv import load_dotenv
import openai

# Load environment variables
load_dotenv()

JIRA_SERVER = os.getenv("JIRA_SERVER")
JIRA_USER = os.getenv("JIRA_USER")
JIRA_API_TOKEN = os.getenv("JIRA_API_TOKEN")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
AI_PROXY_KEY = os.getenv("AI_PROXY_KEY")
FIGMA_TOKEN = os.getenv("FIGMA_TOKEN")

# Setup Clients
jira = JIRA(server=JIRA_SERVER, basic_auth=(JIRA_USER, JIRA_API_TOKEN))

# Configure OpenAI Proxy
client = openai.AzureOpenAI(
    api_key=AI_PROXY_KEY,
    api_version="2024-02-01",
    azure_endpoint="https://ai-proxy.lab.epam.com"
)
AI_MODEL_DEPLOYMENT = "gpt-4o"  # Use the correct deployment name

# Github Auth
g = Github(auth=Auth.Token(GITHUB_TOKEN))

def get_file_structure(path):
    """
    Reads the file structure so the AI knows where to put files.
    """
    file_list = []
    for root, dirs, files in os.walk(path):
        if ".git" in root or "Pods" in root or "build" in root or ".xcodeproj" in root:
            continue
        for file in files:
            if file.endswith(".swift"):
                file_list.append(os.path.join(root, file))
    return "\n".join(file_list)

def loading_animation(stop_event):
    """
    Prints dots while waiting for the AI response.
    Cycles through ., .., ..., and clears.
    """
    chars = [".  ", ".. ", "..."]
    idx = 0
    while not stop_event.is_set():
        sys.stdout.write("\r" + "🧠 AI is thinking" + chars[idx % len(chars)])
        sys.stdout.flush()
        idx += 1
        time.sleep(0.5)
    
    # Clear the line when done
    sys.stdout.write("\r" + " " * 30 + "\r")
    sys.stdout.flush()

def extract_figma_key(url):
    """
    Extracts the file key from a Figma URL.
    Supports: https://www.figma.com/file/KEY/... or https://www.figma.com/design/KEY/...
    """
    match = re.search(r"figma\.com/(?:file|design)/([a-zA-Z0-9]+)", url)
    if match:
        return match.group(1)
    return None

def get_figma_metadata(file_key, token):
    """
    Fetches file metadata from Figma API.
    """
    if not token:
        return "Figma Token is missing. Cannot fetch design details."

    headers = {"X-Figma-Token": token}
    url = f"https://api.figma.com/v1/files/{file_key}"
    
    try:
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            data = response.json()
            name = data.get("name", "Unknown Design")
            last_modified = data.get("lastModified", "")
            # We can extract more structure if needed, but for now getting the name verify it exists
            return f"Figma Design Name: {name} (Last Modified: {last_modified})"
        else:
            return f"Error fetching Figma data: {response.text}"
    except Exception as e:
        return f"Exception fetching Figma data: {e}"

def add_file_to_xcode(file_path, target_name="FlightSearch"):
    """
    Calls the Ruby script to add the file to the Xcode project.
    """
    ruby_script = os.path.abspath("add_file.rb")
    project_path = os.path.abspath("FlightSearch.xcodeproj")
    
    if not os.path.exists(ruby_script):
        print(f"⚠️ Warning: add_file.rb not found at {ruby_script}. Skipping Xcode updates.")
        return

    # Use 'bundle exec ruby' to ensure gems are loaded correctly
    cmd = ["bundle", "exec", "ruby", ruby_script, project_path, file_path, target_name]
    
    try:
        # Capture output to debug if needed
        result = subprocess.run(cmd, capture_output=True, text=True, cwd=os.getcwd())
        if result.returncode == 0:
            print(f"✅ Xcode updated for {os.path.basename(file_path)}")
        else:
            print(f"⚠️ Failed to update Xcode for {file_path}:\n{result.stderr}")
    except Exception as e:
        print(f"⚠️ Error running add_file.rb: {e}")

def generate_code_with_proxy(ticket_id, description, user_prompt, structure):
    """
    The Brain: Sends context to OpenAI Proxy and asks for JSON output.
    """
    
    system_prompt = "You are a Senior iOS Engineer. Return ONLY valid JSON."
    
    user_message = f"""
    TASK:
    Analyze the following Jira requirement and generate the necessary Swift code.
    You must also include a Unit Test (XCTest) file for the new functionality.
    
    CONTEXT:
    - Ticket ID: {ticket_id}
    - Description: {description}
    - User Instruction: {user_prompt}
    
    PROJECT STRUCTURE:
    {structure}
    
    OUTPUT FORMAT:
    Return a JSON object with this exact schema:
    {{
        "files": [
            {{
                "path": "path/to/NewFile.swift",
                "content": "import UIKit..."
            }}
        ],
        "pr_title": "A concise title for the Pull Request",
        "pr_body": "A summary of changes for the PR description"
    }}
    """

    stop_event = threading.Event()
    loader_thread = threading.Thread(target=loading_animation, args=(stop_event,))
    loader_thread.start()
    
    try:
        response = client.chat.completions.create(
            model=AI_MODEL_DEPLOYMENT,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_message}
            ],
            temperature=0.2,
            response_format={"type": "json_object"}
        )
        
        stop_event.set()
        loader_thread.join()
        
        content = response.choices[0].message.content
        return json.loads(content)
        
    except openai.APIError as e:
        stop_event.set()
        loader_thread.join()
        print(f"❌ OpenAI API Error: {e}")
        return None
    except json.JSONDecodeError as e:
        stop_event.set()
        loader_thread.join()
        print(f"❌ Error parsing JSON response: {e}")
        return None
    except Exception as e:
        stop_event.set()
        loader_thread.join()
        print(f"❌ Unexpected Error: {e}")
        return None

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ticket", required=True, help="Jira Ticket ID (e.g., DP-4)")
    parser.add_argument("--repo", required=True, help="GitHub repo name")
    parser.add_argument("--prompt", required=False, help="Extra hints (e.g., 'Use SwiftUI')", default="")
    args = parser.parse_args()
    
    REPO_PATH = os.getcwd()

    # 1. Fetch Jira Info
    print(f"🔍 Fetching Jira Ticket {args.ticket}...")
    try:
        issue = jira.issue(args.ticket)
        ticket_instruction = issue.fields.description or issue.fields.summary
        print(f"📄 Found Requirements in Jira: {len(ticket_instruction)} chars")
    except Exception as e:
        print(f"❌ Error fetching Jira ticket: {e}")
        return

    # 1.5 Figma Integration
    extra_context = ""
    # Check if prompt contains figma url
    if args.prompt and "figma.com" in args.prompt:
        print("🎨 Figma URL detected. Analyzing design...")
        file_key = extract_figma_key(args.prompt)
        if file_key:
            figma_info = get_figma_metadata(file_key, FIGMA_TOKEN)
            extra_context += f"\n\n[FIGMA METADATA]\n{figma_info}\n"
            print(f"   - {figma_info}")
        else:
            print("⚠️ Could not extract Figma key from URL.")
    
    full_prompt = args.prompt + extra_context

    # 2. Analyze Project
    print("📂 Analyzing Project Structure...")
    structure = get_file_structure(REPO_PATH)

    # 3. Generate Code
    print("🧠 AI is reading the ticket and coding...")
    generated_data = generate_code_with_proxy(
        ticket_id=args.ticket, 
        description=ticket_instruction, 
        user_prompt=full_prompt, 
        structure=structure
    )
    
    if not generated_data:
        print("❌ Failed to generate code. Exiting.")
        return

    # 4. Git Operations
    repo = Repo(REPO_PATH)
    branch_name = f"feature/{args.ticket.lower()}-ai-auto"
    
    print(f"🌿 Creating branch {branch_name}...")
    
    repo.git.checkout('main')
    repo.git.pull()
    
    try:
        new_branch = repo.create_head(branch_name)
    except OSError:
        print("Branch exists, switching to it...")
        new_branch = repo.heads[branch_name]
        
    new_branch.checkout(force=True)
    
    # RESTORE TOOLING
    print("🔧 Restoring tooling files from main...")
    try:
        repo.git.checkout("main", "--", "add_file.rb", "Gemfile", "run_autocoder.sh")
    except Exception as e:
        print(f"⚠️ Failed to restore tooling files: {e}")


    # 5. Write Files
    for file_obj in generated_data['files']:
        raw_path = file_obj['path']
        file_path = os.path.normpath(raw_path) 
        
        print(f"📝 Writing {file_path}...")
        
        try:
            os.makedirs(os.path.dirname(file_path), exist_ok=True)
            
            with open(file_path, "w") as f:
                f.write(file_obj['content'])
            
            repo.index.add([file_path])
            
            # Add to Xcode
            if file_path.endswith(".swift"):
                add_file_to_xcode(file_path)
                repo.index.add(["FlightSearch.xcodeproj/project.pbxproj"])
                
        except Exception as e:
            print(f"⚠️ Failed to write file {file_path}: {e}")

    # 6. Commit & Push
    repo.index.commit(f"AI: Implemented {args.ticket}")
    print("🚀 Pushing to origin...")
    repo.remote().push(branch_name)

    # 7. Create or Update PR
    print("✨ Checking for existing Pull Request...")
    gh_repo = g.get_repo(args.repo)
    
    existing_prs = gh_repo.get_pulls(state='open', head=f"{gh_repo.owner.login}:{branch_name}")
    
    if existing_prs.totalCount > 0:
        pr = existing_prs[0]
        print(f"🔄 PR already exists. Updated with new code: {pr.html_url}")
        pr.create_issue_comment(f"🔄 AI Agent updated the code based on Jira ticket {args.ticket}.")
    else:
        try:
            print("🆕 Creating new Pull Request...")
            pr = gh_repo.create_pull(
                title=f"[{args.ticket}] {generated_data['pr_title']}",
                body=f"### Jira: [{args.ticket}]({JIRA_SERVER}/browse/{args.ticket})\n\n{generated_data['pr_body']}\n\n*Generated by AI Agent 🤖*",
                head=branch_name,
                base="main"
            )
            print(f"✅ Success! PR Created: {pr.html_url}")
        except Exception as e:
            print(f"⚠️ PR Creation failed: {e}")

if __name__ == "__main__":
    main()
