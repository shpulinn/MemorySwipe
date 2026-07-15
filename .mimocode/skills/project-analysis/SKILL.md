---
name: project-analysis
description: Systematically analyze a project's architecture, tech stack, and structure by reading configuration files and key source files
---

# Project Analysis Skill

Perform a structured analysis of any software project to understand its architecture, technologies, and key components.

## Procedure

1. **Read root directory** - List all files and folders to understand project type
2. **Read configuration files** - Analyze package manifests, build configs, and settings
3. **Map directory structure** - Explore src/lib folders to understand organization
4. **Read key source files** - Examine entry points, routers, and core modules
5. **Identify patterns** - Note architectural patterns (MVC, feature-based, etc.)
6. **Summarize findings** - Produce a clear overview of the project

## Input

- `project_path`: Path to the project root directory

## Output

A structured summary covering:
- **Project type** (web, mobile, desktop, library)
- **Tech stack** (languages, frameworks, key dependencies)
- **Architecture** (folder structure, patterns, conventions)
- **Key components** (main modules, entry points, services)
- **Build/deploy** (build tools, CI/CD, deployment targets)

## Example Usage

```
Analyze the project at C:\PhotosApp\memory_swipe
```

## Tool Sequence

1. `read` project root directory
2. `read` package.json/pubspec.yaml/requirements.txt (depending on project type)
3. `read` README.md if exists
4. `read` src/lib directory structure
5. `read` key configuration files
6. `glob` for important file types (*.dart, *.js, *.py, etc.)
7. `read` entry points and core modules
8. Produce analysis summary

## Notes

- Adapt file reads based on detected project type
- Focus on architectural decisions, not line-by-line code review
- Note any unusual patterns or potential issues
- Keep summary concise but comprehensive