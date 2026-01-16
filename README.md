# Agent Manager CLI

A Java CLI tool for managing AI agents from different sources for multiple AI Tools (Cursor, Claude, Copilot, etc.).

## Features

- **Multi-tool support**: Manage agents for Cursor, Claude, Copilot, and other AI tools
- **Git integration**: Pull agents from git repositories
- **Nested agent discovery**: Automatically discover agents in nested directory structures
- **Batch updates**: Update all agents from a source with a single command
- **Directory structure preservation**: Copy complete agent directory structures including supporting files

## Requirements

- **Java 8 or later** (Java 8 or Java 21 recommended)
- Maven 3.9+ (for building)

The project provides two modules:
- **agent-manager-java8**: Compatible with Java 8 and later
- **agent-manager-java21**: Optimized for Java 21 and later

The installation script automatically detects your Java version and installs the appropriate module.

## Building

### Build All Modules

```bash
mvn clean package
```

This builds both modules and creates:
- `agent-manager-java8/target/agent-manager-java8.jar`
- `agent-manager-java21/target/agent-manager-java21.jar`

### Build Specific Module

```bash
# Build Java 8 module only
mvn clean package -pl agent-manager-java8 -am

# Build Java 21 module only
mvn clean package -pl agent-manager-java21 -am
```

## Installation

### Windows

After building the project, run the installation script:

```batch
install.bat
```

This will:
1. Detect your Java version automatically
2. Build the appropriate module (Java 8 or Java 21)
3. Copy the JAR to `%USERPROFILE%\.agent-manager\agent-manager-java8.jar` or `agent-manager-java21.jar`
4. Create a wrapper script at `%USERPROFILE%\bin\agent-manager.bat` that uses the correct JAR
5. Optionally add `%USERPROFILE%\bin` to your PATH

After installation, you can use `agent-manager` command from anywhere:

```batch
agent-manager --version
agent-manager --help
```

**Note:** If you just added the PATH, restart your terminal for changes to take effect.

**Alternative:** If the installation script didn't add the PATH automatically, you can run:

```powershell
.\add-to-path.ps1
```

This will add `%USERPROFILE%\bin` to your PATH permanently.

### Manual Installation (Windows)

If you prefer to install manually:

1. Build the appropriate module for your Java version:
   - For Java 8-20: `mvn clean package -pl agent-manager-java8 -am`
   - For Java 21+: `mvn clean package -pl agent-manager-java21 -am`
2. Copy the JAR (`agent-manager-java8.jar` or `agent-manager-java21.jar`) to a permanent location (e.g., `%USERPROFILE%\.agent-manager\`)
3. Copy `agent-manager.bat` to a directory in your PATH (e.g., `%USERPROFILE%\bin\`)
4. The wrapper script will automatically detect your Java version and use the correct JAR

### Linux/macOS

For Linux/macOS, you can create a wrapper script that detects Java version:

```bash
#!/bin/bash
# Detect Java version and use appropriate JAR
JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1)

if [ "$JAVA_VERSION" -ge 21 ] 2>/dev/null; then
    JAR_NAME="agent-manager-java21.jar"
elif [ "$JAVA_VERSION" -ge 8 ] 2>/dev/null || [ "$JAVA_VERSION" = "1.8" ] 2>/dev/null; then
    JAR_NAME="agent-manager-java8.jar"
else
    echo "Error: Java 8 or later is required"
    exit 1
fi

java -jar ~/.agent-manager/$JAR_NAME "$@"
```

Save it as `agent-manager`, make it executable (`chmod +x agent-manager`), and add it to your PATH.

## Usage

### Basic Commands

After installation, you can use the `agent-manager` command directly:

```bash
# Show help
agent-manager --help

# Show version
agent-manager --version
```

Or if not installed, use the JAR directly:

```bash
# Show help (use the appropriate JAR for your Java version)
java -jar agent-manager-java8.jar --help
# or
java -jar agent-manager-java21.jar --help

# Show version
java -jar agent-manager-java8.jar --version
# or
java -jar agent-manager-java21.jar --version
```

### Managing Sources

```bash
# Add a new source repository
agent-manager add-source my-agents https://github.com/user/agents.git

# Add a source with a specific branch
agent-manager add-source my-agents https://github.com/user/agents.git -b develop

# List all sources
agent-manager list-sources

# List sources with details
agent-manager list-sources -v
```

### Discovering Agents

```bash
# Discover all agents in a source repository
agent-manager discover my-agents

# Discover agents for a specific tool only
agent-manager discover my-agents --tool cursor
```

### Updating Agents

```bash
# Update all agents from a source (batch update)
agent-manager update my-agents

# Update a single agent
agent-manager update cursor technologies/java
```

### Listing Agents

```bash
# List all agents
agent-manager list

# List agents for a specific tool
agent-manager list --tool cursor

# List agents with details
agent-manager list -v
```

### Agent Information

```bash
# Get detailed information about an agent
agent-manager info cursor technologies/java
```

### Uploading Agents

```bash
# Copy an agent to another directory
agent-manager upload cursor technologies/java ~/backup/agents
```

### Listing AI Tools

```bash
# List configured AI Tools
agent-manager list-tools

# List with details
agent-manager list-tools -v
```

## Configuration

The tool uses a JSON configuration file (`agent-manager.json`) located in your home directory or the current directory.

### Configuration Structure

```json
{
  "aiTools": [
    {
      "name": "cursor",
      "directory": "~/.cursor",
      "agentsDirectory": "agents",
      "toolFolders": [".github", ".cursor"],
      "supportedPatterns": ["*.md", "**/*"]
    }
  ],
  "sources": [
    {
      "id": "my-agents",
      "type": "git",
      "url": "https://github.com/user/agents.git",
      "branch": "main",
      "localPath": "~/.agent-manager/sources/my-agents"
    }
  ],
  "agents": [
    {
      "name": "technologies/java",
      "tool": "cursor",
      "source": "my-agents",
      "relativePath": "technologies/java",
      "toolFolderName": ".github",
      "sourcePath": "technologies/java/.github/agents",
      "copyEntireSource": true,
      "enabled": true
    }
  ]
}
```

### AI Tool Configuration

- `name`: The tool identifier (e.g., "cursor", "claude")
- `directory`: The tool's configuration directory (supports `~` for home directory)
- `agentsDirectory`: Name of the agents subdirectory
- `toolFolders`: List of folder names that indicate tool-specific content (e.g., ".github", ".cursor")
- `supportedPatterns`: File patterns to include

## Agent Discovery

The tool automatically discovers nested agents by scanning repositories for tool-specific folders (like `.github`, `.cursor`, `.claude`) that contain an `agents` directory.

### Example Repository Structure

```
repo-root/
├── technologies/
│   ├── java/
│   │   └── .github/
│   │       ├── agents/
│   │       │   └── java-expert.md
│   │       ├── instructions/
│   │       └── docs/
│   └── node/
│       └── .github/
│           ├── agents/
│           │   └── node-expert.md
│           └── examples/
└── use-cases/
    ├── planning/
    │   └── .github/
    │       └── agents/
    │           └── planner.md
    └── testing/
        └── .cursor/
            └── agents/
                └── tester.md
```

Running `discover my-agents` would find:
- `technologies/java` (from `.github`)
- `technologies/node` (from `.github`)
- `use-cases/planning` (from `.github`)
- `use-cases/testing` (from `.cursor`)

## Directory Structure

When updating agents, the entire directory structure is preserved:

- **Source**: `technologies/java/.github/` (all contents)
- **Destination**: `~/.cursor/technologies/java/.github/`

This includes:
- `agents/` directory with `.md` files
- `instructions/` directory
- `examples/` directory
- Any other files and directories

## Logs

Logs are stored in `~/.agent-manager/logs/agent-manager.log`.

Enable debug output by setting the `DEBUG` environment variable:

**Windows (CMD):**
```batch
set DEBUG=1
agent-manager list
```

**Windows (PowerShell):**
```powershell
$env:DEBUG=1
agent-manager list
```

**Linux/macOS:**
```bash
DEBUG=1 agent-manager list
```

## Module Differences

Both modules provide the same functionality, but are compiled for different Java versions:

- **agent-manager-java8**: 
  - Compatible with Java 8 and later
  - Uses Java 8 compatible syntax (no `var`, `Path.of()`, `List.of()`, etc.)
  - Recommended for environments with Java 8-20

- **agent-manager-java21**:
  - Requires Java 21 or later
  - Uses modern Java 21 features
  - Recommended for environments with Java 21+

The wrapper scripts (`agent-manager.bat` and `agent-manager.ps1`) automatically detect your Java version and use the appropriate JAR file.

## Project Structure

```
agent-manager-cli/
├── pom.xml                    # Parent POM (multi-module)
├── agent-manager-java8/       # Java 8 module
│   ├── pom.xml
│   └── src/
├── agent-manager-java21/      # Java 21 module
│   ├── pom.xml
│   └── src/
└── install.bat                # Installation script
```

## License

MIT License
