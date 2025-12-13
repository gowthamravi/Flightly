import os
import json
import argparse
import time
import subprocess
import hashlib
import re
import google.generativeai as genai
from jira import JIRA
from github import Github
from git import Repo
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# --- CONFIGURATION ---
JIRA_SERVER = os.getenv("JIRA_SERVER")
JIRA_USER = os.getenv("JIRA_USER")
JIRA_TOKEN = os.getenv("JIRA_API_TOKEN")
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
XCODE_SCHEME = os.getenv("XCODE_SCHEME", "Flightly") 
DEVICE_NAME = os.getenv("XCODE_DEVICE", "iPhone 15")
REPO_PATH = "./"

# --- Initialize Clients ---
genai.configure(api_key=GOOGLE_API_KEY)
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

def run_terminal_command(command):
    """Runs a shell command and returns (success_bool, output_string)"""
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    return (result.returncode == 0, result.stdout + "\n" + result.stderr)

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

def build_and_test():
    """Runs xcodebuild to validate the app."""
    print(f"🛠️ Building Scheme '{XCODE_SCHEME}'...")
    cmd = f"xcodebuild -scheme '{XCODE_SCHEME}' -destination 'platform=iOS Simulator,name={DEVICE_NAME}' clean build CODE_SIGNING_ALLOWED=NO"
    success, output = run_terminal_command(cmd)
    
    if not success:
        error_lines = [line for line in output.split("\n") if "error:" in line or "failed" in line]
        return False, "\n".join(error_lines[:20])
        
    print("✅ Build Successful! Running Tests...")
    return True, "Build Passed"

def take_screenshot(branch_name):
    """Boots simulator and takes screenshot."""
    print("📸 Taking Screenshot...")
    run_terminal_command(f"xcrun simctl boot '{DEVICE_NAME}'")
    time.sleep(5) 
    
    filename = f"screenshots/{branch_name.replace('/', '_')}.png"
    os.makedirs("screenshots", exist_ok=True)
    
    run_terminal_command(f"xcrun simctl io '{DEVICE_NAME}' screenshot {filename}")
    
    if os.path.exists(filename):
        print(f"📸 Screenshot saved: {filename}")
        return filename
    return None

def generate_code_with_gemini(ticket_id, description, user_prompt, structure, error_context=None):
    if error_context:
        print("🚑 Asking Gemini to fix build errors...")
        task_prompt = f"PREVIOUS CODE CAUSED ERRORS. FIX THEM:\n{error_context}\nRefactor code to fix."
    else:
        task_prompt = "Analyze requirements. Generate Swift code & Unit Tests. Handle CORNER CASES."

    prompt = f"""
    You are a Senior iOS Engineer.
    TASK: {task_prompt}
    CONTEXT: {ticket_id} - {description}
    User Note: {user_prompt}
    PROJECT STRUCTURE: {structure}
    OUTPUT FORMAT (JSON ONLY): {{ "files": [ {{ "path": "...", "content": "..." }} ], "pr_title": "...", "pr_body": "..." }}
    """
    
    for attempt in range(2):
        try:
            response = model.generate_content(prompt)
            text = response.text.strip()
            if text.startswith("```json"): text = text[7:]
            if text.startswith("```"): text = text[3:]
            if text.endswith("```"): text = text[:-3]
            return json.loads(text)
        except: continue
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
    
    current_hash = compute_hash((desc or "") + (args.prompt or ""))
    
    # 2. Branch & Repo Setup
    gh_repo = g.get_repo(args.repo)
    repo = Repo(REPO_PATH)
    
    try:
        git_user = repo.config_reader().get_value("user", "name").replace(" ", "").lower()
    except: git_user = "agent"
    try:
        issue_type = issue.fields.issuetype.name.lower().replace(" ", "-")
    except: issue_type = "task"
    branch_name = f"{git_user}/{issue_type}/{args.ticket.lower()}"

    # 3. Determine if we NEED to generate code
    existing_prs = gh_repo.get_pulls(state='open', head=f"{gh_repo.owner.login}:{branch_name}")
    need_generation = True
    initial_error = None
    pr_title = f"[{args.ticket}] Implementation"
    pr_body = "Automated implementation"

    if existing_prs.totalCount > 0:
        pr = existing_prs[0]
        last_hash = extract_hash_from_pr(pr.body)
        
        # A. Check Hash
        if last_hash == current_hash:
            print(f"⚡ JIRA Hash Match. Checking existing code integrity...")
            
            # Checkout existing code
            repo.git.fetch('origin')
            if branch_name in repo.heads:
                repo.git.checkout(branch_name)
                repo.git.pull('origin', branch_name)
            else:
                repo.git.checkout(branch_name)
            
            # B. VALIDATE (Run App)
            success, msg = build_and_test()
            
            if success:
                print("✅ Existing code works perfectly. Skipping AI Generation.")
                need_generation = False
                pr_title = pr.title
                pr_body = pr.body or "Automated implementation" # Handle None body
            else:
                print(f"❌ Existing code BROKEN despite Hash Match.\nmsg: {msg}\n🔁 Triggering AI Fix...")
                need_generation = True
                initial_error = msg # Feed this to AI
        else:
            old_hash_display = last_hash[:6] if last_hash else "None"
            print(f"📝 JIRA Description changed! (Old: {old_hash_display} vs New: {current_hash[:6]}). Regenerating...")
            need_generation = True

    # 4. AI Generation Loop (Only runs if needed)
    if need_generation:
        # If we are here, we either have a new request OR a bug to fix
        print("🧠 Starting Generation Loop...")
        
        # Ensure we are on the branch
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
        max_retries = 3
        build_success = False
        current_error = initial_error # Start with error if we found one earlier
        
        for i in range(max_retries):
            print(f"🔄 Generation Cycle {i+1}/{max_retries}")
            data = generate_code_with_gemini(args.ticket, desc, args.prompt, structure, current_error)
            if not data: break
            
            pr_title = f"[{args.ticket}] {data.get('pr_title', 'Update')}"
            pr_body = data.get('pr_body', 'Updates')

            for f in data['files']:
                path = os.path.normpath(f['path'])
                os.makedirs(os.path.dirname(path), exist_ok=True)
                with open(path, "w") as file: file.write(f['content'])
                repo.index.add([path])
                
            success, msg = build_and_test()
            if success:
                build_success = True
                break
            else:
                print(f"❌ Build Failed:\n{msg}")
                current_error = msg
        
        if not build_success:
            print("❌ Aborting: Could not generate working code.")
            return
            
        repo.index.commit(f"Gemini: {args.ticket} (Verified Build ✅)")
        print("🚀 Pushing code...")
        repo.remote().push(branch_name)

    # 5. Screenshot & PR (Always happens if build passed)
    screenshot_path = take_screenshot(branch_name)
    if screenshot_path:
        repo.index.add([screenshot_path])
        repo.index.commit("Auto-Validation: Screenshot Update 📸")
        repo.remote().push(branch_name)

    print("✨ Updating Pull Request...")
    hidden_meta = f""
    
    # Clean body to avoid duplicates, ensure string
    safe_body = pr_body if pr_body else "Automated implementation"
    clean_body = re.sub(r'', '', safe_body).strip()
    
    final_body = f"### Jira: {args.ticket}\n\n{clean_body}\n\n**Build Status:** ✅ Passed\n{hidden_meta}"
    if screenshot_path:
        final_body += f"\n### Verification\n![Screenshot](https://github.com/{args.repo}/blob/{branch_name}/{screenshot_path}?raw=true)"

    if existing_prs.totalCount > 0:
        existing_prs[0].edit(title=pr_title, body=final_body)
        print(f"✅ PR Updated: {existing_prs[0].html_url}")
    else:
        pr = gh_repo.create_pull(title=pr_title, body=final_body, head=branch_name, base="main")
        print(f"✅ PR Created: {pr.html_url}")

if __name__ == "__main__":
    main()
