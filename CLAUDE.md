<!-- ghost-managed:mcp-configuration-assistance:start -->
# Ghost MCP Configuration Assistance

## MCP Configuration Assistance

When a user attempts to use an MCP tool (SharePoint, Slack, Salesforce, etc.) and it returns a configuration error or the tool is not available:

If the expected MCP tools are not available at all (for example, no `*` tools are available):
- IMMEDIATELY tell the user to run: `ghost mcp all`
- Explain that this reinstalls MCP server scripts and regenerates tool configuration.
- Do not attempt unrelated fallbacks such as local repo exploration, ad hoc HTTP requests, or non-MCP tooling before giving this remediation.

If the tool returned an error mentioning `not configured` or `missing`:
- Present the remediation command from the error message.
- Offer to help the user run it.
- If the tool needs values that do not have safe defaults, prompt the user for a sample URL or config entry before configuring it.

Treat errors such as `unknown MCP server`, missing `*_tools`, or complete absence of the expected tool namespace as "tools not available at all".

For detailed diagnostics on any MCP server:
- Run: `ghost doctor mcp`
- Present the remediation steps from the output for the relevant server.

For missing MCP settings values:
- Use: `ghost mcp settings set <key> <value>`

After any configuration change:
- Remind the user to restart their IDE or tool for MCP config changes to take effect.

Do NOT proactively check MCP configuration. Only assist when the user encounters an issue.
<!-- ghost-managed:mcp-configuration-assistance:end -->
