# Model Switching Guide

## Overview

The CCM Dashboard now includes full model switching functionality that allows you to change your active AI provider through a visual interface. This guide explains how the switching mechanism works, how to use it, and how to troubleshoot common issues.

## How Model Switching Works

Model switching in CCM involves coordinating between the web dashboard, a state file, and your shell environment. Understanding this architecture helps you use the feature effectively and troubleshoot any issues that arise.

### The Challenge

Environment variables set in one process cannot affect other processes or the parent shell. When you run Claude Code, it reads environment variables from your current shell session. The CCM Dashboard runs in a separate Node.js process and cannot directly modify your shell's environment. This fundamental limitation requires a different approach than simply setting variables.

### The Solution

The CCM Dashboard implements a state-based switching mechanism that bridges the gap between the web interface and your shell environment. When you switch models in the dashboard, it writes your desired configuration to a state file at `~/.ccm_active_model`. This JSON file contains all the environment variables needed for your selected provider. You then run the `ccm apply` command in your terminal, which reads this state file and sets the environment variables in your current shell session. Finally, you restart Claude Code to use the new configuration.

This approach provides several advantages. The dashboard gives immediate visual feedback about your switch, the state file serves as a reliable communication channel between processes, and the apply command ensures variables are set correctly in your shell. Most importantly, you maintain full control over when the switch takes effect.

### Architecture Components

The switching system consists of four main components working together. The **Dashboard Frontend** provides the visual interface where you browse available models, see their configuration status, and initiate switches through confirmation dialogs. The **Backend API** handles the business logic, generating the correct environment variable configuration for each provider, handling fallback to PPINFRA when official keys are missing, and writing the configuration to the state file.

The **State File** (`~/.ccm_active_model`) acts as the communication bridge, storing the provider identifier, timestamp of the switch, and complete environment variable configuration in JSON format. Finally, the **Shell Integration** (`ccm apply`) reads the state file, exports environment variables to your current shell, displays confirmation of the switch, and cleans up the state file after applying.

## Using Model Switching

### Step-by-Step Process

Switching models through the dashboard follows a clear workflow that ensures you always know what is happening and have control over the process.

**Step 1: Open the Dashboard**

Launch the CCM Dashboard by running `ccm ui` in your terminal. The dashboard opens in your default web browser and displays all available models with their current configuration status. The "Current Active Model" section at the top shows which model is currently configured in your environment, if any.

**Step 2: Select a Model**

Browse the available models in the grid layout. Each model card shows the provider name, a brief description of its capabilities, the company or service behind it, and a status badge indicating whether it is configured, using fallback, or not set. Click the "Switch" button on the model you want to use.

**Step 3: Confirm the Switch**

A confirmation dialog appears showing you exactly what will change. The dialog displays your current model (if any) and the new model you selected. Review this information carefully to ensure you are switching to the correct provider. Click "Confirm Switch" to proceed, or "Cancel" to abort the operation.

**Step 4: Note the Instructions**

After confirming, the dashboard shows a success message with detailed instructions. The key command you need is `ccm apply`, which will apply the switch in your terminal. A convenient "Copy" button lets you copy this command to your clipboard. The instructions also remind you to restart Claude Code after applying the switch.

**Step 5: Apply in Terminal**

Open your terminal (or switch to an existing terminal session) and run the command `ccm apply`. This command reads the state file created by the dashboard and sets all necessary environment variables in your current shell session. You will see confirmation output showing which model was activated and what configuration was applied.

**Step 6: Restart Claude Code**

Close Claude Code if it is currently running, then launch it again from the terminal where you ran `ccm apply`. Claude Code will now use the new model configuration. You can verify this by checking the model name in Claude Code's interface or by running `ccm status` to see the current environment variables.

### Visual Workflow

The user experience is designed to be intuitive and provide clear feedback at every step. When you first open the dashboard, you immediately see an overview of all available models and their status. Models with green "Configured" badges have valid API keys and are ready to use. Yellow "Fallback" badges indicate the model will use PPINFRA as a backup service. Gray "Not Set" badges show models that need API key configuration before use.

Clicking a Switch button brings up a confirmation dialog that prevents accidental changes. The dialog clearly shows what you are switching from and to, giving you a chance to reconsider. After confirming, the instructions dialog provides everything you need to complete the switch, including a copy button for convenience. Throughout the process, toast notifications keep you informed of success or any errors that occur.

## Command Reference

### ccm apply

The `ccm apply` command is the bridge between the dashboard and your shell environment. When you run this command, it performs several operations to ensure a clean and correct switch.

**What It Does**

First, the command checks for the existence of `~/.ccm_active_model`. If no state file is found, it displays a message indicating there is no pending switch and suggests using the dashboard to prepare one. If the state file exists, the command parses the JSON content to extract the provider information and configuration details.

Next, it cleans any existing CCM-related environment variables from your shell to prevent conflicts. This includes unsetting `ANTHROPIC_BASE_URL`, `ANTHROPIC_API_URL`, `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_API_KEY`, `ANTHROPIC_MODEL`, and `ANTHROPIC_SMALL_FAST_MODEL`. After cleaning, it exports the new environment variables from the state file configuration. Finally, it displays a confirmation message showing which model was activated and removes the state file to prevent accidental reapplication.

**Output Example**

When you run `ccm apply`, you will see output similar to this:

```
╔════════════════════════════════════════╗
║      Applying Model Switch             ║
╚════════════════════════════════════════╝

Provider: DeepSeek
Prepared: 2024-11-13 23:45:12

✅ Switched to DeepSeek

Configuration:
   MODEL: deepseek-chat
   SMALL_MODEL: deepseek-chat
   BASE_URL: https://api.deepseek.com/anthropic

⚠️  Important:
   1. These environment variables are set for the current shell session
   2. Restart Claude Code for changes to take effect
   3. To make permanent, add to your shell RC file (~/.bashrc or ~/.zshrc)

✓ Switch state cleared
```

**Requirements**

The `ccm apply` command requires `jq` (a JSON processor) to be installed on your system. Most modern Unix-like systems have this available through package managers. On macOS, install it with `brew install jq`. On Ubuntu or Debian, use `sudo apt-get install jq`. The command will display a helpful error message if `jq` is not found, including installation instructions for your platform.

### ccm status

The `ccm status` command shows your current CCM configuration, including which model is active and what environment variables are set. This is useful for verifying that a switch was applied correctly or checking your configuration before making changes.

**What It Shows**

The status command displays all relevant environment variables with API keys masked for security. You will see the current `ANTHROPIC_BASE_URL`, `ANTHROPIC_MODEL`, `ANTHROPIC_SMALL_FAST_MODEL`, and which API key is being used (with only the first and last few characters visible). If there is a pending switch that has not been applied, the status command will indicate this and remind you to run `ccm apply`.

### ccm ui

The `ccm ui` command launches the CCM Dashboard in your default web browser. This is your entry point to the visual model management interface.

**What It Does**

When you run `ccm ui`, the command checks if the dashboard is installed at the expected location (`~/ccm-dashboard`). If found, it verifies that Node.js and dependencies are available, then starts the development server. The dashboard URL will be displayed in the terminal, and your browser should open automatically. If the browser does not open, you can manually navigate to the displayed URL (typically `http://localhost:3000`).

The dashboard server runs in the foreground, so keep the terminal window open while using the dashboard. Press Ctrl+C to stop the server when you are done.

## Configuration Files

### State File Format

The `~/.ccm_active_model` file uses JSON format for easy parsing and human readability. Understanding its structure helps you troubleshoot issues or even manually create switches if needed.

A typical state file looks like this:

```json
{
  "provider": "deepseek",
  "providerName": "DeepSeek",
  "timestamp": 1699564800000,
  "config": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_API_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "sk-...",
    "ANTHROPIC_API_KEY": "sk-...",
    "ANTHROPIC_MODEL": "deepseek-chat",
    "ANTHROPIC_SMALL_FAST_MODEL": "deepseek-chat"
  }
}
```

The `provider` field contains the internal identifier for the provider (e.g., "deepseek", "kimi", "claude"). The `providerName` field stores the human-readable display name. The `timestamp` field records when the switch was prepared, in milliseconds since the Unix epoch. The `config` object contains all environment variables that will be exported when you run `ccm apply`.

### Security Considerations

The state file contains your API keys in plain text, so it is important to protect it. The CCM Dashboard automatically sets file permissions to 600 (user read/write only) when creating the state file. This prevents other users on your system from reading your API keys. However, you should still be cautious about backing up this file or storing it in version control.

The state file is temporary by design. It exists only between the time you prepare a switch in the dashboard and when you apply it with `ccm apply`. After applying, the command deletes the state file automatically. If you cancel a switch or decide not to apply it, you can manually delete the file with `rm ~/.ccm_active_model`.

## Provider-Specific Configurations

Each AI provider has its own API endpoint, authentication method, and model identifiers. The CCM Dashboard handles these differences automatically, but understanding them helps you troubleshoot and customize your setup.

### DeepSeek

DeepSeek provides efficient reasoning models with strong coding capabilities. When you switch to DeepSeek with an official API key, the dashboard configures the base URL to `https://api.deepseek.com/anthropic`, sets the model to `deepseek-chat`, and uses your `DEEPSEEK_API_KEY` for authentication. If no official key is configured, the system falls back to PPINFRA with the model `deepseek/deepseek-v3.2-exp`.

### KIMI (Moonshot)

KIMI comes in two variants. The standard KIMI for Coding uses `https://api.kimi.com/coding/` as the base URL and is optimized for programming tasks with long context support. KIMI CN (Chinese version) uses `https://api.moonshot.cn/anthropic` and includes the K2 Thinking model for advanced reasoning. Both require a `KIMI_API_KEY` from Moonshot AI, with PPINFRA fallback available using `moonshotai/kimi-k2-thinking`.

### Qwen (Alibaba Cloud)

Qwen models from Alibaba Cloud use the DashScope API with the base URL `https://dashscope.aliyuncs.com/api/v2/apps/claude-code-proxy`. The default model is `qwen3-max`, with `qwen3-next-80b-a3b-instruct` as the small/fast model. Authentication requires a `QWEN_API_KEY` from your Alibaba Cloud account. PPINFRA fallback uses `qwen3-next-80b-a3b-thinking`.

### GLM (Zhipu AI)

GLM 4.6 from Zhipu AI provides advanced Chinese language understanding. The official endpoint is `https://open.bigmodel.cn/api/anthropic` with the model identifier `glm-4.6`. You need a `GLM_API_KEY` from Zhipu AI's platform. The PPINFRA fallback uses `zai-org/glm-4.6`.

### Claude (Anthropic)

Claude models (Sonnet, Opus, Haiku) use Anthropic's official API and do not require a custom base URL. The dashboard simply sets the model identifier and relies on your Claude Pro account credentials. Sonnet uses `claude-sonnet-4-5-20250929`, Opus uses `claude-opus-4-1-20250805`, and Haiku uses `claude-haiku-4-5`. These models require an active Claude Pro subscription and do not have PPINFRA fallback.

### MiniMax

MiniMax M2 provides multimodal capabilities through the endpoint `https://api.minimax.io/anthropic`. The model identifier is `MiniMax-M2` for both standard and small/fast models. Authentication requires a `MINIMAX_API_KEY`. PPINFRA fallback is available with `minimax/minimax-m2`.

### Seed/Doubao (ByteDance)

Doubao Seed-Code from ByteDance is optimized for coding tasks. It uses the Volcano Engine ARK platform with the base URL `https://ark.cn-beijing.volces.com/api/v3`. The model identifier is `doubao-seed-code-preview-latest`. You need an `ARK_API_KEY` from Volcano Engine. This provider does not currently have PPINFRA fallback support.

### LongCat (Meituan)

LongCat provides fast thinking and chat capabilities through `https://api.longcat.chat/anthropic`. It offers two models: `LongCat-Flash-Thinking` for reasoning tasks and `LongCat-Flash-Chat` for conversational interactions. Authentication requires a `LONGCAT_API_KEY`. PPINFRA fallback is not currently available for this provider.

### KAT (StreamLake)

StreamLake's KAT service provides the KAT-Coder model. Configuration details for this provider are managed through the CCM configuration file, including the endpoint ID. A `KAT_API_KEY` is required for authentication. PPINFRA fallback is not available.

## Troubleshooting

### Switch Not Applied

If you prepare a switch in the dashboard but do not see the new model active in Claude Code, several issues could be the cause.

**Forgot to Run ccm apply**

The most common issue is forgetting to run `ccm apply` after preparing the switch in the dashboard. The dashboard cannot directly modify your shell environment, so you must run the apply command to actually set the environment variables. Check if the state file exists with `ls -la ~/.ccm_active_model`. If the file is present, run `ccm apply` to complete the switch.

**Applied in Wrong Terminal**

Environment variables are specific to each shell session. If you run `ccm apply` in one terminal but launch Claude Code from a different terminal, the new configuration will not be active. Make sure you run `ccm apply` in the same terminal where you will launch Claude Code. Alternatively, run `ccm apply` in all terminals where you might launch Claude Code.

**Did Not Restart Claude Code**

Claude Code reads environment variables only at startup. If Claude Code was already running when you applied the switch, it will continue using the old configuration. Close Claude Code completely and relaunch it from the terminal where you ran `ccm apply`. You can verify the active configuration by running `ccm status` before launching Claude Code.

### API Key Errors

If the dashboard reports that an API key is missing or invalid, you need to configure it through the Settings panel.

**Key Not Configured**

Open the Settings panel in the dashboard and find the provider you want to use. Click the Edit button next to the API key field and enter your key. Click Save to store it in your `~/.ccm_config` file. The dashboard will automatically update the status badges to reflect the new configuration.

**Key Format Invalid**

Some providers have specific requirements for API key format. Ensure your key does not have extra spaces or line breaks. The key should be exactly as provided by the service, including any prefixes like "sk-" for some providers. If you copied the key from a website, try copying again to ensure you got the complete string.

**Key Expired or Revoked**

API keys can expire or be revoked by the provider. If you previously had a working key but now see errors, log in to the provider's dashboard and check if your key is still valid. You may need to generate a new key and update it in the CCM Dashboard settings.

### jq Not Found

The `ccm apply` command requires `jq` to parse the JSON state file. If you see an error about `jq` not being found, you need to install it.

**macOS Installation**

If you use Homebrew, run `brew install jq`. If you do not have Homebrew, you can install it from https://brew.sh/ first, then install jq.

**Linux Installation**

On Ubuntu, Debian, or other Debian-based distributions, run `sudo apt-get install jq`. On Fedora, CentOS, or RHEL, use `sudo yum install jq` or `sudo dnf install jq`. On Arch Linux, run `sudo pacman -S jq`.

**Verification**

After installation, verify that jq is working by running `jq --version`. You should see the version number displayed. If the command is not found, you may need to restart your terminal or add jq's installation directory to your PATH.

### Dashboard Won't Start

If the `ccm ui` command fails to start the dashboard, several issues could be preventing it.

**Dashboard Not Installed**

The dashboard must be installed at `~/ccm-dashboard` for the `ccm ui` command to find it. If you have not installed it yet, run the installation script from the CCM repository. If you installed it to a different location, either move it to the expected location or modify the `ccm-ui` script to point to your installation directory.

**Node.js Not Installed**

The dashboard requires Node.js version 18 or higher. Check if Node.js is installed by running `node --version`. If the command is not found or shows a version below 18, install or update Node.js from https://nodejs.org/.

**Dependencies Not Installed**

If Node.js is installed but the dashboard fails to start, dependencies might be missing. Navigate to the dashboard directory with `cd ~/ccm-dashboard` and run `pnpm install` or `npm install` to install all required packages. Then try `ccm ui` again.

**Port Already in Use**

The dashboard runs on port 3000 by default. If another application is using this port, the dashboard will fail to start. Check what is using the port with `lsof -i :3000` on macOS/Linux. Stop the other application or configure the dashboard to use a different port by editing the start script.

## Advanced Usage

### Making Switches Permanent

By default, environment variables set by `ccm apply` only affect the current shell session. If you want a particular model to be your default, you can add the configuration to your shell's RC file.

**Bash Users**

Edit `~/.bashrc` and add the export statements shown by `ccm apply`. For example:

```bash
export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
export ANTHROPIC_API_URL="https://api.deepseek.com/anthropic"
export ANTHROPIC_AUTH_TOKEN="$DEEPSEEK_API_KEY"
export ANTHROPIC_API_KEY="$DEEPSEEK_API_KEY"
export ANTHROPIC_MODEL="deepseek-chat"
export ANTHROPIC_SMALL_FAST_MODEL="deepseek-chat"
```

After editing, run `source ~/.bashrc` to apply the changes to your current session. All new terminal sessions will automatically have these variables set.

**Zsh Users**

Edit `~/.zshrc` instead of `~/.bashrc`, following the same process. Zsh users should run `source ~/.zshrc` after editing.

**Considerations**

Making a configuration permanent means it applies to all terminal sessions and persists across reboots. This is convenient if you primarily use one model, but it means you need to edit the RC file again to change your default. For users who frequently switch between models, using `ccm apply` for temporary switches is more flexible.

### Scripting and Automation

The model switching mechanism can be integrated into scripts and automation workflows.

**Checking for Pending Switches**

Your scripts can check if a switch is pending by testing for the state file:

```bash
if [ -f ~/.ccm_active_model ]; then
    echo "Pending model switch detected"
    # Optionally auto-apply
    ccm apply
fi
```

**Automated Switching**

You can prepare switches programmatically by calling the dashboard's API directly. The tRPC endpoint `ccm.switchModel` accepts a provider ID and creates the state file. This allows you to integrate model switching into larger automation workflows.

**Pre-Launch Checks**

Add a check to your Claude Code launch script to ensure the correct model is active:

```bash
#!/bin/bash
# Ensure DeepSeek is active before launching
ccm status | grep -q "deepseek" || ccm apply
claude-code
```

### Multiple Configurations

Some users work with different configurations for different projects or clients. You can manage multiple configurations by saving and restoring state files.

**Saving a Configuration**

After preparing a switch, copy the state file before applying:

```bash
cp ~/.ccm_active_model ~/.ccm_config_project_a
```

**Restoring a Configuration**

To switch back to a saved configuration:

```bash
cp ~/.ccm_config_project_a ~/.ccm_active_model
ccm apply
```

**Organizing Configurations**

Create a directory to store your configurations:

```bash
mkdir -p ~/.ccm_configs
cp ~/.ccm_active_model ~/.ccm_configs/project_a.json
```

This approach lets you maintain multiple configurations and quickly switch between them as needed.

## Best Practices

### Security

Protecting your API keys is crucial for preventing unauthorized usage and unexpected charges.

**File Permissions**

Always ensure your configuration files have restrictive permissions. The CCM Dashboard sets `~/.ccm_active_model` to 600 automatically, but you should verify your `~/.ccm_config` file is also protected:

```bash
chmod 600 ~/.ccm_config
```

**Environment Variables vs Files**

For production or shared systems, consider using environment variables instead of storing keys in files. Environment variables can be set through system configuration tools that provide better access control and auditing.

**Key Rotation**

Periodically rotate your API keys, especially if you suspect they may have been exposed. Most providers allow you to generate new keys and revoke old ones through their dashboards. After generating a new key, update it in the CCM Dashboard settings.

**Backup Considerations**

Be careful when backing up your home directory. Exclude `~/.ccm_config` and `~/.ccm_active_model` from backups that might be stored in less secure locations. If you must back up these files, encrypt the backup.

### Workflow Optimization

Develop efficient workflows that minimize friction while maintaining safety.

**Dashboard for Setup, CLI for Daily Use**

Use the dashboard for initial configuration and when adding new providers. Once your API keys are configured, use the CLI commands (`ccm deepseek`, `ccm kimi`, etc.) for quick switches during development. The CLI is faster for frequent switches, while the dashboard provides better visibility for less common operations.

**Verification Habit**

Develop a habit of running `ccm status` before starting work sessions. This quick check confirms which model is active and prevents surprises. Include it in your morning routine or project startup script.

**Documentation**

Document which models work best for which tasks in your team or personal notes. For example, you might use DeepSeek for general coding, KIMI for long context work, and Claude Opus for complex reasoning. Having this documented helps you make quick decisions about when to switch.

### Cost Management

Different providers have different pricing models, and switching between them can help manage costs.

**Monitor Usage**

Keep track of which models you use most frequently and how much each costs. Most providers offer usage dashboards where you can see your consumption. Use this data to optimize your model selection.

**Fallback Strategy**

The PPINFRA fallback service provides access to multiple models through a single API key. While this is convenient, understand the pricing and limitations of the fallback service compared to direct provider access. For heavy usage, direct provider keys may be more cost-effective.

**Model Selection**

Choose the right model for the task. You do not always need the most powerful model. For simple code edits or questions, a faster, cheaper model like Claude Haiku or DeepSeek may be sufficient. Reserve expensive models like Claude Opus for complex problems that truly require their capabilities.

## Conclusion

The CCM Dashboard's model switching functionality provides a bridge between visual configuration management and command-line efficiency. By understanding how the state file mechanism works and following the best practices outlined in this guide, you can seamlessly switch between AI providers to optimize your development workflow.

The key to effective use is remembering that the dashboard prepares switches while `ccm apply` executes them. This two-step process gives you control and visibility while maintaining the security and reliability of your configuration. Combined with the existing CLI tools, you now have a complete toolkit for managing your Claude Code AI provider configuration.

---

**Version**: 1.0  
**Last Updated**: November 2024  
**Author**: Manus AI
