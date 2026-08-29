You are very close, but you can actually remove an entire link from that chain to make it simpler and cleaner.
Because [CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI) is already a multi-agent protocol translator, you do not need UniClaudeProxy. CLIProxyAPI natively exposes an Anthropic-compatible API endpoint directly to [Claude Code](https://github.com/router-for-me/CLIProxyAPI/issues/2098). [1, 2] 
Your perfect, functioning enterprise chain looks like this:

[ Chorus Daemon ]
       │ 
       ▼ (Thinks it's running native autonomous Claude Code)
[ Claude Code CLI ]
       │ 
       ▼ (Fires Anthropic REST API traffic over http://localhost:8317)
[ CLIProxyAPI ] 
       │ 
       ▼ (Spawns background task to your corporate binary: gemini run -p "...")
[ Gemini CLI ]
       │ 
       ▼ (Your managed proxy intercepts this and bypasses the firewall)
[ Corporate Firewall / Enterprise Endpoint ]

## 🧠 Why this exact chain works for your constraints

   1. Chorus ➔ Claude Code: Chorus spawns Claude Code as a native local OS process. Claude Code acts as the "hands and feet"—it can read your Windows directory, execute build tests, and write files flawlessly. [2] 
   2. Claude Code ➔ CLIProxyAPI: You set $env:ANTHROPIC_BASE_URL="http://localhost:8317". When Claude Code tries to think, its web traffic is redirected into CLIProxyAPI. CLIProxyAPI acts as the rosetta stone: it absorbs Claude's multi-turn history and tool payloads, and strips out the Anthropic schema. [1, 2, 3] 
   3. CLIProxyAPI ➔ Gemini CLI: Instead of calling a web URL, CLIProxyAPI wraps the prompt text and launches your local gemini.exe binary as a background subprocess. [1] 
   4. Gemini CLI ➔ Corporate Firewall: Because the actual authorized gemini.exe application is the one making the external connection, your laptop's corporate proxy interceptor attaches your network tokens and routes the traffic through your enterprise gateway safely.

## ⚙️ How to tie them together right now
When setting your console session environment variables before launching chorus daemon, skip the extra proxies and map them directly into CLIProxyAPI:

# Point Claude Code straight to CLIProxyAPI's native Anthropic port
$env:ANTHROPIC_BASE_URL="http://localhost:8317/v1"
$env:ANTHROPIC_API_KEY="cliproxy-dummy-token"
# Fire up Chorus
chorus daemon --agent claude

Have you already downloaded the Windows executable (cli-proxy-api.exe), or do you need the exact config.yaml layout to register your local gemini.exe as the primary provider inside its management center? [4, 5] 

[1] [https://hk.x-cmd.com](https://hk.x-cmd.com/install/cliproxyapi/)
[2] [https://vervecode.dev](https://vervecode.dev/ai/cli-proxy-api/)
[3] [https://www.youtube.com](https://www.youtube.com/watch?v=sYtNcR9zXvk)
[4] [https://developer.cloud.tencent.com](https://developer.cloud.tencent.com/article/2636407?policyId=1003)
[5] [https://github.com](https://github.com/router-for-me/CLIProxyAPI/issues/852)
