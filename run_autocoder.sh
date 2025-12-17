#!/bin/bash
# Wrapper script to run auto_coder.py with the correct environment

# 1. Ensure we are using the python3 from the PATH (or specify absolute path if needed)
PYTHON_CMD="python3"

if ! command -v $PYTHON_CMD &> /dev/null; then
    echo "python3 not found! Please install Python 3."
    exit 1
fi

echo "🐍 Using Python: $($PYTHON_CMD --version) at $(which $PYTHON_CMD)"

# 2. Install/Update dependencies to ensure they exist for THIS python
echo "📦 Checking dependencies..."
$PYTHON_CMD -m pip install --user -q openai jira PyGithub GitPython python-dotenv requests pbxproj

if [ $? -ne 0 ]; then
    echo "⚠️  Warning: Failed to install dependencies via pip. Attempting to run anyway..."
fi

# 3. Run the script
echo "🚀 Running auto_coder.py..."
$PYTHON_CMD auto_coder.py "$@"
