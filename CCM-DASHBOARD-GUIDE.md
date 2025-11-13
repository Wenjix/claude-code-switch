# CCM Dashboard User Guide

## Overview

The **CCM Dashboard** is a modern web-based interface for the Claude Code Model Switcher (CCM) that provides visual management of your AI model configurations. It complements the existing command-line tools by offering an intuitive graphical interface to view, configure, and switch between different AI providers.

## Key Features

The dashboard provides a comprehensive visual interface for managing your Claude Code model configurations. At the center of the experience is a real-time status display that shows your currently active model, along with its provider information and configuration details. The model grid presents all twelve supported AI providers in an organized card layout, each displaying the provider name, description, and current configuration status through color-coded badges.

Configuration management is streamlined through the integrated settings panel, where you can securely manage API keys for all providers with masked display for security. The dashboard includes connection testing functionality to verify your API credentials before switching models. A confirmation dialog ensures safe model switching by showing you exactly what will change before applying any modifications.

Visual status indicators make it immediately clear which providers are fully configured with valid API keys, which are using fallback services, and which still need setup. The interface supports both light and dark themes for comfortable viewing in any environment, and the responsive design ensures the dashboard works seamlessly across desktop and mobile devices.

## Supported AI Providers

The CCM Dashboard supports twelve different AI model providers, each offering unique capabilities and strengths.

**Anthropic Models** include Claude Sonnet 4.5, which provides balanced performance and speed for general-purpose tasks. Claude Opus 4.1 represents the most capable model in the lineup, ideal for complex reasoning and challenging problems. Claude Haiku 4.5 offers the fastest response times when speed is the priority.

**Chinese AI Providers** are well-represented with DeepSeek offering efficient reasoning and strong coding capabilities. Zhipu AI's GLM 4.6 provides advanced Chinese language understanding and generation. Moonshot's KIMI comes in two variants: KIMI for Coding optimized for long context programming tasks, and KIMI CN (K2 Thinking) featuring advanced reasoning capabilities for Chinese language tasks.

**Cloud Platform Models** include Alibaba Cloud's Qwen 3 Max, their flagship model with strong multilingual support. MiniMax M2 brings multimodal capabilities to the table. Meituan's LongCat Flash provides fast thinking and chat capabilities. ByteDance contributes Doubao Seed-Code, specifically optimized for coding tasks.

**Infrastructure Services** round out the options with StreamLake's KAT service and PPINFRA serving as a fallback service provider when official API keys are not configured.

## Installation

### Prerequisites

Before installing the CCM Dashboard, ensure you have Node.js version 18 or higher installed on your system. You can verify your installation by running `node --version` in your terminal. The package manager pnpm is recommended but not required, as npm will work as an alternative.

### Installation Steps

The dashboard installation process is straightforward. First, navigate to your CCM installation directory where you cloned the claude-code-switch repository. Run the installation script with `./install-ui.sh`, which will check your system requirements and set up the necessary components.

If you prefer manual installation, you can navigate to the ccm-dashboard directory and install dependencies using either `pnpm install` or `npm install`. Once dependencies are installed, you can start the development server with `pnpm dev` or `npm run dev`.

## Launching the Dashboard

### Using the CLI Command

The simplest way to launch the dashboard is through the integrated CLI command. Simply run `ccm ui` from any directory, and the dashboard will start automatically. The terminal will display the local URL where the dashboard is accessible, typically `http://localhost:3000`. Your default web browser should open automatically to this address.

### Manual Launch

If you prefer to launch the dashboard manually, navigate to the ccm-dashboard directory and run the development server with `pnpm dev` or `npm run dev`. The server will start and display the access URL in the terminal.

## Using the Dashboard

### Main Dashboard View

When you first open the dashboard, you are greeted with the main view that provides an at-a-glance overview of your CCM configuration. The top of the page features the Current Active Model card, prominently displaying which model is currently configured for Claude Code. This card shows the model name, provider, description, and the base URL being used for API calls.

Below the active model card, you will find the Available Models grid, which displays all twelve supported providers in a clean card layout. Each model card contains the provider logo or initials, the model name and provider, a brief description of its capabilities, a status badge indicating configuration state, and a Switch button to change to that model.

At the bottom of the dashboard, quick statistics provide useful metrics including the total number of providers, how many are fully configured, and how many still need API keys to be set up.

### Model Status Indicators

The dashboard uses three distinct status badges to communicate the configuration state of each provider. A green "Configured" badge indicates that the provider has a valid API key set and is ready to use. A yellow "Fallback" badge means no direct API key is configured, but the provider can use the PPINFRA fallback service. A gray "Not Set" badge shows that no API key is configured and no fallback is available.

### Switching Models

To switch to a different model, simply click the Switch button on any model card in the grid. A confirmation dialog will appear showing you the current model and the new model you are switching to. Review the changes and click "Confirm Switch" to apply the change, or "Cancel" to abort the operation. After confirming, the dashboard will update the configuration and the new model will become active.

### Settings Panel

Access the settings panel by clicking the Settings button in the top-right corner of the dashboard. The settings interface is divided into two main sections.

The API Key Management section allows you to configure authentication credentials for each provider. Each provider row displays the provider name, a masked API key field for security, a status indicator showing whether the key is valid, an Edit button to modify the key, and a Test button to verify the connection.

To update an API key, click the Edit button next to the provider name. The key field becomes editable, allowing you to enter or paste your new API key. Click Save to store the changes to your configuration file. You can then click Test to verify that the connection works with the new credentials.

The Preferences section provides interface customization options. Toggle between light and dark themes using the Dark Mode switch. Language settings can be configured to match your preference, with support for English and Chinese interfaces.

## Configuration File

### Location and Format

The CCM Dashboard reads from and writes to the standard CCM configuration file located at `~/.ccm_config`. This file uses a simple key-value format that is both human-readable and machine-parseable. The configuration file is shared between the CLI tools and the dashboard, ensuring consistency across all interfaces.

### Configuration Priority

When determining which API key to use, CCM follows a specific priority order. Environment variables take the highest priority, overriding any values in the configuration file. The configuration file values are used when no environment variable is set. Finally, built-in fallback keys are used as a last resort when no other configuration is available.

### Security Considerations

The dashboard implements several security measures to protect your API credentials. API keys are always masked in the interface, showing only the first and last four characters. Keys are stored in plain text in the configuration file, so ensure proper file permissions are set with `chmod 600 ~/.ccm_config`. The dashboard never transmits API keys over the network except when testing connections to the respective provider APIs. For production deployments, consider using environment variables instead of storing keys in the configuration file.

## Troubleshooting

### Dashboard Won't Start

If the dashboard fails to start, first verify that Node.js is installed and accessible by running `node --version`. Check that you are in the correct directory (ccm-dashboard) when running the start command. Ensure all dependencies are installed by running `pnpm install` or `npm install`. Check for port conflicts if port 3000 is already in use by another application.

### Models Show "Not Set" Status

When all models display a "Not Set" status, this typically indicates that no API keys are configured in the `~/.ccm_config` file. Open the Settings panel and add your API keys for the providers you want to use. After saving, refresh the dashboard to see the updated status. Remember that you need to obtain API keys from each provider's website before you can use their services.

### Connection Test Fails

If a connection test fails despite having an API key configured, verify that the API key is correct and has not expired. Check your internet connection to ensure you can reach the provider's API endpoints. Some providers may have rate limits or require additional setup beyond just the API key. Consult the provider's documentation for specific requirements.

### Changes Not Reflected in Claude Code

After making changes in the dashboard, you may need to restart Claude Code for the new configuration to take effect. The dashboard updates the configuration file, but Claude Code reads this file only at startup. Close and reopen Claude Code to load the new settings. Alternatively, use the CLI command `ccm status` to verify that the changes were written correctly to the configuration file.

## Integration with CLI Tools

### Complementary Usage

The CCM Dashboard is designed to work seamlessly alongside the existing CLI tools. Use the CLI for quick switches during your workflow with commands like `ccm deepseek` or `ccc kimi`. The dashboard is ideal for initial setup and configuration, managing multiple API keys, and getting a visual overview of your configuration status. Both interfaces read from and write to the same configuration file, ensuring consistency.

### Workflow Recommendations

For the most efficient workflow, use the dashboard for your initial setup by configuring all your API keys at once and testing connections to verify everything works. During daily development, use the CLI for quick model switches with commands like `ccc deepseek` or `ccm opus`. Return to the dashboard periodically for configuration review, checking which models are configured, and updating API keys when they expire or change.

## Best Practices

### API Key Management

Maintain good security practices with your API credentials. Never commit the `~/.ccm_config` file to version control systems. Use environment variables for sensitive production deployments. Rotate API keys periodically to maintain security. Keep backup copies of your configuration in a secure location. Set restrictive file permissions on the configuration file with `chmod 600 ~/.ccm_config`.

### Model Selection

Choose the right model for your specific task requirements. For complex reasoning tasks and difficult problems, use Claude Opus. For balanced performance across most coding tasks, Claude Sonnet is an excellent choice. When you need quick responses and fast iteration, Claude Haiku provides the speed you need. For Chinese language tasks, consider GLM or KIMI CN. When working with long context or large codebases, KIMI for Coding excels.

### Configuration Backup

Protect your configuration by regularly backing up your `~/.ccm_config` file. Document which API keys are used for which providers. Keep a secure record of where to obtain new API keys if needed. Test your backup configuration periodically to ensure it works. Consider using a password manager to store API keys securely.

## Advanced Features

### Environment Variable Override

You can override any configuration file setting using environment variables. This is particularly useful for CI/CD pipelines or temporary testing. For example, `export DEEPSEEK_API_KEY=sk-your-key` will override the value in the configuration file. Environment variables take precedence over file configuration, allowing for flexible deployment scenarios.

### Custom Model IDs

The dashboard supports custom model ID overrides for advanced users. You can specify alternative model identifiers in the configuration file if a provider offers multiple model versions. This allows you to use beta models or specific model versions when needed.

### Fallback Configuration

The PPINFRA fallback service provides a safety net when official API keys are not configured. This allows you to test CCM and the dashboard without immediately setting up accounts with every provider. However, for production use and best performance, configure official API keys for the providers you regularly use.

## Support and Resources

### Getting Help

If you encounter issues or have questions about the CCM Dashboard, several resources are available. Check the main CCM README file for general information about the project. Review the troubleshooting section of this guide for common problems and solutions. Visit the GitHub repository to report bugs or request features. Consult individual provider documentation for API-specific questions.

### Contributing

The CCM Dashboard is part of the open-source claude-code-switch project. Contributions are welcome through pull requests on GitHub. Report bugs and suggest features through the GitHub issue tracker. Share your experience and help other users in discussions. Improve documentation by submitting clarifications or additions.

## Conclusion

The CCM Dashboard provides a modern, intuitive interface for managing your Claude Code model configurations. By combining the speed of CLI tools with the clarity of a visual interface, it offers the best of both worlds for developers who work with multiple AI providers. Whether you are setting up CCM for the first time or managing a complex multi-provider configuration, the dashboard streamlines the process and makes it easy to stay organized.

---

**Version**: 1.0  
**Last Updated**: November 2024  
**Author**: Manus AI
