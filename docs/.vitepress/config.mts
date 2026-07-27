import { defineConfig } from "vitepress";

export default defineConfig({
  title: "PPTB Skills",
  base: "/PPTB-skills/",
  description:
    "A curated library of reusable development skills, patterns, and best practices for building plugins and tools within the Power Platform Toolbox (PPTB) ecosystem.",
  head: [["link", { rel: "icon", href: "/PPTB-skills/favicon.ico" }]],
  themeConfig: {
    logo: "/app-icon.svg",
    sidebar: [
      {
        text: "PPTB Tools",
        link: "/pptb-tools/",
        collapsed: true,
        items: [
          {
            text: "Getting Started",
            collapsed: true,
            items: [
              {
                text: "Introduction",
                link: "/pptb-tools/getting-started/",
                collapsed: true,
                items: [
                  {
                    text: "Guides",
                    link: "/pptb-tools/getting-started/guides/",
                  },
                  {
                    text: "Resources",
                    link: "/pptb-tools/getting-started/resources/",
                  },
                ],
              },
              {
                text: "Quick Start",
                link: "/pptb-tools/getting-started/quick-start/",
              },
              {
                text: "AI Assistants",
                link: "/pptb-tools/getting-started/ai-assistants/",
              },
              {
                text: "Tool Installation",
                link: "/pptb-tools/getting-started/tool-installation/",
              },
              {
                text: "Authentication",
                link: "/pptb-tools/getting-started/authentication/",
              },
              {
                text: "Access to Data",
                link: "/pptb-tools/getting-started/access-to-data/",
              },
            ],
          },
          {
            text: "Tool Development",
            collapsed: true,
            items: [
              {
                text: "Overview",
                link: "/pptb-tools/tool-development/",
              },
              {
                text: "Package Manifest",
                link: "/pptb-tools/tool-development/package-manifest/",
              },
              {
                text: "API Reference",
                link: "/pptb-tools/tool-development/api-reference/",
              },
              {
                text: "ToolBox API",
                link: "/pptb-tools/tool-development/toolbox-api/",
              },
              {
                text: "Dataverse API",
                link: "/pptb-tools/tool-development/dataverse-api/",
              },
              {
                text: "PowerPlatform API",
                link: "/pptb-tools/tool-development/powerplatform-api/",
              },
              {
                text: "Events API",
                link: "/pptb-tools/tool-development/events-api/",
              },
              {
                text: "Settings API",
                link: "/pptb-tools/tool-development/settings-api/",
              },
              {
                text: "File System API",
                link: "/pptb-tools/tool-development/file-system-api/",
              },
              {
                text: "Error Handling",
                link: "/pptb-tools/tool-development/error-handling/",
              },
              {
                text: "CSP Configuration",
                link: "/pptb-tools/tool-development/csp-configuration/",
              },
              {
                text: "Local Validation",
                link: "/pptb-tools/tool-development/local-validation/",
              },
              {
                text: "Inter-Tool Invocation",
                link: "/pptb-tools/tool-development/inter-tool-invocation/",
              },
              {
                text: "Agent Integration",
                link: "/pptb-tools/tool-development/agent-integration/",
              },
              {
                text: "Publishing Tools",
                link: "/pptb-tools/tool-development/publishing-tools/",
              },
            ],
          },
          {
            text: "ToolBox Development",
            link: "/pptb-tools/toolbox-development/",
            collapsed: true,
            items: [
              {
                text: "Getting Started",
                link: "/pptb-tools/toolbox-development/getting-started/",
              },
              {
                text: "Architecture",
                link: "/pptb-tools/toolbox-development/architecture/",
              },
            ],
          },
          {
            text: "Contributing",
            collapsed: true,
            items: [
              {
                text: "Contribution Guide",
                link: "/pptb-tools/contributing/",
              },
              {
                text: "Code of Conduct",
                link: "/pptb-tools/contributing/code-of-conduct/",
              },
              {
                text: "Getting Started",
                link: "/pptb-tools/contributing/getting-started/",
              },
              {
                text: "How to Contribute",
                link: "/pptb-tools/contributing/how-to-contribute/",
              },
              {
                text: "Coding Standards",
                link: "/pptb-tools/contributing/coding-standards/",
              },
              {
                text: "Documentation",
                link: "/pptb-tools/contributing/documentation/",
              },
              {
                text: "Testing",
                link: "/pptb-tools/contributing/testing/",
              },
              {
                text: "Release Process",
                link: "/pptb-tools/contributing/release-process/",
              },
              {
                text: "PR Requirements Summary",
                link: "/pptb-tools/contributing/pr-requirements-summary/",
              },
              {
                text: "Community",
                link: "/pptb-tools/contributing/community/",
              },
              {
                text: "Recognition",
                link: "/pptb-tools/contributing/recognition/",
              },
              {
                text: "Next Steps",
                link: "/pptb-tools/contributing/next-steps/",
              },
            ],
          },
        ],
      },
      {
        text: "PPTB Skills Catalog",
        link: "/pptb-skills/",
        collapsed: true,
        items: [
          {
            text: "Tool Skills",
            link: "/pptb-skills/tool-skills/",
            collapsed: true,
            items: [
              {
                text: "create-pptb-tool",
                link: "/pptb-skills/tool-skills/create-pptb-tool/",
              },
              {
                text: "add-toolbox-api",
                link: "/pptb-skills/tool-skills/add-toolbox-api/",
              },
              {
                text: "add-dataverse-api",
                link: "/pptb-skills/tool-skills/add-dataverse-api/",
              },
              {
                text: "add-powerplatform-api",
                link: "/pptb-skills/tool-skills/add-powerplatform-api/",
              },
              {
                text: "configure-csp",
                link: "/pptb-skills/tool-skills/configure-csp/",
              },
              {
                text: "add-error-handling",
                link: "/pptb-skills/tool-skills/add-error-handling/",
              },
              {
                text: "validate-pptb-tool",
                link: "/pptb-skills/tool-skills/validate-pptb-tool/",
              },
              {
                text: "add-inter-tool-invocation",
                link: "/pptb-skills/tool-skills/add-inter-tool-invocation/",
              },
              {
                text: "add-agent-integration",
                link: "/pptb-skills/tool-skills/add-agent-integration/",
              },
              {
                text: "publish-pptb-tool",
                link: "/pptb-skills/tool-skills/publish-pptb-tool/",
              },
            ],
          },
          {
            text: "ToolBox Skills",
            link: "/pptb-skills/toolbox-skills/",
            collapsed: true,
            items: [
              {
                text: "setup-toolbox-dev-env",
                link: "/pptb-skills/toolbox-skills/setup-toolbox-dev-env/",
              },
              {
                text: "add-host-manager",
                link: "/pptb-skills/toolbox-skills/add-host-manager/",
              },
              {
                text: "package-toolbox",
                link: "/pptb-skills/toolbox-skills/package-toolbox/",
              },
            ],
          },
        ],
      },
      {
        text: "References",
        link: "/references/",
      },
    ],
  },
});
