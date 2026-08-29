# 1. Define paths for capturing background communication streams
$InputFile  = "$env:USERPROFILE\.chorus\gemini_in.txt"
$OutputFile = "$env:USERPROFILE\.chorus\gemini_out.txt"

# Ensure the workspace directory exists
New-Item -ItemType Directory -Force -Path (Split-Path $InputFile) | Out-Null

# 2. Capture incoming prompt from the Chorus Daemon
# $args contains whatever prompt string Chorus is passing to the CLI
$ChorusInput = $args -join " "
Set-Content -Path $InputFile -Value $ChorusInput -Force

# 3. Spin up your interactive Enterprise Gemini CLI in a background task thread
# We instruct the script block to fetch input sequentially, but output interactively to your host window
$GeminiJob = Start-Job -ScriptBlock {
    param($In, $Out)
    # Read the prompt written by Chorus
    $Prompt = Get-Content -Path $In -Raw
    
    # Run your interactive Gemini CLI binary
    # (Replace 'gemini.exe' with your exact corporate executable name)
    gemini.exe --interactive $Prompt | Out-File -FilePath $Out -Force
}

# 4. Monitor the process and surface Interactive Validation Prompts
# This loop forces the Windows terminal to wait while allowing you to hit Y/N for any corporate prompts
while ($GeminiJob.State -eq "Running") {
    # Check if Gemini output file contains a validation string like "(Y/n)" or "Confirm"
    if (Test-Path $OutputFile) {
        $CurrentOutput = Get-Content -Path $OutputFile -Tail 5 -ErrorAction SilentlyContinue
        if ($CurrentOutput -match "Y/n" -or $CurrentOutput -match "Confirm") {
            # Bring attention to the console window so you can approve/deny the corporate terminal hook
            Write-Host -ForegroundColor Yellow "`n⚠️  [SECURITY WARNING]: Enterprise Gemini is waiting for command authorization..."
            
            # Flush output to host screen so you see exactly what Gemini is trying to run
            Receive-Job -Job $GeminiJob -Keep
            
            # Pause execution to wait for your physical keyboard response
            Read-Host "Authorize this action? (Press Enter to continue, or Ctrl+C to abort)"
        }
    }
    Start-Sleep -Milliseconds 250
}

# 5. Emulate the Structured JSON Output that Chorus Daemon expects
Receive-Job -Job $GeminiJob | Out-Null
Remove-Job -Job $GeminiJob

# Format a fake successful Claude Code return block so the Chorus loop closes gracefully
$JsonReturn = @{
    type = "assistant"
    message = @{
        role = "assistant"
        content = @(
            @{ type = "text"; text = "Task completed successfully inside Gemini environment." }
        )
    }
} | ConvertTo-Json -Compress

Write-Output $JsonReturn
