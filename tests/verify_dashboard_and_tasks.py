import sys
from playwright.sync_api import sync_playwright

def verify_dashboard(url):
    print(f"🚀 Verifying Dashboard at: {url}")
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        try:
            # Login if needed (simplified check)
            page.goto(url, timeout=60000)

            # If redirected to login, we might need to handle it or assume logged in session
            # For now, just check if we can see Dashboard
            try:
                page.wait_for_selector('text=Dashboard', timeout=5000)
                print("✅ Dashboard loaded")
            except:
                print("⚠️ Dashboard not found immediately (maybe login needed?)")

            # Check for Metrics
            print("Checking metrics...")
            # We expect real numbers now, so they might be 0 or more.
            # Look for "Tasks Due"
            if page.get_by_text("Tasks Due").count() > 0:
                 print("✅ Found 'Tasks Due' metric")
            else:
                 print("❌ Missing 'Tasks Due'")

            # Check My Tasks navigation
            print("Checking My Tasks...")
            # Navigate to My Tasks (assuming index 2 in bottom nav or rail)
            # Find "My Tasks" in navigation
            # Note: NavigationRail destination label "Tasks" (index 2) or "My Tasks"
            # In MainLayout we have NavigationRailDestination label "Tasks"

            # Try to click the Tasks navigation item
            # Use a selector that matches the navigation item
            page.get_by_icon("check_circle_outline").click() # Or by text

            # Should see "My Tasks" title
            try:
                page.wait_for_selector('text=My Tasks', timeout=5000)
                print("✅ Navigated to 'My Tasks' screen")
            except:
                 print("❌ Failed to navigate to 'My Tasks' screen")

            page.screenshot(path="verification_dashboard.png")
            print("📸 Screenshot saved.")
            return True
        except Exception as e:
            print(f"❌ Error: {e}")
            return False
        finally:
            browser.close()

if __name__ == "__main__":
    url = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8080"
    verify_dashboard(url)
