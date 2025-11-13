# CCM Dashboard Analytics Guide

**Author:** Manus AI  
**Last Updated:** November 13, 2025

## Overview

The CCM Dashboard Analytics system provides comprehensive insights into your model usage patterns, helping you optimize provider selection and reduce costs. The analytics engine automatically tracks every model switch, measures session durations, estimates costs, and generates actionable recommendations based on your actual usage data.

## Features

The analytics dashboard delivers four key categories of insights that work together to give you complete visibility into your AI model usage patterns.

### Usage Tracking

The system automatically records every model switch you make, whether through the dashboard interface or the command-line tools. Each switch event captures the source provider, destination provider, exact timestamp, and whether the switch was successfully applied to your environment. This creates a complete audit trail of your model selection decisions over time.

Session tracking runs continuously in the background, measuring how long each model configuration remains active. When you switch from one provider to another, the system automatically closes the previous session and starts a new one, calculating the exact duration you spent using each model. This data forms the foundation for all usage analytics and cost estimates.

### Cost Estimation

The analytics engine maintains a comprehensive database of pricing information for all supported AI providers. Cost estimates are calculated using a conservative formula that assumes an average token generation rate of one thousand tokens per minute of active usage. While actual token consumption varies based on your specific tasks, this approach provides a reasonable baseline for comparing provider costs.

The cost comparison view displays estimated monthly expenses for each provider you've used, allowing you to identify which models are driving your AI spending. The system breaks down costs by provider and visualizes the data through interactive charts, making it easy to spot opportunities for cost optimization.

### Visual Analytics

The analytics dashboard presents your data through multiple visualization formats designed to reveal different aspects of your usage patterns.

**Usage Distribution Pie Chart** shows the percentage of time spent on each provider, making it immediately obvious which models dominate your workflow. The chart uses distinct colors for each provider and displays both the provider name and total hours in the labels.

**Cost Comparison Bar Chart** visualizes estimated costs across all providers you've used, with bar heights representing dollar amounts. This view makes it easy to identify expensive providers at a glance and compare relative costs between different options.

**Switch History Timeline** displays your recent model switches in chronological order, showing the transition path (from provider → to provider), exact timestamps, application status, and the method used (dashboard or CLI). This timeline helps you understand your switching patterns and identify frequently-used provider combinations.

### Optimization Recommendations

The recommendation engine analyzes your usage data and generates personalized suggestions to improve your workflow and reduce costs. The system applies multiple heuristics to identify optimization opportunities.

**High-Cost Usage Detection** identifies cases where you're spending significant time on expensive models like Claude Opus. When the system detects extended usage of premium providers, it calculates potential savings from switching a portion of your workload to more cost-effective alternatives like Claude Sonnet or DeepSeek.

**Underutilized Provider Alerts** notify you when highly cost-effective providers like DeepSeek receive minimal usage despite offering strong capabilities. These recommendations help you discover cheaper alternatives you might not be fully leveraging.

**Cost Distribution Analysis** examines which providers account for the largest share of your estimated spending. If a single provider dominates your costs, the system suggests mixing in cheaper alternatives for routine tasks while reserving premium models for complex work.

Each recommendation includes a clear title, detailed description, impact level (high, medium, or low), and estimated monthly savings when applicable. Recommendations are sorted by potential impact, ensuring you see the most valuable suggestions first.

## Data Model

The analytics system uses three primary database tables to track and analyze your usage patterns.

### Switch Events Table

Every model switch creates a new record in the switch events table, capturing comprehensive metadata about the transition.

| Field | Type | Description |
|-------|------|-------------|
| id | Integer | Unique identifier for the switch event |
| timestamp | DateTime | When the switch was initiated |
| fromProvider | String | Source provider (null for first switch) |
| toProvider | String | Destination provider |
| fromModel | String | Source model identifier |
| toModel | String | Destination model identifier |
| switchMethod | Enum | How the switch was performed (dashboard or cli) |
| applied | Boolean | Whether the switch was applied via `ccm apply` |
| appliedAt | DateTime | When the switch was applied (null if pending) |
| createdAt | DateTime | Record creation timestamp |

The `applied` field distinguishes between switches that were merely configured in the dashboard versus those that were actually activated in your shell environment. This distinction is important because a switch isn't truly active until you run `ccm apply` to update your environment variables.

### Usage Sessions Table

Usage sessions track continuous periods where a specific model configuration was active in your environment.

| Field | Type | Description |
|-------|------|-------------|
| id | Integer | Unique identifier for the session |
| provider | String | Active provider during this session |
| model | String | Active model identifier |
| startTime | DateTime | When the session began |
| endTime | DateTime | When the session ended (null if ongoing) |
| duration | Integer | Session length in seconds |
| switchEventId | Integer | Associated switch event (if applicable) |
| createdAt | DateTime | Record creation timestamp |

The system automatically ends the current session whenever you switch to a different model, calculating the duration by subtracting the start time from the end time. Ongoing sessions have a null `endTime` value and are automatically closed when the next switch occurs.

### Provider Metadata Table

Provider metadata stores pricing, performance, and reliability information for all supported AI providers.

| Field | Type | Description |
|-------|------|-------------|
| provider | String | Provider identifier (primary key) |
| displayName | String | Human-readable provider name |
| costPer1MTokens | Integer | Cost in cents per million tokens |
| avgResponseTime | Integer | Average response time in milliseconds |
| reliability | Integer | Reliability score from zero to one hundred |
| lastUpdated | DateTime | When this metadata was last updated |

Cost values are stored in cents to avoid floating-point precision issues. The reliability score provides a subjective measure of each provider's uptime and consistency, though this metric is currently set manually rather than calculated from actual performance data.

## Using the Analytics Dashboard

Access the analytics dashboard by clicking the **Analytics** button in the main dashboard header, or navigate directly to `/analytics` in your browser.

### Summary Metrics

Four key metrics appear at the top of the analytics page, providing an at-a-glance view of your usage patterns over the past thirty days.

**Total Switches** counts how many times you've changed model providers, indicating how frequently you experiment with different options or adjust your configuration for specific tasks.

**Most Used Provider** identifies which model you've spent the most time with, based on total session duration. This metric helps you understand your primary go-to model.

**Average Session Duration** calculates the mean time you spend on each model before switching to another. Longer sessions suggest you're finding models that work well for extended tasks, while shorter sessions might indicate frequent experimentation.

**Estimated Monthly Cost** sums up the projected spending across all providers based on your usage patterns. This estimate assumes your usage remains consistent throughout the month and applies the token generation rate formula to calculate costs.

### Filtering and Time Ranges

The analytics dashboard currently displays data for the past thirty days. Future versions will support custom date ranges and filtering by specific providers or time periods.

### Exporting Data

While the current version includes an **Export Data** button in the header, the export functionality is not yet implemented. This feature is planned for a future release and will support exporting analytics data in CSV and JSON formats for external analysis.

## Cost Calculation Methodology

Understanding how the system calculates cost estimates helps you interpret the numbers and make informed decisions about provider selection.

### Token Estimation Formula

The analytics engine estimates token consumption using the following formula:

```
Estimated Tokens = (Session Duration in Minutes) × 1000 tokens/minute
```

This assumes a steady token generation rate of one thousand tokens per minute, which represents a moderate usage pattern. Actual token consumption varies significantly based on factors like prompt complexity, response length, and the specific tasks you're performing.

For example, a thirty-minute session would generate an estimated thirty thousand tokens. If you're using Claude Sonnet at three dollars per million tokens, the estimated cost would be:

```
Cost = (30,000 tokens / 1,000,000) × $3.00 = $0.09
```

### Pricing Data Sources

Provider pricing information is stored in the provider metadata table and reflects publicly available pricing as of November 2025. The system uses the following cost structure:

| Provider | Cost per 1M Tokens | Notes |
|----------|-------------------|-------|
| Claude Opus | $15.00 | Most capable model, highest cost |
| Claude Sonnet | $3.00 | Balanced performance and cost |
| Claude Haiku | $0.25 | Fastest and most economical |
| DeepSeek | $0.14 | Highly cost-effective for coding |
| KIMI | $0.50 | Optimized for long context |
| Qwen | $0.40 | Alibaba's flagship model |
| GLM | $0.30 | Advanced Chinese language support |
| MiniMax | $0.45 | Multimodal capabilities |
| Seed | $0.35 | Optimized for coding tasks |
| LongCat | $0.38 | Fast thinking model |
| KAT | $0.42 | StreamLake service |

These prices represent input token costs and may differ from output token pricing. Always verify current pricing with each provider before making cost-critical decisions.

### Limitations and Accuracy

Cost estimates should be treated as approximations rather than exact predictions. Several factors can cause actual costs to differ from estimates:

**Variable Token Consumption:** The one thousand tokens per minute assumption is a rough average. Complex coding tasks might generate more tokens, while simple queries generate fewer.

**Input vs Output Pricing:** Many providers charge different rates for input tokens (your prompts) versus output tokens (the model's responses). The current system uses a single blended rate per provider.

**Caching and Optimization:** Some providers offer caching mechanisms that reduce costs for repeated queries. These optimizations aren't reflected in the estimates.

**Batch vs Real-Time:** Providers may offer discounted batch processing rates that differ from real-time API pricing.

Despite these limitations, the estimates provide valuable relative comparisons between providers and help identify cost optimization opportunities.

## Optimization Strategies

The analytics system generates automated recommendations, but you can also apply manual optimization strategies based on your usage data.

### Task-Based Provider Selection

Different AI models excel at different types of tasks. By analyzing your usage patterns, you can develop a task-based provider selection strategy that balances cost and capability.

**Complex Reasoning Tasks** benefit from Claude Opus's advanced capabilities. Use this premium model for architectural decisions, complex debugging, and tasks requiring deep understanding.

**Routine Coding Work** runs efficiently on DeepSeek or Claude Sonnet. These models offer strong coding capabilities at a fraction of Opus's cost, making them ideal for everyday development tasks.

**Quick Queries and Iterations** work well with Claude Haiku or other fast, economical models. When you need rapid feedback or are iterating on simple changes, these models provide excellent value.

**Long Context Processing** suits KIMI's specialized architecture. If you're working with large codebases or extensive documentation, KIMI's long context window justifies its moderate cost.

### Switching Patterns

The switch history timeline reveals your model switching patterns, which can inform optimization strategies.

**Frequent Switching** between expensive and cheap models suggests you're already optimizing costs by using premium models only when necessary. This pattern is generally efficient.

**Prolonged Premium Usage** indicates opportunities to reduce costs by switching to cheaper alternatives for portions of your work. Review your session durations and consider whether all that time truly requires premium capabilities.

**Underutilized Providers** appear rarely or never in your history despite offering good value. Experiment with these providers to determine if they can handle some of your workload at lower cost.

### Monitoring and Adjustment

Effective cost optimization requires ongoing monitoring and adjustment. Review your analytics dashboard weekly to identify trends and opportunities.

**Track Cost Trends** over time to see if your optimization efforts are working. If estimated monthly costs are increasing, investigate which providers are driving the growth.

**Experiment with Alternatives** when you notice high costs on a particular provider. Try switching to a cheaper option for similar tasks and compare the results.

**Set Cost Budgets** based on your analytics data. If you're consistently spending more than expected, establish provider-specific budgets and track your progress toward staying within them.

## Technical Implementation

The analytics system integrates seamlessly with the existing CCM Dashboard architecture, adding minimal overhead while providing comprehensive tracking.

### Automatic Event Recording

Analytics tracking happens automatically whenever you use the dashboard to switch models. The `writeSwitchState` function in the switch service calls the analytics service to record each switch event:

```typescript
const switchEventId = await recordSwitchEvent({
  timestamp: new Date(),
  fromProvider,
  toProvider,
  fromModel,
  toModel,
  switchMethod: 'dashboard',
  applied: 0,
  appliedAt: null,
});
```

The function also ends any ongoing usage sessions and starts a new session for the selected provider:

```typescript
await endOngoingSessions();
await startUsageSession(provider, config.ANTHROPIC_MODEL, switchEventId);
```

This ensures session tracking remains accurate even if you switch models multiple times in quick succession.

### CLI Integration

The analytics system currently tracks switches made through the dashboard interface. Command-line switches made directly via the `ccm` tool are not automatically recorded in the analytics database. Future versions will add CLI integration to capture all switches regardless of method.

### Data Aggregation

The analytics API provides several aggregation endpoints that power the dashboard visualizations:

**Usage Statistics** (`/api/trpc/analytics.stats`) returns switch counts and session statistics grouped by provider for a specified time range.

**Daily Usage** (`/api/trpc/analytics.daily`) breaks down usage by date and provider, enabling time-series analysis and trend identification.

**Cost Estimates** (`/api/trpc/analytics.costs`) calculates estimated costs for each provider based on session durations and pricing metadata.

**Recommendations** (`/api/trpc/analytics.recommendations`) applies heuristics to your usage data and generates optimization suggestions.

All endpoints support a `daysBack` parameter to control the analysis time window, defaulting to thirty days.

### Performance Considerations

The analytics system uses database indexes on frequently-queried columns to maintain fast response times. The `timestamp` and `startTime` columns in the switch events and usage sessions tables are indexed to accelerate date range queries.

Aggregation queries use SQL `GROUP BY` clauses to perform calculations in the database rather than in application code, minimizing data transfer and improving performance.

The dashboard loads all analytics data in parallel using tRPC's query hooks, ensuring the page renders quickly even when fetching multiple datasets.

## Future Enhancements

Several planned enhancements will expand the analytics system's capabilities in future releases.

### Real-Time Tracking

Implement background tracking that monitors your active model configuration and automatically records session data without requiring manual switches. This would provide more accurate usage measurements and capture sessions that don't end with an explicit model switch.

### Custom Time Ranges

Add date range selectors to the analytics dashboard, allowing you to analyze specific time periods rather than being limited to the past thirty days. This would enable month-over-month comparisons and long-term trend analysis.

### Data Export

Complete the implementation of the export functionality, supporting CSV and JSON formats. Exported data would include all switch events, usage sessions, and calculated metrics, enabling external analysis in tools like Excel or Python.

### Provider Performance Metrics

Track actual response times and error rates for each provider, replacing the current static reliability scores with real performance data. This would help you identify providers that consistently deliver fast, reliable results.

### Budget Alerts

Implement cost budget tracking with configurable alerts that notify you when your estimated spending approaches or exceeds defined thresholds. Alerts could be delivered via email or in-dashboard notifications.

### Advanced Recommendations

Enhance the recommendation engine with machine learning models that identify complex usage patterns and generate more sophisticated optimization suggestions. The system could learn which providers work best for specific types of tasks based on your switching behavior.

### Team Analytics

For teams using the CCM Dashboard, add aggregated analytics that show usage patterns across multiple users. Team administrators could identify which models are most popular, track total team spending, and optimize shared API key usage.

## Troubleshooting

Common issues and their solutions when working with the analytics system.

### No Analytics Data Appearing

If the analytics dashboard shows empty charts and zero metrics, verify that you've made at least one model switch through the dashboard interface. The system only tracks switches made via the dashboard, not direct CLI usage
