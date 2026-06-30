#!/usr/bin/env bash
set -e

pip3 install --upgrade hopx-ai --break-system-packages 2>/dev/null || pip3 install --upgrade hopx-ai >/dev/null 2>&1

python3 - << 'EOF'
import getpass, sys, os
try:
    from hopx_ai import Sandbox
except ImportError:
    print("[-] hopx-ai library is not installed."); sys.exit(1)

key = getpass.getpass("[+] Enter HopX API Key (input hidden): ").strip()
if not key: print("[-] Key cannot be empty!"); sys.exit(1)

os.system("clear")

print("[*] Checking HopX account...")
try:
    sbs = Sandbox.list(api_key=key)
    if sbs:
        print(f"\n[!] You ALREADY HAVE an active Sandbox running!")
        print(f"    - ID: {sbs[0].sandbox_id}")
        print(f"    - Status: {sbs[0].status}")
    else:
        print("\n[*] No active sandbox found. Creating a new one...")
        sb = None
        for t in [2147483647, 604800, 86400]:
            try: sb = Sandbox.create(template="code-interpreter", api_key=key, timeout=t); break
            except: continue
        if not sb: sb = Sandbox.create(template="code-interpreter", api_key=key)
        
        print(f"[✓] New Sandbox VM created successfully!")
        print(f"    - ID: {sb.sandbox_id}")

    print("\n====================================================")
    print("[🎉] SUCCESS: Your VM is ready and running!")
    print("[👉] Please return to the HopX Web Dashboard to use")
    print("     the full-featured, interactive Web Terminal.")
    print("====================================================")

except Exception as e:
    print(f"[-] HopX API Error: {e}"); sys.exit(1)
EOF
