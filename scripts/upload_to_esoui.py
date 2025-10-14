#!/usr/bin/env python3
"""
Automated ESOUI addon upload using Playwright.

Requires:
  pip install playwright python-dotenv
  playwright install chromium

Usage:
  python3 upload_to_esoui.py <zip_path> <version> <changelog>

Environment Variables (set in .env file):
  ESOUI_USERNAME - Your ESOUI username
  ESOUI_PASSWORD - Your ESOUI password
  ESOUI_ADDON_ID - Your addon ID (from URL after first upload)

Example:
  python3 scripts/upload_to_esoui.py \
    dist/CharacterMarkdown-v1.0.1.zip \
    1.0.1 \
    "Bug fixes and improvements"
"""

import os
import sys
from pathlib import Path
from playwright.sync_api import sync_playwright, TimeoutError
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

ESOUI_USERNAME = os.getenv("ESOUI_USERNAME")
ESOUI_PASSWORD = os.getenv("ESOUI_PASSWORD")
ESOUI_ADDON_ID = os.getenv("ESOUI_ADDON_ID")

# Configuration
HEADLESS = os.getenv("HEADLESS", "false").lower() == "true"
TIMEOUT = 30000  # 30 seconds


def validate_environment():
    """Validate required environment variables are set."""
    missing = []
    
    if not ESOUI_USERNAME:
        missing.append("ESOUI_USERNAME")
    if not ESOUI_PASSWORD:
        missing.append("ESOUI_PASSWORD")
    if not ESOUI_ADDON_ID:
        missing.append("ESOUI_ADDON_ID")
    
    if missing:
        print("✗ Missing required environment variables:")
        for var in missing:
            print(f"  - {var}")
        print("\nCreate a .env file with these variables or export them.")
        sys.exit(1)


def upload_addon(zip_path: str, version: str, changelog: str):
    """
    Upload addon to ESOUI using browser automation.
    
    Args:
        zip_path: Path to the ZIP file
        version: Version string (e.g., "1.0.1")
        changelog: Change log text
    """
    
    with sync_playwright() as p:
        # Launch browser
        print(f"Launching browser (headless={HEADLESS})...")
        browser = p.chromium.launch(headless=HEADLESS)
        context = browser.new_context()
        page = context.new_page()
        
        try:
            # Step 1: Login to ESOUI
            print("\n1. Logging in to ESOUI...")
            page.goto("https://www.esoui.com/login.php", timeout=TIMEOUT)
            
            # Fill login form
            page.fill('input[name="vb_login_username"]', ESOUI_USERNAME)
            page.fill('input[name="vb_login_password"]', ESOUI_PASSWORD)
            
            # Submit login
            page.click('input[type="submit"][value="Log in"]')
            page.wait_for_load_state("networkidle", timeout=TIMEOUT)
            
            # Verify login successful
            if "login" in page.url.lower() or "error" in page.content().lower():
                raise Exception("Login failed - check your credentials")
            
            print("   ✓ Logged in successfully")
            
            # Step 2: Navigate to addon update page
            print(f"\n2. Navigating to addon #{ESOUI_ADDON_ID}...")
            addon_url = f"https://www.esoui.com/downloads/info{ESOUI_ADDON_ID}.html"
            page.goto(addon_url, timeout=TIMEOUT)
            
            # Click "Update File" or "Manage" button
            try:
                page.click('text="Update File"', timeout=5000)
            except TimeoutError:
                try:
                    page.click('text="Manage"', timeout=5000)
                    page.click('text="Update File"', timeout=5000)
                except TimeoutError:
                    raise Exception("Could not find 'Update File' button - check addon ID")
            
            page.wait_for_load_state("networkidle", timeout=TIMEOUT)
            print("   ✓ On update page")
            
            # Step 3: Upload new version
            print(f"\n3. Uploading {Path(zip_path).name}...")
            
            # Upload file
            file_input = page.locator('input[type="file"]')
            file_input.set_input_files(zip_path)
            print("   ✓ File selected")
            
            # Fill version field
            version_input = page.locator('input[name="version"]')
            version_input.fill(version)
            print(f"   ✓ Version set to {version}")
            
            # Fill changelog
            changelog_input = page.locator('textarea[name="changelog"]')
            changelog_input.fill(changelog)
            print("   ✓ Changelog added")
            
            # Optional: Check API version compatibility boxes if present
            # This varies by ESOUI's current form structure
            
            # Step 4: Submit upload
            print("\n4. Submitting upload...")
            submit_button = page.locator('input[type="submit"][value="Upload"]')
            submit_button.click()
            
            # Wait for response
            page.wait_for_load_state("networkidle", timeout=TIMEOUT)
            
            # Step 5: Verify success
            print("\n5. Verifying upload...")
            page_content = page.content().lower()
            
            if "success" in page_content or "uploaded" in page_content:
                print(f"\n✓ Upload successful! Version {version} uploaded.")
                print(f"  View at: {addon_url}")
                return True
            elif "error" in page_content or "fail" in page_content:
                print("\n✗ Upload may have failed.")
                print("  Check the ESOUI page manually:")
                print(f"  {addon_url}")
                return False
            else:
                print("\n⚠ Upload status unclear.")
                print("  Please verify manually at:")
                print(f"  {addon_url}")
                return None
                
        except TimeoutError as e:
            print(f"\n✗ Timeout error: {e}")
            print("  The page took too long to load.")
            print("  Try again or check your internet connection.")
            return False
            
        except Exception as e:
            print(f"\n✗ Error during upload: {e}")
            
            # Take screenshot for debugging
            if not HEADLESS:
                screenshot_path = "error_screenshot.png"
                page.screenshot(path=screenshot_path)
                print(f"  Screenshot saved to: {screenshot_path}")
            
            return False
            
        finally:
            # Cleanup
            browser.close()


def main():
    """Main entry point."""
    
    # Check arguments
    if len(sys.argv) < 4:
        print("Usage: upload_to_esoui.py <zip_path> <version> <changelog>")
        print("\nExample:")
        print("  python3 upload_to_esoui.py \\")
        print("    dist/CharacterMarkdown-v1.0.1.zip \\")
        print("    1.0.1 \\")
        print('    "Bug fixes and improvements"')
        sys.exit(1)
    
    zip_path = sys.argv[1]
    version = sys.argv[2]
    changelog = sys.argv[3]
    
    # Validate inputs
    if not Path(zip_path).exists():
        print(f"✗ ZIP file not found: {zip_path}")
        sys.exit(1)
    
    if not version:
        print("✗ Version cannot be empty")
        sys.exit(1)
    
    # Validate environment
    validate_environment()
    
    # Display upload information
    print("=" * 60)
    print("ESOUI Addon Upload")
    print("=" * 60)
    print(f"File:      {zip_path}")
    print(f"Version:   {version}")
    print(f"Changelog: {changelog[:50]}..." if len(changelog) > 50 else f"Changelog: {changelog}")
    print(f"Addon ID:  {ESOUI_ADDON_ID}")
    print("=" * 60)
    print()
    
    # Perform upload
    success = upload_addon(zip_path, version, changelog)
    
    # Exit with appropriate code
    if success is True:
        sys.exit(0)
    elif success is False:
        sys.exit(1)
    else:
        sys.exit(2)  # Unclear status


if __name__ == "__main__":
    main()
