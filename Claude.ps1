# 1. Capture the prompt passed by the Chorus Daemon
$ChorusInput = $args -join " "

# 2. Open your Enterprise Gemini CLI in a REAL, separate window 
# This ensures it retains its native interactive prompt environment and corporate auth
$ProcessStartInfo = New-Object System.Diagnostics.ProcessStartInfo
$ProcessStartInfo.FileName = "cmd.exe"
# Start cmd, run Gemini CLI interactively, and keep the window open
$ProcessStartInfo.Arguments = "/c gemini.exe --interactive" 
$ProcessStartInfo.WindowStyle = "Normal" # Change to "Minimized" if you want it out of the way

$GeminiProcess = [System.Diagnostics.Process]::Start($ProcessStartInfo)

# Give the terminal window a brief moment to initialize
Start-Sleep -Milliseconds 800

# 3. Use Windows Script Host to inject Chorus's prompt into the active Gemini window
$WshShell = New-Object -ComObject WScript.Shell
$WshShell.AppActivate($GeminiProcess.Id)

# Programmatically "type" the Chorus input prompt and hit Enter
# We replace special characters that SendKeys treats as modifiers
$SanitizedInput = $ChorusInput.Replace("+", "{+}").Replace("^", "{^}").Replace("%", "{%}").Replace("~", "{~}")
$WshShell.SendKeys($SanitizedInput)
$WshShell.SendKeys("{ENTER}")

# 4. HANDOFF TO USER FOR VALIDATION
# The window is now active on your desktop. Gemini will process the command.
# If Gemini prompts you with an enterprise "Execute this command? (Y/n)" validation rule,
# you can physically click on that command window and type Y or N yourself.

# The script blocks and waits right here until you finish your session and close the window
$GeminiProcess.WaitForExit()

# 5. Return JSON to Chorus to gracefully close the daemon task turn
$JsonReturn = @{
    type = "assistant"
    message = @{
        role = "assistant"
        content = @(
            @{ type = "text"; text = "Task completed inside Gemini environment." }
        )
    }
} | ConvertTo-Json -Compress

Write-Output $JsonReturn
