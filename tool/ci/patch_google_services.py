"""CI only: make google-services.json build for com.sbfrusho.yourshop.

Until the new package is registered in Firebase (docs/ROADMAP.md, Sprint 11),
the file only has the legacy com.example.shopping_app client, and the Google
Services Gradle plugin refuses to build. This copies that client under the
new package name in the CI checkout. It never runs on your machine, and it
does nothing once the real client is in the file.
"""
import json
import sys

PATH = "android/app/google-services.json"
OLD, NEW = "com.example.shopping_app", "com.sbfrusho.yourshop"

with open(PATH) as f:
    data = json.load(f)

def package(client):
    return client["client_info"]["android_client_info"]["package_name"]

clients = data["client"]
if any(package(c) == NEW for c in clients):
    print(f"{NEW} already registered; nothing to do")
    sys.exit(0)

source = next(c for c in clients if package(c) == OLD)
copy = json.loads(json.dumps(source))
copy["client_info"]["android_client_info"]["package_name"] = NEW
clients.append(copy)
with open(PATH, "w") as f:
    json.dump(data, f, indent=2)
print(f"added CI-only client for {NEW}")
