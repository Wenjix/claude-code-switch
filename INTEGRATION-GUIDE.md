# CCM Dashboard Integration Guide

## Overview

This guide provides technical details for developers who want to integrate the CCM Dashboard into their workflow, extend its functionality, or understand its architecture. The dashboard is built with modern web technologies and follows best practices for maintainability and extensibility.

## Architecture

### Technology Stack

The CCM Dashboard is built on a modern full-stack architecture that ensures type safety and developer productivity. The frontend uses React 19 with TypeScript for type-safe component development, Tailwind CSS 4 for utility-first styling, and Wouter for lightweight client-side routing. The component library is based on shadcn/ui, providing accessible and customizable UI components. State management and server communication are handled through tRPC 11 with React Query, ensuring end-to-end type safety.

The backend runs on Node.js with Express 4 serving as the HTTP server foundation. tRPC provides the API layer with full TypeScript integration, while Drizzle ORM handles database operations when needed. The authentication system uses Manus OAuth for secure user management. The entire application is built with Vite for fast development and optimized production builds.

### Project Structure

The project follows a clear organizational structure that separates concerns and promotes maintainability. The client directory contains all frontend code, with the src subdirectory housing pages for route components, components for reusable UI elements, lib for utility functions and tRPC client setup, and contexts for React context providers. The server directory contains the backend logic, including routers.ts for tRPC procedure definitions, ccm-service.ts for CCM-specific business logic, and db.ts for database operations. The shared directory provides common code used by both client and server, such as ccm-types.ts for TypeScript type definitions and model-definitions.ts for provider metadata.

### Data Flow

Understanding the data flow helps developers work effectively with the dashboard. When the client needs data, it calls a tRPC hook like `trpc.ccm.models.useQuery()`. This triggers a type-safe API request to the server, where the corresponding procedure in `server/routers.ts` executes. The procedure calls service functions in `server/ccm-service.ts` to perform the actual work, such as reading the configuration file or querying environment variables. The service returns data to the procedure, which sends it back to the client. React Query automatically caches the response and manages loading states, providing a smooth user experience.

For mutations that modify data, the client calls a mutation hook like `trpc.ccm.updateApiKey.useMutation()`. After the mutation succeeds, the client invalidates relevant queries using `utils.ccm.config.invalidate()`, which triggers automatic refetching of updated data. This pattern ensures the UI always reflects the current state without manual refresh logic.

## Backend API

### CCM Service Layer

The core business logic resides in `server/ccm-service.ts`, which provides functions for interacting with CCM configuration. The `readCCMConfig()` function parses the `~/.ccm_config` file and returns a typed configuration object. It handles comments, inline comments, and various formatting styles gracefully. The `writeCCMConfig()` function takes a configuration object and writes it back to the file with proper formatting and comments preserved.

The `getCurrentModelStatus()` function examines environment variables to determine which model is currently active. It returns information about the provider, model IDs, base URL, and authentication status. The `getAllModels()` function combines configuration data with model definitions to return a complete list of all providers with their current status. This function is the primary data source for the dashboard's model grid.

API key management is handled through `updateApiKey()`, which modifies a specific provider's API key in the configuration file, and `maskApiKey()`, which safely masks API keys for display in the UI, showing only the first and last four characters.

### tRPC Procedures

The tRPC router in `server/routers.ts` exposes several procedures that the frontend can call. The `ccm.models` query returns all model providers with their configuration status, including whether they are configured, using fallback, or not set. The `ccm.status` query returns the current active model information from environment variables. The `ccm.config` query returns the full configuration with masked API keys for security.

The `ccm.updateApiKey` mutation accepts a provider ID and new API key, updating the configuration file accordingly. The `ccm.testConnection` mutation attempts to verify that an API key is valid by checking its format and presence. In a production implementation, this would make an actual API call to the provider to verify connectivity.

### File System Operations

The dashboard interacts with the file system to read and write configuration files. All file operations use Node.js async APIs with proper error handling. The configuration file path is resolved using `os.homedir()` to ensure cross-platform compatibility. When the configuration file does not exist, the service gracefully returns an empty configuration rather than throwing an error, allowing for first-time setup scenarios.

File writes are atomic, using `fs.writeFile()` to replace the entire file contents at once. This prevents partial writes that could corrupt the configuration. The service preserves the overall structure and comments in the configuration file, making it still human-readable and editable with a text editor.

## Frontend Components

### Dashboard Page

The main dashboard page (`client/src/pages/Dashboard.tsx`) serves as the primary interface for viewing and switching models. It uses tRPC queries to fetch model data and current status, displaying the active model in a prominent card at the top of the page. The model grid shows all available providers with their status badges and switch buttons. Quick statistics at the bottom provide an overview of configuration completeness.

The component implements a confirmation dialog before switching models, preventing accidental changes. The dialog shows the current and new model side by side, making it clear what will change. State management is handled through React hooks, with `useState` managing local UI state like dialog visibility and `trpc` hooks managing server data.

### Settings Page

The settings page (`client/src/pages/Settings.tsx`) provides comprehensive configuration management. It displays all API keys in an editable format with masked display for security. Each provider row includes edit and test buttons for managing credentials. The page uses optimistic updates for a responsive feel, immediately reflecting changes in the UI while the server processes the request.

The component implements visibility toggles for API keys, allowing users to temporarily reveal masked keys when needed. Input validation ensures that empty or invalid keys are not saved. Error handling provides clear feedback when operations fail, using toast notifications to communicate success or failure.

### Reusable Components

The dashboard leverages shadcn/ui components throughout the interface for consistency and accessibility. The Card component provides the container for model information and settings sections. The Button component handles all interactive actions with consistent styling and states. The Dialog component creates modal overlays for confirmations and detailed information. The Badge component displays status indicators with color-coded variants. The Input component provides text entry with built-in styling and accessibility features.

These components are customizable through Tailwind classes and variant props, allowing the dashboard to maintain a cohesive design language while adapting to different contexts.

## Extending the Dashboard

### Adding New Providers

To add support for a new AI provider, you need to update several files in a coordinated manner. First, add the provider ID to the `ModelProvider` type in `shared/ccm-types.ts`. Then, add a new entry to `MODEL_DEFINITIONS` in `shared/model-definitions.ts` with all the provider metadata including name, description, API key name, and default model IDs. Update the `MODEL_ORDER` array to control where the new provider appears in the grid.

In the configuration file handling code (`server/ccm-service.ts`), add the new API key field to the `apiKeys` array in `writeCCMConfig()`. This ensures the configuration file includes the new provider. Finally, test the integration by adding an API key through the settings panel and verifying that the provider appears correctly in the model grid with proper status indication.

### Custom Status Indicators

The dashboard uses three standard status values: configured, fallback, and not_set. If you need additional status types, modify the `ApiKeyStatus` type in `shared/ccm-types.ts` to include your new status values. Update the `getApiKeyStatus()` function in `server/ccm-service.ts` to return your new status values based on your custom logic.

In the frontend components, update the `getStatusBadge()` and `getStatusIcon()` functions to handle your new status types with appropriate colors and icons. Consider the user experience implications of adding more status types, as too many options can create confusion.

### Enhanced Connection Testing

The current connection test implementation is a placeholder that only verifies the API key is set. To implement real connection testing, modify the `testConnection` procedure in `server/routers.ts` to make an actual API call to the provider. Each provider has different authentication methods and test endpoints, so you will need to implement provider-specific logic.

A robust implementation would use a switch statement on the provider ID, calling the appropriate API endpoint for each provider. Handle various error conditions such as network timeouts, invalid credentials, and rate limiting. Return detailed error messages to help users diagnose connection problems. Consider implementing caching to avoid excessive API calls during testing.

### Model Switching Implementation

The current model switching feature shows a confirmation dialog but does not actually change the environment variables. To implement real model switching, you need to update environment variables in the Node.js process. However, environment variables set in the Node.js process do not affect the parent shell or other processes.

For true model switching, you have several options. The dashboard could write a shell script that sets environment variables and then instructs the user to source it. Alternatively, the dashboard could update the configuration file and instruct the user to restart Claude Code. For a more integrated solution, the dashboard could communicate with the CCM CLI tools through a socket or file-based IPC mechanism to trigger a switch in the user's shell session.

## Development Workflow

### Local Development

To set up a local development environment, first clone the repository and navigate to the ccm-dashboard directory. Install dependencies with `pnpm install` or `npm install`. Start the development server with `pnpm dev` or `npm run dev`. The server will start on port 3000 with hot module replacement enabled, allowing you to see changes immediately as you edit files.

The development server includes several useful features. TypeScript compilation runs in watch mode, reporting type errors as you code. The tRPC client automatically generates types from your server procedures, ensuring type safety across the API boundary. Vite provides fast hot module replacement, updating the browser without full page reloads. The console displays helpful error messages and warnings during development.

### Testing Changes

When making changes to the dashboard, test both the frontend and backend components thoroughly. For frontend changes, verify that the UI displays correctly in both light and dark themes. Test responsive behavior by resizing the browser window. Ensure all interactive elements work as expected, including buttons, dialogs, and form inputs. Check that loading states and error messages display appropriately.

For backend changes, test API endpoints using the browser's developer tools network tab. Verify that configuration file reads and writes work correctly by examining `~/.ccm_config` after operations. Test error handling by simulating failure conditions such as missing files or invalid data. Ensure that type safety is maintained across the tRPC boundary by checking for TypeScript errors.

### Building for Production

To create a production build, run `pnpm build` or `npm run build`. This compiles TypeScript, bundles the frontend with Vite, and prepares the server code for deployment. The build process performs type checking, ensuring no type errors exist in the codebase. It also optimizes assets, minifying JavaScript and CSS for faster loading.

The production build outputs to the `dist` directory, with separate subdirectories for client and server code. To run the production build, use `pnpm start` or `npm start`, which starts the Express server serving the built frontend. For deployment to a server, copy the entire project directory including `node_modules`, or use a containerization solution like Docker.

## Security Considerations

### API Key Storage

The dashboard stores API keys in the `~/.ccm_config` file in plain text, which is consistent with the existing CCM CLI tools. However, this approach has security implications. The configuration file should have restrictive permissions (600) to prevent other users from reading it. For production deployments, consider using environment variables instead of file storage. More secure alternatives include using system keychains or secret management services.

The dashboard never transmits API keys to any server except the respective provider's API during connection testing. Keys are masked in the UI to prevent shoulder surfing. However, users can reveal keys temporarily using the visibility toggle, so ensure the dashboard is not used in public or recorded settings.

### Authentication

The current dashboard implementation does not include authentication, assuming it runs locally on the user's machine. If you deploy the dashboard to a network-accessible server, you must add authentication to prevent unauthorized access to API keys. The template includes Manus OAuth integration that can be enabled for this purpose.

Consider implementing role-based access control if multiple users need access to the dashboard. Separate read-only and administrative roles to limit who can modify API keys. Implement audit logging to track configuration changes for security and compliance purposes.

### Network Security

When deploying the dashboard to a server, use HTTPS to encrypt all traffic between the browser and server. This prevents API keys from being intercepted if they are transmitted during configuration updates. Implement CORS policies to restrict which domains can access the API. Use security headers like Content-Security-Policy to prevent XSS attacks.

For local development, the dashboard runs on HTTP, which is acceptable since traffic does not leave the machine. However, be aware that other processes on the same machine could potentially intercept this traffic.

## Troubleshooting Development Issues

### TypeScript Errors

If you encounter TypeScript errors, first ensure all dependencies are installed with `pnpm install`. Check that your IDE is using the workspace TypeScript version rather than a global version. Run `pnpm tsc` to see all type errors at once. Common issues include missing type definitions, which can be resolved by installing the appropriate `@types/*` package, and type mismatches between client and server, which indicate the tRPC types need to be regenerated.

### Module Resolution Issues

Module resolution problems often manifest as "Cannot find module" errors. Verify that the file exists at the specified path and has the correct extension. Check that path aliases in `tsconfig.json` match your import statements. Restart the development server after making changes to configuration files. Clear the Vite cache by deleting the `node_modules/.vite` directory if stale modules are cached.

### Build Failures

Build failures can have various causes. Check the console output for specific error messages. Ensure all TypeScript errors are resolved before building. Verify that all dependencies are installed and compatible. Check for circular dependencies, which can cause build tools to fail. Increase Node.js memory if you encounter heap out-of-memory errors during large builds.

## Contributing

### Code Style

The project follows standard TypeScript and React conventions. Use functional components with hooks rather than class components. Prefer const over let, and avoid var entirely. Use arrow functions for consistency. Format code with Prettier using the project's configuration. Follow the existing file organization patterns when adding new features.

### Pull Request Process

When contributing changes, fork the repository and create a feature branch. Make your changes with clear, descriptive commit messages. Ensure all tests pass and no TypeScript errors exist. Update documentation to reflect your changes. Submit a pull request with a detailed description of what changed and why. Be responsive to code review feedback and make requested changes promptly.

### Testing Requirements

While the current project does not include a comprehensive test suite, contributors should manually test all changes thoroughly. For new features, provide step-by-step testing instructions in the pull request description. Consider adding automated tests using Vitest for critical functionality. Test edge cases and error conditions, not just the happy path.

## Conclusion

The CCM Dashboard provides a solid foundation for visual model management with room for extension and customization. By understanding its architecture and following the patterns established in the codebase, developers can enhance the dashboard to meet their specific needs. Whether adding new providers, implementing advanced features, or integrating with other tools, the modular design and type-safe architecture make development straightforward and maintainable.

---

**Version**: 1.0  
**Last Updated**: November 2024  
**Author**: Manus AI
