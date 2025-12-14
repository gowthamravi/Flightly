import os
import json
import argparse
import time
import subprocess
import hashlib
import re
import requests
import warnings

# Suppress warnings
warnings.filterwarnings("ignore", category=FutureWarning, module="google.api_core")
warnings.filterwarnings("ignore", category=DeprecationWarning)

# FIX for Python < 3.10: Backport packages_distributions
try:
    import importlib.metadata
    import importlib_metadata
    if not hasattr(importlib.metadata, "packages_distributions"):
        importlib.metadata.packages_distributions = importlib_metadata.packages_distributions
except ImportError:
    pass # If importlib_metadata is missing, we can't fix it.

import google.generativeai as genai

from jira import JIRA
from github import Github
from git import Repo
from dotenv import load_dotenv
from PIL import Image
from io import BytesIO

# Load environment variables
load_dotenv()

# --- CONFIGURATION ---
JIRA_SERVER = os.getenv("JIRA_SERVER")
JIRA_USER = os.getenv("JIRA_USER")
JIRA_TOKEN = os.getenv("JIRA_API_TOKEN")
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
FIGMA_TOKEN = os.getenv("FIGMA_TOKEN")
REPO_PATH = "./"

# --- Initialize Clients ---
genai.configure(api_key=GOOGLE_API_KEY)

# Using gemini-1.5-flash because it is fast and supports IMAGES (Vision)
model = genai.GenerativeModel('gemini-2.5-flash-lite', generation_config={"response_mime_type": "application/json"})

jira = JIRA(server=JIRA_SERVER, basic_auth=(JIRA_USER, JIRA_TOKEN))
g = Github(GITHUB_TOKEN)

def get_file_structure(path):
    file_list = []
    for root, dirs, files in os.walk(path):
        if ".git" in root or "Pods" in root or "build" in root or ".xcodeproj" in root:
            continue
        for file in files:
            if file.endswith(".swift"):
                file_list.append(os.path.join(root, file))
    return "\n".join(file_list)

def compute_hash(text):
    if not text: return "empty"
    return hashlib.md5(text.encode('utf-8')).hexdigest()

def extract_hash_from_pr(pr_body):
    if not pr_body: return None
    pattern = r''
    match = re.search(pattern, pr_body)
    if match and match.lastindex and match.lastindex >= 1:
        return match.group(1)
    return None

# --- FIGMA LOGIC ---
def extract_figma_info(text):
    """Finds Figma URL and extracts File Key and Node ID"""
    if not text: return None, None
    # Regex matches: figma.com/design/FILE_KEY/... or figma.com/file/FILE_KEY/...
    # AND looks for ?node-id=123-456
    match = re.search(r'figma\.com/(?:file|design)/([a-zA-Z0-9]+)[^?]*\?.*?node-id=([0-9%2D-]+)', text)
    if match:
        file_key = match.group(1)
        node_id = match.group(2).replace('%2D', '-')
        return file_key, node_id
    return None, None

def download_figma_image(file_key, node_id):
    """Downloads the specific frame/node as a PNG image"""
    if not FIGMA_TOKEN:
        print("⚠️ No FIGMA_TOKEN found in .env. Skipping image download.")
        return None

    headers = {"X-Figma-Token": FIGMA_TOKEN}
    
    # FIX: Figma API often expects colons (0:1) instead of dashes (0-1)
    node_id_colon = node_id.replace('-', ':')
    
    print(f"🎨 Fetching Figma Image (File: {file_key}, Node: {node_id})...")
    
    # We request BOTH formats in the API call to be safe
    url = f"https://api.figma.com/v1/images/{file_key}?ids={node_id},{node_id_colon}&format=png&scale=2"
    
    try:
        res = requests.get(url, headers=headers)
        data = res.json()
        
        if "err" in data and data["err"]:
            print(f"❌ Figma API Error: {data['err']}")
            return None
            
        # Try finding the image url with either ID format
        image_url = data.get("images", {}).get(node_id) or data.get("images", {}).get(node_id_colon)
        
        if not image_url:
            print(f"❌ Could not find image URL. API keys returned: {list(data.get('images', {}).keys())}")
            return None

        # Download the actual image bytes
        img_res = requests.get(image_url)
        return Image.open(BytesIO(img_res.content))
        
    except Exception as e:
        print(f"❌ Failed to download Figma image: {e}")
        return None

# --- GEN AI WITH VISION ---
def generate_code_with_gemini(ticket_id, description, user_prompt, structure, figma_image=None):
    task_prompt = "Analyze requirements. Generate Swift code & Unit Tests. Handle CORNER CASES."
    
    vision_instruction = ""
    if figma_image:
        print("👁️ Sending Figma Image + Text to Gemini...")
        vision_instruction = "VISUAL INSTRUCTION: Use the attached Figma design image as the SINGLE SOURCE OF TRUTH for UI layout, spacing, and colors."

    text_prompt = f"""
    You are a Senior iOS Engineer.
    TASK: {task_prompt}
    {vision_instruction}
    
    CONTEXT: {ticket_id} - {description}
    User Note: {user_prompt}
    
    PROJECT STRUCTURE: {structure}
    OUTPUT FORMAT (JSON ONLY): {{ "files": [ {{ "path": "...", "content": "..." }} ], "pr_title": "...", "pr_body": "..." }}
    """
    
    print("🧠 Gemini is thinking...")
    for attempt in range(2):
        try:
            # Prepare inputs: [Text] OR [Text, Image]
            inputs = [text_prompt]
            if figma_image:
                inputs.append(figma_image)
                
            response = model.generate_content(inputs)
            
            text = response.text.strip()
            if text.startswith("```json"): text = text[7:]
            if text.startswith("```"): text = text[3:]
            if text.endswith("```"): text = text[:-3]
            return json.loads(text)
        except Exception as e:
            print(f"❌ Gemini Error (Attempt {attempt+1}): {e}")
            continue
    return None

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ticket", required=True)
    parser.add_argument("--repo", required=True)
    parser.add_argument("--prompt", required=False, default="")
    args = parser.parse_args()

    # 1. Setup & Jira
    print(f"🔍 Fetching Jira Ticket {args.ticket}...")
    try:
        issue = jira.issue(args.ticket)
        desc = issue.fields.description or issue.fields.summary
    except Exception as e:
        print(f"❌ Jira Error: {e}")
        return
    
    # Calculate hash of requirements
    current_hash = compute_hash((desc or "") + (args.prompt or ""))
    
    # 2. Check for Figma Link
    file_key, node_id = extract_figma_info(desc)
    figma_image = None
    if file_key and node_id:
        figma_image = download_figma_image(file_key, node_id)
    
    # 3. Branch & Repo Setup
    gh_repo = g.get_repo(args.repo)
    repo = Repo(REPO_PATH)
    
    try:
        git_user = repo.config_reader().get_value("user", "name").replace(" ", "").lower()
    except: git_user = "agent"
    try:
        issue_type = issue.fields.issuetype.name.lower().replace(" ", "-")
    except: issue_type = "task"
    branch_name = f"{git_user}/{issue_type}/{args.ticket.lower()}"

    # 4. Check Skip Logic
    existing_prs = gh_repo.get_pulls(state='open', head=f"{gh_repo.owner.login}:{branch_name}")
    need_generation = True
    pr_title = f"[{args.ticket}] Implementation"
    pr_body = "Automated implementation"

    if existing_prs.totalCount > 0:
        pr = existing_prs[0]
        last_hash = extract_hash_from_pr(pr.body)
        
        if last_hash == current_hash:
            print(f"⚡ JIRA Hash Match. No changes in requirements.")
            need_generation = False
            pr_title = pr.title
            pr_body = pr.body or "Automated implementation"
        else:
            print(f"📝 JIRA Description changed! Regenerating...")
            need_generation = True

    # 5. AI Generation Loop
    if need_generation:
        print("🧠 Starting Generation...")
        
        # Reset Branch
        if repo.active_branch.name != branch_name:
            repo.git.checkout('main')
            repo.git.fetch('origin')
            repo.git.reset('--hard', 'origin/main')
            if branch_name in repo.heads:
                new_branch = repo.heads[branch_name]
            else:
                new_branch = repo.create_head(branch_name)
            new_branch.checkout(force=True)

        structure = get_file_structure(REPO_PATH)
        
        # Call Gemini (With Image if available)
        data = generate_code_with_gemini(args.ticket, desc, args.prompt, structure, figma_image)
        
        if not data:
            print("❌ Aborting: Gemini failed to generate valid code.")
            return
            
        pr_title = f"[{args.ticket}] {data.get('pr_title', 'Update')}"
        pr_body = data.get('pr_body', 'Updates')

        # Write Files
        for f in data['files']:
            path = os.path.normpath(f['path'])
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "w") as file: file.write(f['content'])
            repo.index.add([path])
            print(f"📝 Wrote {path}")
            
        repo.index.commit(f"Gemini: {args.ticket}")
        print("🚀 Pushing code...")
        repo.remote().push(branch_name)

    # 6. Update/Create PR
    print("✨ Updating Pull Request...")
    hidden_meta = f""
    
    safe_body = pr_body if pr_body else "Automated implementation"
    clean_body = re.sub(r'', '', safe_body).strip()
    
    if figma_image:
        clean_body = "**🎨 Designed from Figma**\n" + clean_body

    final_body = f"### Jira: {args.ticket}\n\n{clean_body}\n\n{hidden_meta}"

    if existing_prs.totalCount > 0:
        existing_prs[0].edit(title=pr_title, body=final_body)
        print(f"✅ PR Updated: {existing_prs[0].html_url}")
    else:
        pr = gh_repo.create_pull(title=pr_title, body=final_body, head=branch_name, base="main")
        print(f"✅ PR Created: {pr.html_url}")

if __name__ == "__main__":
    main()
