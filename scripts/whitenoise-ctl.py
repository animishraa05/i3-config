#!/usr/bin/env python3
import socket
import json
import sys
import os

SOCKET = "/tmp/mpv-whitenoise"


def send_command(cmd):
    if not os.path.exists(SOCKET):
        return False
    try:
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.settimeout(2)
        s.connect(SOCKET)
        s.send(json.dumps({"command": cmd}).encode() + b"\n")
        s.recv(4096)
        s.close()
        return True
    except Exception:
        return False


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: whitenoise-ctl.py [toggle|up|down]")
        sys.exit(1)

    action = sys.argv[1]

    if action == "toggle":
        send_command(["cycle", "pause"])
    elif action == "up":
        send_command(["add", "volume", "5"])
    elif action == "down":
        send_command(["add", "volume", "-5"])
    else:
        print(f"Unknown action: {action}")
        sys.exit(1)
