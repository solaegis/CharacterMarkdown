#!/bin/bash
# Verify that no deprecated format references remain in the source code

echo "Checking for 'discord' references..."
if grep -r -i "discord" src/ | grep -v "test" | grep -v "DISABLED"; then
    echo "⚠️ Found 'discord' references (ignoring tests/DISABLED):"
    grep -r -i "discord" src/ | grep -v "test" | grep -v "DISABLED"
else
    echo "✅ No 'discord' references found in src/ (excluding tests/DISABLED)"
fi

echo "Checking for 'vscode' references..."
if grep -r -i "vscode" src/ | grep -v "test" | grep -v "DISABLED"; then
     echo "⚠️ Found 'vscode' references:"
     grep -r -i "vscode" src/ | grep -v "test" | grep -v "DISABLED"
else
    echo "✅ No 'vscode' references found in src/"
fi
