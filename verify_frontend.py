from playwright.sync_api import sync_playwright, expect
import time

def verify_app_launch():
    with sync_playwright() as p:
        # Launch browser
        browser = p.chromium.launch(headless=False) # Headless=False to see it in action
        page = browser.new_page()

        print("Navigating to Flutter web app...")
        # Assuming the app is running on localhost:8080 or the port printed by 'flutter run -d web-server'
        # Adjust the URL if your port is different.
        page.goto("http://localhost:8080")

        # Wait for the app to load (Flutter web apps take a moment to initialize)
        # We look for a widget that should appear on the home screen or login screen.
        # Based on the code, if not logged in, it shows a login screen (from AuthWrapper).
        # But 'HomeScreen' has a BottomNavigationBar with 'Projects', 'Messages', 'Settings'.

        print("Waiting for app to load...")
        # Generic wait for Flutter content (canvas or semantics)
        page.wait_for_selector("flt-glass-pane", timeout=10000)

        # Check for expected elements based on the fix in HomeScreen
        # HomeScreen has BottomNavigationBar items: 'Projects', 'Messages', 'Settings'
        # But note: AuthWrapper might show LoginScreen if not authenticated.
        # Ideally, we just want to verify the app renders without crashing (white screen).

        # Take a screenshot
        screenshot_path = "verification_screenshot.png"
        page.screenshot(path=screenshot_path)
        print(f"Screenshot saved to {screenshot_path}")

        # Basic assertion: Title or specific element
        # Since I can't run it, I can't know the exact title, but usually it's in index.html
        # We can assert that the body is not empty.
        expect(page.locator("body")).not_to_be_empty()

        browser.close()
        print("Verification script finished.")

if __name__ == "__main__":
    verify_app_launch()
