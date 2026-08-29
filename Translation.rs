use std::io::{self, BufRead, Write};
use std::process::{Command, Stdio};
use serde_json::json;

fn main() -> io::Result<()> {
    let stdin = io::stdin();
    let handle = stdin.lock();

    // 1. Core loop: Keep the process open and listen for Chorus Daemon commands
    for line in handle.lines() {
        let chorus_prompt = match line {
            Ok(text) => text.trim().to_string(),
            Err(_) => break, // Exit loop if Chorus closes the pipe
        };

        if chorus_prompt.is_empty() {
            continue;
        }

        // 2. Invoke your Enterprise Gemini CLI 
        // Adjust "gemini.exe" and flags to match your corporate CLI requirements
        let output = Command::new("gemini.exe")
            .arg("--interactive") 
            .arg(&chorus_prompt)
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .output();

        match output {
            Ok(res) => {
                let mut raw_gemini_text = String::from_utf8_lossy(&res.stdout).into_owned();
                let raw_error_text = String::from_utf8_lossy(&res.stderr).into_owned();

                // 3. ENTERPRISE VALIDATION INTERCEPTOR
                // If Gemini prompts for permission, break out to the physical console screen
                if raw_gemini_text.contains("(Y/n)") || raw_error_text.contains("Confirm") {
                    // Open a direct channel to the Windows Host Console (\.\CON)
                    if let Ok(mut con) = std::fs::OpenOptions::new().write(true).open("\\\\.\\CON") {
                        let _ = writeln!(con, "\n⚠️ [ENTERPRISE SECURITY]: Gemini requires validation!\n{}", raw_gemini_text);
                    }
                    
                    // Freeze execution and wait for a manual confirmation input key from the user
                    let mut user_validation = String::new();
                    if let Ok(mut con_in) = std::fs::OpenOptions::new().read(true).open("\\\\.\\CON") {
                        let _ = io::BufReader::new(con_in).read_line(&mut user_validation);
                    }

                    // If the user aborts, inject a cancellation notice into the buffer
                    if !user_validation.trim().eq_ignore_ascii_case("y") {
                        raw_gemini_text = String::from("Execution aborted by enterprise user validation gate.");
                    }
                }

                // 4. CHORUS STREAM-JSON ENVELOPE FORMATTING
                // Build the precise payload object Chorus needs to process state
                let chorus_envelope = json!({
                    "type": "assistant",
                    "message": {
                        "role": "assistant",
                        "content": [
                            {
                                "type": "text",
                                "text": raw_gemini_text.trim()
                            }
                        ]
                    }
                });

                // Emit cleanly to stdout as a single flat string + newline
                println!("{}", chorus_envelope.to_string());
                io::stdout().flush()?;
            }
            Err(e) => {
                // Return an explicit error JSON if the binary execution completely fails
                let error_envelope = json!({
                    "type": "error",
                    "message": format!("Failed to invoke enterprise gemini.exe: {}", e)
                });
                println!("{}", error_envelope.to_string());
                io::stdout().flush()?;
            }
        }
    }

    Ok(())
}
