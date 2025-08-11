# Local Lucee Development Environment

A comprehensive, automated setup for local Lucee CFML development with HTTPS support, file watching, multi-client site management, and local debugger.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/rcowles3/local_lucee_public.git
cd local_lucee_public

# Run the installation
sudo ./install.sh
```

That's it! The script will automatically:
- ✅ Install and configure Lucee Server
- ✅ Set up HTTPS with local certificates
- ✅ Configure VS Code workspace and extensions
- ✅ Create development aliases and tools
- ✅ Open your browser to the local dashboard

## 📋 Prerequisites

The install script checks for these requirements automatically:

- **macOS** (tested on macOS 13+)
- **Homebrew** - [Install here](https://brew.sh/)
- **Docker** - `brew install --cask docker`
- **VS Code** - `brew install --cask visual-studio-code`
- **Git** - `brew install git`
- **mkcert** - `brew install mkcert`
- **NSS** - `brew install nss`
- **fswatch** - `brew install fswatch`
- **pandoc** - `brew install pandoc`

## 🏗️ What Gets Installed

### Core Components
- **Lucee Server 5.4.6.9** running on Tomcat
- **Local HTTPS certificates** for `*.localhost` domains
- **Multi-client development workspace** at `~/workspace/lab-1-devel/`
- **VS Code configuration** with CFML extensions and team settings

### Development Tools
- **File watcher** with automatic cache clearing
- **Local dashboard** with documentation
- **Site management tools** for adding new clients
- **Convenient aliases** for common tasks

### Network Configuration
- **HTTP**: `localhost:8888`
- **HTTPS**: `localhost:8443` and `*.localhost:8443`
- **Debug Port**: `10000` (for VS Code debugging)

## 🛠️ Daily Usage

### Starting Development
```bash
# Start Lucee server
lucee-start

# Start file watching (automatic cache clearing)
lucee-watch-bg

# Check status
lucee-watch-status
```

### Managing Sites
```bash
# Add a new client site
lucee-add-site

# Restart server
lucee-restart

# View server logs
lucee-catalina-out
```

### File Watching
The file watcher automatically clears Lucee caches when you edit:
- `.cfm` and `.cfc` files → Template cache cleared
- `Application.cfc` → Application cache cleared
- `.css` files → Logged for reference

```bash
lucee-watch          # Run in foreground (see live output)
lucee-watch-bg       # Run in background with logging
lucee-watch-log      # View live log output
lucee-watch-stop     # Stop background process
lucee-watch-status   # Check if running
```

### VS Code Integration
- **Automatic workspace** opens with proper CFML support
- **Debugger configured** for Lucee development
- **Team extensions** installed automatically
- **Consistent settings** across your development team

## 📁 Project Structure

```
~/workspace/lab-1-devel/           # Main development directory
├── client1-devel.localhost/       # Individual client sites
├── client2-portal-devel.localhost/
└── client3-workspace-devel.localhost/

/opt/lucee_server/                 # Lucee installation
├── lucee/                         # Lucee server files
├── tools/                         # Management scripts
│   ├── lucee/                     # Server control scripts
│   └── sites/                     # Site management tools
└── local_lucee.code-workspace     # VS Code workspace

~/.lucee/                          # User configuration
├── keystores/                     # HTTPS certificates
├── fswatch.log                    # File watcher logs
└── tool_aliases                   # Shell aliases
```

## 🌐 Site URLs

Your local sites will be accessible at:
- `https://client-devel.localhost:8443/`
- `https://client-portal-devel.localhost:8443/`
- `https://client-workspace-devel.localhost:8443/`

The HTTPS certificates are automatically trusted, so no browser warnings!

## 🔧 Configuration

### Adding Team Members
New developers can use the same setup:

1. Clone this repository
2. Run `./install.sh`
3. Use `source ~/.lucee/tool_aliases` in their shell profile

### VS Code Team Settings
The installation automatically configures VS Code with:
- CFML language support and syntax highlighting
- Consistent formatting and tab settings
- Recommended extensions for CFML development
- File associations for `.cfm`, `.cfc`, `.cfml`
- Debugging configuration for Lucee

### Custom Client Configurations
Each client can have custom rewrite rules in their `WEB-INF/rewrite.config`:
- URL rewriting for clean URLs
- Legacy system compatibility
- Client-specific routing logic

## 🚨 Troubleshooting

### Port Conflicts
```bash
# Kill processes using Lucee ports
lucee-killports

# Check what's running on ports
lsof -i :8888
lsof -i :8443
```

### Certificate Issues
```bash
# Reinstall certificates
lucee-install-cert

# Verify mkcert is working
mkcert -CAROOT
```

### File Watching Not Working
```bash
# Check fswatch status
lucee-watch-status

# View logs
lucee-watch-log

# Restart file watching
lucee-watch-stop
lucee-watch-bg
```

### Lucee Admin Access
- **Server Admin**: `https://localhost:8443/lucee/admin/server.cfm`
- **Web Admin**: `https://[site-url]/lucee/admin/web.cfm`

### Cache Issues
```bash
# Manual cache clearing
curl "https://localhost:8443/lucee/admin/server.cfm?action=services.cache.clear"

# Restart Lucee completely
lucee-restart
```

## 🔍 Development Workflow

1. **Start your day**:
   ```bash
   lucee-start && lucee-watch-bg
   ```

2. **Open VS Code**: The workspace opens automatically with all client sites

3. **Develop**: Edit CFML files - caches clear automatically

4. **Add new sites**: Use `lucee-add-site` for new clients

5. **Debug**: Use VS Code's built-in debugger (already configured)

6. **End of day**:
   ```bash
   lucee-watch-stop && lucee-stop
   ```

## 🤝 Contributing

To add features or fix bugs:

1. Fork this repository
2. Create a feature branch
3. Test with a fresh install
4. Submit a pull request

### Development Notes
- All scripts use `/bin/bash` for compatibility
- Global variables are defined in `install.sh`
- Certificate handling is in `cert.sh`
- Lucee patching is in `patches.sh`
- VS Code setup is in `setup_vscode.sh`

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋 Support

For questions or issues:
1. Check the troubleshooting section above
2. Review the installation logs
3. Open an issue on GitHub with:
   - Your macOS version
   - Error messages from logs
   - Steps to reproduce the problem

---

**Happy CFML Development!** 🎉