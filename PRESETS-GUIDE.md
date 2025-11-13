# CCM Dashboard Model Presets Guide

**Author:** Manus AI  
**Last Updated:** November 13, 2025

## Overview

The Model Presets feature in the CCM Dashboard allows you to save your favorite model configurations as named presets and switch between them with a single click. This feature is designed to streamline your workflow by eliminating the need to repeatedly configure the same model settings for different projects, tasks, or contexts.

## Why Use Presets

Managing multiple AI model configurations can become tedious when you frequently switch between different workflows. The presets system addresses this challenge by providing a convenient way to organize and access your most-used model configurations.

### Common Use Cases

**Project-Based Workflows** benefit significantly from presets. If you work on multiple projects that require different AI models—for example, using Claude Opus for complex architectural work and DeepSeek for routine coding tasks—you can create a preset for each project and switch between them instantly.

**Task-Specific Configurations** represent another valuable application. Different types of work often demand different model capabilities. You might create a "Code Review" preset using Claude Sonnet for balanced performance, an "Experimentation" preset with DeepSeek for cost-effective testing, and a "Documentation" preset with Claude Haiku for fast iteration.

**Team Collaboration** scenarios also benefit from presets. When working with a team, you can establish standard presets that everyone uses for specific purposes, ensuring consistency across your organization. For example, a "Production" preset might use Claude Opus for critical work, while a "Development" preset uses a more economical option.

## Creating Presets

The CCM Dashboard provides two methods for creating presets, each suited to different workflows.

### Method 1: Save from Dashboard

The quickest way to create a preset is directly from the main dashboard. When you see a model configuration you want to save, simply click the bookmark icon next to the Switch button on that model's card. This opens the "Save as Preset" dialog where you can provide a name and optional description.

The process follows these steps:

Navigate to the main CCM Dashboard and locate the model you want to save as a preset. Click the bookmark icon (📑) next to the Switch button on the model card. Enter a descriptive name for your preset in the dialog that appears. Optionally, add a description explaining what this preset is for or when to use it. Click "Save Preset" to create the preset.

The preset is immediately saved to the database and becomes available in the Presets page for future use.

### Method 2: Create from Presets Page

For more control over preset creation, including the ability to choose custom icons and colors, use the dedicated Presets page.

Access the Presets page by clicking the "Presets" button in the dashboard header. Click the "New Preset" button in the top-right corner. Fill in the preset details including name, description, model provider, icon, and color. Click "Create Preset" to save your configuration.

The Presets page offers additional customization options not available in the quick-save method. You can select from eight different emoji icons (⚡, 🚀, 💼, 🎯, 🔬, 🎨, 📚, ⚙️) and six color schemes to visually distinguish your presets.

## Managing Presets

Once created, presets can be viewed, edited, and organized through the Presets page.

### Viewing Presets

The Presets page displays all your saved presets in a grid layout. Each preset card shows the preset name, associated model provider, description, icon, and color scheme. Default presets are marked with a star badge for easy identification.

Presets are automatically sorted with the default preset appearing first, followed by other presets in reverse chronological order (newest first). This ensures your most important and recently created presets are always easily accessible.

### Editing Presets

To modify an existing preset, click the edit icon (pencil) on the preset card. This opens the edit dialog where you can change any aspect of the preset including its name, description, provider, icon, or color.

Changes are saved immediately when you click "Save Changes". The system validates that preset names remain unique—you cannot change a preset's name to match another existing preset.

### Deleting Presets

When a preset is no longer needed, click the trash icon on the preset card. A confirmation dialog appears to prevent accidental deletion. Confirm the deletion to permanently remove the preset from your collection.

Deleted presets cannot be recovered, so ensure you truly no longer need a preset before confirming deletion.

### Setting Default Preset

The default preset feature allows you to designate one preset as your primary configuration. This is particularly useful if you have a go-to model that you use most frequently.

To set a preset as default, click the "Set as Default" button at the bottom of the preset card. The system automatically removes the default flag from any previously designated default preset, ensuring only one preset is marked as default at a time.

Default presets are visually distinguished with a yellow star badge and appear first in the preset list.

## Applying Presets

The primary purpose of presets is to enable quick model switching. The CCM Dashboard provides a streamlined process for applying saved presets to your environment.

### One-Click Application

To apply a preset, simply click the "Apply" button (with lightning bolt icon) on the preset card. The system immediately configures the model switch and displays a success notification.

The application process follows the same workflow as manual model switching. The dashboard writes the configuration to the `~/.ccm_active_model` file, but the switch does not take effect in your shell environment until you run the `ccm apply` command.

### Post-Application Steps

After clicking "Apply" on a preset, you must complete the activation process in your terminal:

```bash
# Activate the preset configuration
ccm apply

# Verify the switch was successful
ccm status
```

The `ccm apply` command reads the configuration file and updates your shell environment variables to use the selected model. The `ccm status` command confirms which model is currently active.

## Preset Data Structure

Understanding how presets are stored helps you appreciate the system's capabilities and limitations.

### Database Schema

Presets are stored in the `model_presets` table with the following structure:

| Field | Type | Description |
|-------|------|-------------|
| id | Integer | Unique identifier (auto-increment) |
| name | String (128) | Preset display name |
| description | Text | Optional description of the preset's purpose |
| provider | String (64) | Model provider identifier (e.g., "claude-sonnet") |
| icon | String (32) | Optional emoji or icon identifier |
| color | String (32) | Optional color class for UI display |
| isDefault | Integer | Default flag (0 = false, 1 = true) |
| createdAt | DateTime | Timestamp when preset was created |
| updatedAt | DateTime | Timestamp of last modification |

The `isDefault` field uses integer values (0 or 1) instead of boolean to ensure compatibility with MySQL's integer-based boolean representation.

### Unique Constraints

Preset names must be unique across your entire preset collection. The system enforces this constraint at both the database level and through application-level validation. When creating or editing a preset, the backend checks for name conflicts and returns an error if a duplicate is detected.

This ensures you can reliably reference presets by name without ambiguity.

## Advanced Features

The presets system includes several advanced capabilities that enhance usability and integration with other dashboard features.

### Analytics Integration

Preset switches are automatically tracked in the analytics system. When you apply a preset, the system records a switch event in the database, associating it with the preset you used. This allows the analytics dashboard to show which presets you use most frequently and how they contribute to your overall model usage patterns.

Future enhancements may include preset-specific analytics, showing metrics like average session duration per preset, cost estimates for each preset, and recommendations for optimizing your preset collection.

### Default Preset Behavior

The default preset serves as a suggested starting point but does not automatically apply when you open the dashboard. This design decision ensures you maintain explicit control over which model is active at any given time.

If you want to automatically apply your default preset when starting a new session, you can create a shell alias or script that runs both `ccm ui` to open the dashboard and `ccm apply` to activate the default configuration.

### Preset Naming Best Practices

Choosing effective preset names improves usability and helps you quickly identify the right configuration for each situation. Consider these naming strategies:

**Descriptive Names** clearly indicate the preset's purpose. Examples include "Code Review", "Documentation Writing", "Complex Debugging", or "Quick Prototyping". These names immediately communicate when to use each preset.

**Project Names** work well if you maintain separate presets for different projects. Examples might be "Project Alpha", "Client Website", or "Internal Tools". This approach is particularly useful in team environments where multiple people work on the same projects.

**Context-Based Names** describe the working environment or constraints. Examples include "Low Budget", "High Performance", "Fast Iteration", or "Production Ready". These names help you select presets based on your current needs rather than specific projects.

Avoid generic names like "Preset 1" or "Test" that provide no context about the preset's purpose. The description field can supplement the name with additional details, but the name itself should be self-explanatory.

## Integration with CLI Tools

While the dashboard provides a visual interface for managing presets, the underlying configuration system remains compatible with the command-line CCM tools.

### Manual Preset Application

You can manually apply preset configurations using the standard `ccm` command-line interface. The dashboard writes preset configurations to the same `~/.ccm_active_model` file that the CLI tools use, ensuring complete compatibility.

To view the current pending configuration (which may have been set by a preset), run:

```bash
cat ~/.ccm_active_model
```

This displays the JSON configuration that will be applied when you run `ccm apply`.

### Preset Persistence

Presets are stored in the database and persist across dashboard sessions. Even if you close the browser or restart the dashboard server, your presets remain available. This ensures your preset collection is always accessible regardless of how you interact with the CCM system.

The database-backed storage also enables future enhancements like preset synchronization across multiple machines or sharing presets with team members.

## Troubleshooting

Common issues and their solutions when working with presets.

### Preset Not Appearing After Creation

If you create a preset but it doesn't appear in the presets list, check for these potential issues:

**Browser Cache** may be displaying stale data. Refresh the page (Ctrl+R or Cmd+R) to reload the preset list from the server.

**Database Connection** problems can prevent presets from being saved. Check the browser console (F12) for error messages indicating database connectivity issues.

**Name Conflicts** cause creation to fail silently in some cases. Ensure your preset name is unique and doesn't match any existing preset.

### Preset Application Not Taking Effect

When you apply a preset but the model doesn't change, verify these steps:

**Run ccm apply** in your terminal. The dashboard only writes the configuration file—you must run `ccm apply` to activate it in your shell environment.

**Check Shell Session** to ensure you're running `ccm apply` in the same terminal where you want to use the model. Environment variables are session-specific and don't propagate across different terminal windows.

**Verify Configuration** by running `ccm status` after applying. This confirms which model is actually active in your current shell.

### Cannot Delete Preset

If the delete operation fails, possible causes include:

**Network Issues** preventing the delete request from reaching the server. Check your internet connection and try again.

**Database Locks** in rare cases can prevent deletion. Wait a moment and retry the operation.

**Permission Problems** should not occur in the current implementation but could arise in future multi-user versions.

## Future Enhancements

Several planned features will expand the presets system's capabilities in future releases.

### Preset Import/Export

The ability to export presets to JSON files and import them on other machines would enable preset sharing and backup. This feature would be particularly valuable for teams who want to standardize their model configurations across multiple developers.

### Preset Templates

Pre-configured preset templates for common use cases (like "Cost-Optimized", "Performance-Focused", or "Balanced") would help new users get started quickly without needing to understand all the available models.

### Preset Scheduling

Automatic preset switching based on time of day or calendar events could optimize costs by using cheaper models during off-peak hours and reserving premium models for critical work periods.

### Preset Groups

Organizing presets into folders or categories would improve manageability for users with large preset collections. For example, you might have groups for "Work", "Personal", and "Experimentation".

### Preset Recommendations

Machine learning analysis of your usage patterns could suggest new presets based on frequently-used model combinations or identify opportunities to consolidate similar presets.

## Best Practices

Maximize the value of the presets system by following these recommended practices.

### Start with Core Workflows

Begin by creating presets for your most common workflows rather than trying to preset every possible configuration. Focus on the model switches you perform most frequently—these are the ones where presets will save the most time.

As you become comfortable with the preset system, gradually add more specialized presets for edge cases and occasional tasks.

### Use Descriptive Metadata

Take advantage of the description field to document when and why you use each preset. Future you (or your teammates) will appreciate the context when deciding which preset to apply.

Similarly, choose icons and colors that create visual associations with each preset's purpose. For example, use the rocket emoji (🚀) for high-performance presets or the briefcase emoji (💼) for work-related configurations.

### Maintain a Default Preset

Designate one preset as your default to establish a consistent starting point for new work sessions. This should typically be your most frequently-used configuration or a balanced option that works well for general-purpose tasks.

Update your default preset as your needs evolve. What works as a default today might not be optimal in six months as your projects and priorities change.

### Regularly Review and Prune

Periodically review your preset collection and delete presets you no longer use. A cluttered preset list makes it harder to find the configurations you actually need.

Consider setting a reminder to review your presets quarterly, removing outdated configurations and updating descriptions to reflect current usage patterns.

### Combine with Analytics

Use the analytics dashboard to identify which presets you use most frequently and which ones might be redundant. If two presets have similar usage patterns and configurations, consider consolidating them into a single preset.

Analytics can also reveal opportunities to create new presets. If you frequently switch between the same two models manually, that's a sign you should create a preset for that configuration.

## Security Considerations

The presets system stores model provider identifiers but does not store API keys or other sensitive credentials. This design ensures that presets can be safely shared or exported without exposing authentication information.

API keys remain in the `~/.ccm_config` file and environment variables, separate from the preset definitions. When you apply a preset, the system uses the provider identifier to look up the appropriate API key from your existing configuration.

This separation of concerns means you can freely create, edit, and share presets without worrying about credential exposure.

## Conclusion

The Model Presets feature transforms the CCM Dashboard from a simple model switcher into a comprehensive workflow management tool. By saving your favorite configurations and enabling one-click switching, presets eliminate repetitive configuration tasks and help you focus on your actual work.

Whether you're managing multiple projects, optimizing costs across different models, or collaborating with a team, presets provide the flexibility and convenience to adapt your AI model usage to your specific needs.

Start by creating presets for your most common workflows, use the analytics dashboard to track their effectiveness, and gradually refine your preset collection as your needs evolve. With thoughtful organization and regular maintenance, the presets system becomes an indispensable part of your AI development workflow.
