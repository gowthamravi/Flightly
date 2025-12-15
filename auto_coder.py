import os
import json
import argparse
import openai
from jira import JIRA
from github import Github
from git import Repo
from dotenv import load_dotenv

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
g = Github(GITHUB_TOKEN)

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

    print(f"🧠 AI ({AI_MODEL_DEPLOYMENT}) is thinking...")
    
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
        
        content = response.choices[0].message.content
        return json.loads(content)
        
    except openai.APIError as e:
        print(f"❌ OpenAI API Error: {e}")
        return None
    except json.JSONDecodeError as e:
        print(f"❌ Error parsing JSON response: {e}")
        print(f"Raw content: {content}")
        return None
    except Exception as e:
        print(f"❌ Unexpected Error: {e}")
        return None

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ticket", required=True, help="Jira Ticket ID (e.g., DP-4)")
    parser.add_argument("--repo", required=True, help="GitHub repo name")
    # CHANGED: Prompt is now OPTIONAL. We default to None if not provided.
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

    # 2. Analyze Project
    print("📂 Analyzing Project Structure...")
    structure = get_file_structure(REPO_PATH)

    # 3. Generate Code
    # We pass the Jira Description as the primary instruction
    # args.prompt is just "extra" info now
    print("🧠 AI is reading the ticket and coding...")
    generated_data = generate_code_with_proxy(
        ticket_id=args.ticket, 
        description=ticket_instruction, 
        user_prompt=args.prompt, 
        structure=structure
    )
    
    if not generated_data:
        print("❌ Failed to generate code. Exiting.")
        return

    # 4. Git Operations
    repo = Repo(REPO_PATH)
    branch_name = f"feature/{args.ticket.lower()}-ai-auto"
    
    print(f"🌿 Creating branch {branch_name}...")
    
    # Check if we are on a clean slate
    repo.git.checkout('main')
    repo.git.pull()
    
    # Create or switch to branch
    try:
        new_branch = repo.create_head(branch_name)
    except OSError:
        # If branch exists, just check it out
        print("Branch exists, switching to it...")
        new_branch = repo.heads[branch_name]
        
    new_branch.checkout(force=True)

# 5. Write Files
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
        except Exception as e:
            print(f"⚠️ Failed to write file {file_path}: {e}")

    # 6. Commit & Push
    # ... (rest of script is fine)
    repo.index.commit(f"AI: Implemented {args.ticket}")
    print("🚀 Pushing to origin...")
    repo.remote().push(branch_name)

# ... (Steps 1 through 6 remain exactly the same) ...

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
