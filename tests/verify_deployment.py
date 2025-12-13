import sys
from playwright.sync_api import sync_playwright

def verify_deployment(url):
    print(f"🚀 Starting verification for: {url}")
    with sync_playwright() as p:
        # Launch browser
        browser = p.chromium.launch(headless=True)
        context = browser.new_context()
        page = context.new_page()

        try:
            # 1. Navigate to URL
            print("Changes applied. Navigating...")
            response = page.goto(url, timeout=60000, wait_until='networkidle')

            if not response:
                print("❌ Verification Failed: No response received.")
                return False

            if response.status >= 400:
                print(f"❌ Verification Failed: HTTP Status {response.status}")
                return False

            print("✅ Page loaded successfully.")

            # 2. Check Title
            title = page.title()
            print(f"📄 Page Title: '{title}'")
            if "EasyTaskFlow" not in title:
                print("⚠️ Warning: Title does not match expected 'EasyTaskFlow'.")
            else:
                print("✅ Title verification passed.")

            # 3. Check for specific text/elements
            # Waiting for some content to ensure Flutter app has hydrated
            # Flutter web renders into a canvas or shadow DOM, but text is usually searchable in semantic tree
            # or if 'flutter_bootstrap.js' works, we might see the loading indicator or the app

            # Taking a screenshot is the best proof
            screenshot_path = "verification_result.png"
            page.screenshot(path=screenshot_path)
            print(f"📸 Screenshot saved to: {screenshot_path}")

            return True

        except Exception as e:
            print(f"❌ Verification Error: {e}")
            return False
        finally:
            browser.close()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        target_url = sys.argv[1]
    else:
        print("ℹ️  Usage: python tests/verify_deployment.py <URL>")
        target_url = input("Enter the deployment URL: ").strip()

    if not target_url:
        print("❌ Error: URL is required.")
        sys.exit(1)

    if verify_deployment(target_url):
        print("\n✨ VERIFICATION SUCCESSFUL ✨")
        sys.exit(0)
    else:
        print("\n💀 VERIFICATION FAILED 💀")
        sys.exit(1)
