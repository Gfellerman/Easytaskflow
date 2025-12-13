import sys
from playwright.sync_api import sync_playwright

def verify_deployment(url):
    print(f"🚀 Starting verification for: {url}")
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        try:
            print("Navigating...")
            response = page.goto(url, timeout=60000, wait_until='networkidle')
            if not response or response.status >= 400:
                print("❌ Verification Failed: HTTP Error or No Response")
                return False
            
            print(f"✅ Page loaded. Title: {page.title()}")
            page.screenshot(path="verification_result.png")
            print("📸 Screenshot saved.")
            return True
        except Exception as e:
            print(f"❌ Error: {e}")
            return False
        finally:
            browser.close()

if __name__ == "__main__":
    url = sys.argv[1] if len(sys.argv) > 1 else input("Enter URL: ").strip()
    if verify_deployment(url):
        sys.exit(0)
    else:
        sys.exit(1)
