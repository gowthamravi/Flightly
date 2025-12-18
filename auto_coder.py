
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
AI_MODEL_DEPLOYMENT = "claude-sonnet-4@20250514"  # Use the correct deployment name

# Github Auth
g = Github(auth=Auth.Token(GITHUB_TOKEN))

def get_file_structure(path):
    """
    Reads the file structure so the AI knows where to put files.
    Returns RELATIVE paths from the repo root.
    """
    file_list = []
    for root, dirs, files in os.walk(path):
        if ".git" in root or "Pods" in root or "build" in root or ".xcodeproj" in root:
            continue
        for file in files:
            if file.endswith(".swift"):
                # Use relpath to give AI cleaner context
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, path)
                file_list.append(rel_path)
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

def sanitize_path(path):
    """
    Ensures the path is relative to the current working directory.
    Strips absolute prefixes or 'Users/...' garbage if present.
    """
    # 1. Normalize separators
    path = os.path.normpath(path)
    cwd = os.getcwd()
    
    # 2. If it's absolute and starts with CWD, make it relative
    if os.path.isabs(path):
        if path.startswith(cwd):
            return os.path.relpath(path, cwd)
        # If it's absolute but NOT in CWD, that's dangerous/wrong for this tool
        # Try to guess: if it contains the repo name 'Flightly', strip up to it
        if "Flightly" in path:
            # simple heuristic: take everything after 'Flightly/'
            parts = path.split("Flightly/")
            if len(parts) > 1:
                return parts[-1]
    
    # 3. If it starts with "Users/" but is relative (which caused the bug), strip it
    # Heuristic: check if path components start with Users -> User -> Documents -> Flightly
    parts = path.split(os.sep)
    if parts[0] == "Users":
        # Look for the project folder name in the parts
        project_name = os.path.basename(cwd)
        if project_name in parts:
            idx = parts.index(project_name)
            if idx + 1 < len(parts):
                return os.path.join(*parts[idx+1:])
    
    return path

def clean_json_response(content):
    """
    Cleans the AI response to ensure it's valid JSON.
    Removes markdown code blocks (```json ... ```).
    """
    if "```" in content:
        # Extract content between the first and last validation of ```
        # This handles ```json ... ``` or just ``` ... ```
        pattern = r"```(?:json)?\s*(.*?)```"
        match = re.search(pattern, content, re.DOTALL)
        if match:
            return match.group(1).strip()
    return content.strip()

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
                "path": "FlightSearch/Views/NewFile.swift",
                "content": "import UIKit..."
            }}
        ],
        "pr_title": "A concise title for the Pull Request",
        "pr_body": "A summary of changes for the PR description"
    }}
    
    IMPORTANT RULES:
    1. The 'path' in the JSON must be RELATIVE to the project root (e.g., "FlightSearch/Views/MyFile.swift").
    2. DO NOT include absolute paths (like /Users/...).
    3. DO NOT create new top-level folders unless absolutely necessary. Use existing structure from PROJECT STRUCTURE.
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
        
        raw_content = response.choices[0].message.content
        cleaned_content = clean_json_response(raw_content)
        
        try:
             return json.loads(cleaned_content)
        except json.JSONDecodeError as e:
            print(f"\n❌ JSON Parsing Failed!")
            print(f"--- RAW RESPONSE START ---")
            print(raw_content)
            print(f"--- RAW RESPONSE END ---")
            print(f"Error: {e}")
            return None
            
    except openai.APIError as e:
        stop_event.set()
        loader_thread.join()
        print(f"❌ OpenAI API Error: {e}")
        return None
    except Exception as e:
        stop_event.set()
        loader_thread.join()
        print(f"❌ Unexpected Error: {e}")
        return None

def run_xcodebuild(project_path="FlightSearch.xcodeproj", scheme="FlightSearch", max_output_lines=100):
    """
    Runs xcodebuild to compile the project and check for errors.
    Returns (success: bool, error_output: str)
    """
    print("\n🔨 Building project with xcodebuild...")
    
    cmd = [
        "xcodebuild",
        "-project", project_path,
        "-scheme", scheme,
        "-configuration", "Debug",
        "build",
        "CODE_SIGNING_ALLOWED=NO",
        "CODE_SIGNING_REQUIRED=NO",
        "CODE_SIGN_IDENTITY="
    ]
    
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            cwd=os.getcwd(),
            timeout=300  # 5 minute timeout
        )
        
        if result.returncode == 0:
            print("✅ Build succeeded!")
            return True, ""
        else:
            # Extract error messages from output
            error_lines = []
            for line in result.stderr.split('\n') + result.stdout.split('\n'):
                if 'error:' in line.lower() or 'warning:' in line.lower():
                    error_lines.append(line)
            
            # Limit output to avoid overwhelming the AI
            error_output = '\n'.join(error_lines[-max_output_lines:])
            
            print(f"❌ Build failed with {len(error_lines)} errors/warnings")
            return False, error_output
            
    except subprocess.TimeoutExpired:
        print("❌ Build timed out after 5 minutes")
        return False, "Build process timed out"
    except Exception as e:
        print(f"❌ Error running xcodebuild: {e}")
        return False, str(e)

def fix_build_errors_with_ai(error_output, structure, modified_files):
    """
    Uses AI to analyze build errors and suggest fixes.
    Returns JSON with file modifications or None if AI can't help.
    """
    print("\n🤖 Asking AI to fix build errors...")
    
    system_prompt = "You are a Senior iOS Engineer specializing in fixing Swift compilation errors. Return ONLY valid JSON."
    
    # Get content of modified files for context
    file_contents = {}
    for file_path in modified_files:
        try:
            if os.path.exists(file_path):
                with open(file_path, 'r') as f:
                    file_contents[file_path] = f.read()
        except Exception as e:
            print(f"⚠️ Could not read {file_path}: {e}")
    
    files_context = "\n\n".join([
        f"FILE: {path}\n```swift\n{content}\n```" 
        for path, content in file_contents.items()
    ])
    
    user_message = f"""
    TASK:
    The following Swift files have compilation errors. Analyze the errors and provide fixes.
    
    BUILD ERRORS:
    {error_output}
    
    MODIFIED FILES:
    {files_context}
    
    PROJECT STRUCTURE:
    {structure}
    
    OUTPUT FORMAT:
    Return a JSON object with this exact schema:
    {{
        "files": [
            {{
                "path": "FlightSearch/Views/SomeFile.swift",
                "content": "<complete fixed file content>"
            }}
        ],
        "fix_summary": "Brief explanation of what was fixed"
    }}
    
    IMPORTANT:
    1. Only include files that need to be modified to fix the errors
    2. Provide the COMPLETE file content, not just the changed lines
    3. Use RELATIVE paths from project root
    4. Focus on fixing compilation errors, not warnings
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
        
        raw_content = response.choices[0].message.content
        cleaned_content = clean_json_response(raw_content)
        
        try:
            fix_data = json.loads(cleaned_content)
            if 'fix_summary' in fix_data:
                print(f"💡 AI suggests: {fix_data['fix_summary']}")
            return fix_data
        except json.JSONDecodeError as e:
            print(f"❌ Failed to parse AI fix response: {e}")
            return None
            
    except Exception as e:
        stop_event.set()
        loader_thread.join()
        print(f"❌ Error getting AI fix: {e}")
        return None

def apply_fixes(fix_data, repo):
    """
    Applies the AI-suggested fixes to files.
    Returns list of modified file paths.
    """
    modified_files = []
    
    if not fix_data or 'files' not in fix_data:
        return modified_files
    
    for file_obj in fix_data['files']:
        file_path = sanitize_path(file_obj['path'])
        
        print(f"🔧 Applying fix to {file_path}...")
        
        try:
            os.makedirs(os.path.dirname(file_path), exist_ok=True)
            
            with open(file_path, 'w') as f:
                f.write(file_obj['content'])
            
            repo.index.add([file_path])
            modified_files.append(file_path)
            
        except Exception as e:
            print(f"⚠️ Failed to apply fix to {file_path}: {e}")
    
    return modified_files

def build_and_fix_loop(repo, structure, initial_files, max_retries=3):
    """
    Main build verification loop with AI-powered auto-fix.
    Returns True if build succeeds, False otherwise.
    """
    modified_files = initial_files.copy()
    
    for attempt in range(max_retries + 1):
        if attempt == 0:
            print("\n" + "="*60)
            print("🔍 INITIAL BUILD VERIFICATION")
            print("="*60)
        else:
            print("\n" + "="*60)
            print(f"🔄 BUILD FIX ATTEMPT {attempt}/{max_retries}")
            print("="*60)
        
        success, error_output = run_xcodebuild()
        
        if success:
            print("\n✅ Build verification passed!")
            return True
        
        if attempt < max_retries:
            print(f"\n⚠️ Build failed. Attempting AI-powered fix ({attempt + 1}/{max_retries})...")
            
            fix_data = fix_build_errors_with_ai(error_output, structure, modified_files)
            
            if fix_data:
                newly_modified = apply_fixes(fix_data, repo)
                modified_files.extend(newly_modified)
                
                # Update Xcode project if Swift files were modified
                for file_path in newly_modified:
                    if file_path.endswith(".swift"):
                        add_file_to_xcode(file_path)
                
                # Stage the project file changes
                try:
                    repo.index.add(["FlightSearch.xcodeproj/project.pbxproj"])
                except:
                    pass
                
                # Amend the commit with fixes
                try:
                    repo.index.commit(f"AI: Auto-fix build errors (attempt {attempt + 1})", amend=True)
                except:
                    repo.index.commit(f"AI: Auto-fix build errors (attempt {attempt + 1})")
            else:
                print("❌ AI could not suggest fixes. Manual intervention required.")
                break
        else:
            print(f"\n❌ Build still failing after {max_retries} fix attempts.")
            print("⚠️ Manual review required. Pushing code anyway for human review.")
            return False
    
    return False

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
    figma_key = None
    
    # Check prompt for Figma
    if args.prompt and "figma.com" in args.prompt:
        figma_key = extract_figma_key(args.prompt)
        print("🎨 Figma URL found in command argument.")
    
    # If not in prompt, check Jira description
    if not figma_key and ticket_instruction and "figma.com" in ticket_instruction:
        figma_key = extract_figma_key(ticket_instruction)
        print("🎨 Figma URL found in Jira Ticket.")

    if figma_key:
        print("🔍 Analyzing Figma Design...")
        figma_info = get_figma_metadata(figma_key, FIGMA_TOKEN)
        extra_context += f"\n\n[FIGMA METADATA]\n{figma_info}\n"
        print(f"   - {figma_info}")
    elif args.prompt and "figma.com" in args.prompt:
         print("⚠️ Could not extract Figma key from URL in prompt.")
    
    full_prompt = args.prompt + extra_context

    # 2. Analyze Project
    print("📂 Analyzing Project Structure...")
    # This now returns RELATIVE paths
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
        
        # Sanitize path to prevent 'Users/...' absolute nesting bug
        file_path = sanitize_path(raw_path)
        
        if file_path != raw_path:
            print(f"⚠️  Fixed path: '{raw_path}' -> '{file_path}'")
        
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

    # 6. Build Verification and Auto-Fix
    print("\n" + "="*60)
    print("🔨 BUILD VERIFICATION PHASE")
    print("="*60)
    
    # Get list of files we just created/modified
    initial_files = [sanitize_path(f['path']) for f in generated_data['files']]
    
    # Run build verification with auto-fix loop
    build_success = build_and_fix_loop(repo, structure, initial_files, max_retries=3)
    
    if not build_success:
        print("\n⚠️ WARNING: Code has build issues but will be pushed for review.")
    
    # 7. Commit & Push
    repo.index.commit(f"AI: Implemented {args.ticket}")
    print("🚀 Pushing to origin...")
    try:
        repo.remote().push(branch_name, force=True)  # Force push since we may have amended commits
    except Exception as e:
        print(f"⚠️ Push failed: {e}")
        return

    # 8. Create or Update PR
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
