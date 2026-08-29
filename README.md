.chorus/daemon.json to point to powershell script

{
  "agents": [
    {
      "name": "enterprise-gemini-agent",
      "backend": "claude",
      "env": {
        "PATH": "C:\\Windows\\System32\\WindowsPowerShell\\v1.0;C:\\Program Files\\Git\\bin"
      }
    }
  ]
}
