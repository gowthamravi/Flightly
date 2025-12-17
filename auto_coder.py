#!/usr/bin/env python3
import os
import json
import argparse
import openai
from jira import JIRA
from github import Github, Auth
from git import Repo
from dotenv import load_dotenv
import threading
import time
import sys
import subprocess
import requests
import re
# Removed pbxproj import

# Load environment variables from .env file
load_dotenv()

# --- CONFIGURATION ---
JIRA_SERVER = os.getenv("JIRA_SERVER")
JIRA_USER = os.getenv("JIRA_USER")
JIRA_TOKEN = os.getenv("JIRA_API_TOKEN")

# OpenAI Proxy Config (Azure Client)
AI_PROXY_KEY = os.getenv("AI_PROXY_KEY")
AI_MODEL_DEPLOYMENT = os.getenv("AI_MODEL_DEPLOYMENT", "gemini-2.5-pro")
AI_PROXY_URL = os.getenv("AI_PROXY_URL", "https://ai-proxy.lab.epam.com")
AI_API_VERSION = os.getenv("AI_API_VERSION", "")

GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
REPO_PATH = "./"

# Figma Config
FIGMA_TOKEN = os.getenv("FIGMA_TOKEN")
FIGMA_API_BASE = "https://api.figma.com/v1"

# --- Initialize Clients ---
# 1. OpenAI (Azure)
client = openai.AzureOpenAI(
    azure_endpoint=AI_PROXY_URL,
    api_key=AI_PROXY_KEY,
    api_version=AI_API_VERSION,
    azure_deployment=AI_MODEL_DEPLOYMENT
)

# 2. Jira & GitHub
jira = JIRA(server=JIRA_SERVER, basic_auth=(JIRA_USER, JIRA_TOKEN))
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
            # You can add .xib or .storyboard if needed
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

# --- FIGMA INTEGRATION ---
def extract_figma_key(text):
    """
    Extracts the Figma file key from a URL found in text.
    Matches: figma.com/file/KEY/... or figma.com/design/KEY/...
    """
    if not text:
        return None
    match = re.search(r"figma\.com/(?:file|design)/([a-zA-Z0-9]+)", text)
    if match:
        return match.group(1)
    return None

def get_figma_metadata(file_key):
    """
    Fetches minimal metadata (colors, text content) from the Figma file.
    """
    if not FIGMA_TOKEN:
        print("⚠️ FIGMA_TOKEN not found in environment. Skipping Figma extraction.")
        return None
    
    print(f"🎨 Fetching Figma Design: {file_key}")
    headers = {"X-Figma-Token": FIGMA_TOKEN}
    
    try:
        # Get file nodes (depth 2 to avoid huge payload)
        url = f"{FIGMA_API_BASE}/files/{file_key}?depth=2"
        resp = requests.get(url, headers=headers)
        
        if resp.status_code != 200:
            print(f"❌ Figma API Error: {resp.status_code} - {resp.text}")
            return None
        
        data = resp.json()
        document = data.get("document", {})
        
        # Simple extraction of what we found (Name, Last Modified, Components)
        summary = {
            "name": data.get("name"),
            "lastModified": data.get("lastModified"),
            "structure_preview": []
        }
        
        # Helper to traverse and capture interesting nodes (Frames/Text) from the first page
        def traverse(node):
            node_type = node.get("type")
            name = node.get("name")
            
            info = {"type": node_type, "name": name}
            
            if node_type == "TEXT":
                 # Extract standard characters if available (Figma API structure varies)
                 # Usually deep in style, but simplified here
                 pass
            
            if "children" in node:
                children_info = []
                for child in node["children"]:
                    # Recursively get children, but limit depth/count for token context
                    child_summary = traverse(child)
                    if child_summary:
                        children_info.append(child_summary)
                if children_info:
                    info["children"] = children_info
            
            return info

        # Only look at the first canvas (Page 1)
        if "children" in document and len(document["children"]) > 0:
            first_page = document["children"][0]
            summary["structure_preview"] = traverse(first_page)
        
        return json.dumps(summary, indent=2)

    except Exception as e:
        print(f"❌ Figma Exctraction Error: {e}")
        return None

# --- XCODE INTEGRATION (Ruby Bridge) ---
def add_file_to_xcode(file_path):
    """
    Adds a file to the Xcode project using the external Ruby script.
    """
    # Get absolute path of this script to find add_file.rb
    script_dir = os.path.dirname(os.path.abspath(__file__))
    ruby_script_path = os.path.join(script_dir, "add_file.rb")

    if not os.path.exists(ruby_script_path):
        print(f"⚠️ add_file.rb not found at {ruby_script_path}. CWD: {os.getcwd()}. Skipping Xcode registration.")
        return

    project_path = "FlightSearch.xcodeproj"
    target_name = "FlightSearch"
    
    # Use bundle exec to ensure gems are found
    cmd = ["bundle", "exec", "ruby", ruby_script_path, project_path, file_path, target_name]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"🔹 {result.stdout.strip()}")
        else:
            print(f"⚠️ Failed to add file to Xcode: {result.stderr.strip()}")
    except Exception as e:
        print(f"⚠️ Error running add_file.rb: {e}")

# --- BUILD VERIFICATION ---
def run_build_verification():
    """
    Attempts to build the project using xcodebuild.
    Returns (success: bool, output: str)
    """
    print("\n🔨 Verifying Build...")
    cmd = [
        "xcodebuild",
        "build",
        "-scheme", "FlightSearch",
        "-destination", "generic/platform=iOS Simulator",
        "CODE_SIGNING_ALLOWED=NO",
        "-quiet" # Reduce verbosity
    ]
    
    try:
        # Capture both stdout and stderr
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            print("✅ Build Succeeded!")
            return True, result.stdout
        else:
            print("❌ Build Failed!")
            # Return significant error lines
            error_log = "\n".join(result.stdout.splitlines()[-50:] + result.stderr.splitlines()[-20:])
            return False, error_log
    except Exception as e:
        print(f"❌ Verification Error: {e}")
        return False, str(e)

def generate_code_with_proxy(ticket_id, description, user_prompt, structure, previous_error=None, figma_data=None):
    """
    The Brain: Sends context to OpenAI Proxy and asks for JSON output.
    """
    
    system_prompt = "You are a Senior iOS Engineer. Return ONLY valid JSON."
    
    task_description = f"""
    TASK:
    Analyze the following Jira requirement and generate the necessary Swift code.
    You must also include a Unit Test (XCTest) file for the new functionality.
    
    CONTEXT:
    - Ticket ID: {ticket_id}
    - Description: {description}
    - User Instruction: {user_prompt}
    
    PROJECT STRUCTURE:
    {structure}
    """
    
    # Inject Figma Data if available
    if figma_data:
        task_description += f"""
        
        🎨 FIGMA DESIGN CONTEXT:
        The following structure was extracted from the linked Figma file. 
        Use the names and hierarchy to infer View names and structure.
        {figma_data}
        """

    if previous_error:
        task_description += f"""
        
        ⚠️ PREVIOUS BUILD FAILED ⚠️
        The code you generated previously failed to compile.
        Here is the build error log:
        {previous_error}
        
        PLEASE FIX THE CODE.
        """

    task_description += """
    OUTPUT FORMAT:
    Return a JSON object with this exact schema:
    {
        "files": [
            {
                "path": "path/to/NewFile.swift",
                "content": "import UIKit..."
            }
        ],
        "pr_title": "A concise title for the Pull Request",
        "pr_body": "A summary of changes for the PR description"
    }
    """
    
    user_message = task_description

    stop_event = threading.Event()
    loader_thread = threading.Thread(target=loading_animation, args=(stop_event,))
    loader_thread.start()
    
    try:
        response = client.chat.completions.create(
            model=AI_MODEL_DEPLOYMENT, # In Azure, model is often ignored if deployment is set in client, but passing it is safe
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
        print(f"Raw content: {content}")
        return None
    except Exception as e:
        stop_event.set()
        loader_thread.join()
        print(f"❌ Unexpected Error: {e}")
        return None

def write_files(generated_data, repo):
    for file_obj in generated_data['files']:
        # SANITIZE PATH: This fixes the "./" error by cleaning the path string
        raw_path = file_obj['path']
        file_path = os.path.normpath(raw_path) 
        
        print(f"📝 Writing {file_path}...")
        
        # Ensure directory exists
        try:
            os.makedirs(os.path.dirname(file_path), exist_ok=True)
            
            with open(file_path, "w") as f:
                f.write(file_obj['content'])
            
            # Add to Git
            repo.index.add([file_path])
            
            # Add to Xcode (Calling Ruby Script now)
            add_file_to_xcode(file_path)
            
        except Exception as e:
            print(f"⚠️ Failed to write file {file_path}: {e}")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ticket", required=True, help="Jira Ticket ID (e.g., DP-4)")
    parser.add_argument("--repo", required=True, help="GitHub repo name")
    parser.add_argument("--prompt", required=False, help="Extra hints (e.g., 'Use SwiftUI')", default="")
    args = parser.parse_args()

    # 1. Fetch Jira Info
    print(f"🔍 Fetching Jira Ticket {args.ticket}...")
    try:
        issue = jira.issue(args.ticket)
        # Get description, fallback to summary if empty
        ticket_instruction = issue.fields.description or issue.fields.summary
        print(f"📄 Found Requirements in Jira: {len(ticket_instruction)} chars")
    except Exception as e:
        print(f"❌ Error fetching Jira ticket: {e}")
        return
        
    # 2. Extract Figma Data
    figma_key = extract_figma_key(ticket_instruction)
    figma_data = None
    if figma_key:
        figma_data = get_figma_metadata(figma_key)
    else:
        print("ℹ️  No Figma URL found in ticket.")

    # 3. Analyze Project
    print("📂 Analyzing Project Structure...")
    structure = get_file_structure(REPO_PATH)

    # 4. Code Generation & Build Loop
    max_retries = 3
    retry_count = 0
    build_success = False
    build_error = None
    
    # 5. Git Operations - Init Branch early
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

    while retry_count < max_retries:
        if retry_count > 0:
            print(f"🔄 Attempt {retry_count + 1}/{max_retries}: Fixing build errors...")
        else:
            print("🧠 AI is reading the ticket and coding...")

        generated_data = generate_code_with_proxy(
            ticket_id=args.ticket, 
            description=ticket_instruction, 
            user_prompt=args.prompt, 
            structure=structure,
            previous_error=build_error,
            figma_data=figma_data
        )
        
        if not generated_data:
            print("❌ Failed to generate code. Exiting.")
            return

        # Write files
        write_files(generated_data, repo)
        
        # Verify Build
        success, output = run_build_verification()
        
        if success:
            build_success = True
            break
        else:
            build_error = output
            retry_count += 1
            
    if not build_success:
        print("❌ Failed to build after maximum retries. Aborting Push.")
        return

    # 6. Commit & Push
    repo.index.commit(f"AI: Implemented {args.ticket}")
    print("🚀 Pushing to origin...")
    repo.remote().push(branch_name)

    # 7. Create or Update PR
    print("✨ Checking for existing Pull Request...")
    gh_repo = g.get_repo(args.repo)
    
    # Check if a PR already exists for this branch
    existing_prs = gh_repo.get_pulls(state='open', head=f"{gh_repo.owner.login}:{branch_name}")
    
    if existing_prs.totalCount > 0:
        # PR exists! We already pushed the code in Step 6, so we are done.
        pr = existing_prs[0]
        print(f"🔄 PR already exists. Updated with new code: {pr.html_url}")
        
        # Optional: Add a comment saying we updated it
        pr.create_issue_comment(f"🔄 AI Agent updated the code based on Jira ticket {args.ticket}.")
    else:
        # No PR exists, create a new one
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
