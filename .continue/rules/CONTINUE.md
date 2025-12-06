# Project Guide: Clover's NixOS Configuration

## 1. Project Overview
This is a comprehensive NixOS system configuration for a Framework 16 laptop, leveraging Nix's declarative and reproducible system management approach. The configuration provides a flexible, customizable setup for development, productivity, and personal computing.

### Key Technologies
- NixOS (Linux distribution)
- Nix Package Manager
- Flakes for dependency and configuration management
- SOPS for secrets management
- Various system and application configurations

## 2. Getting Started

### Prerequisites
- A Linux-compatible system (optimized for Framework 16)
- Nix package manager installed
- Git for cloning the repository

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/nixos-config.git
   cd nixos-config
   ```

2. Ensure you have Nix with Flakes support enabled

3. Build and switch to the configuration:
   ```bash
   sudo nixos-rebuild switch --flake .#theseus
   ```

### System Requirements
- Framework 16 laptop (AMD 7040 series)
- Compatible with NixOS unstable channel

## 3. Project Structure

### Key Directories
- `config/`: Modular NixOS configuration files
  #### Networking and Connectivity
  - `networking.nix`: Core network configuration (hostname, DNS, firewall)
  - `iwd.nix`: Internet wireless daemon configuration
  - `tailscale.nix`: Tailscale VPN configuration
  - `mullvad.nix`: Mullvad VPN configuration
  
  #### System and Package Management
  - `pkgs.nix`: System-wide package installations
  - `flatpak.nix`: Declarative Flatpak management
  
  #### Development and Platforms
  - `android.nix`: Android development environment setup
  - `waydroid.nix`: Android container support (Waydroid)
  - `steam.nix`: Gaming platform configuration
  
  #### User Experience and Aesthetics
  - `fonts.nix`: System font configurations
  - `plymouth.nix`: Boot screen and animation settings
  
  #### AI and Machine Learning
  - `ollama.nix`: Ollama AI model management and inference
  
  #### Security and Secrets
  - `sops.nix`: Secrets management with SOPS
  
  #### Performance
  - `optimisations.nix`: System performance tuning and optimizations

- `secrets/`: Encrypted secrets management
- `cachix/`: Nix binary cache configurations

### Configuration Files
- `flake.nix`: Primary Nix Flake configuration
- `configuration.nix`: Legacy NixOS configuration
- `.sops.yaml`: SOPS (Secrets OPerationS) configuration

## 4. Development Workflow

### Configuration Management
- Use `config/` directory for modular system configurations
- Modify specific `.nix` files for targeted changes
- Use SOPS for managing encrypted secrets

### Testing Changes
1. Validate configuration:
   ```bash
   nix flake check
   ```

2. Build without switching:
   ```bash
   sudo nixos-rebuild build --flake .#theseus
   ```

3. Switch to new configuration:
   ```bash
   sudo nixos-rebuild switch --flake .#theseus
   ```

### Secrets Management
- Use SOPS for encrypting and managing sensitive information
- Refer to `secrets/README.md` for specific guidance

## 5. Key Concepts

### Nix Flakes
- Provides reproducible, declarative system configurations
- Locks dependencies to specific versions
- Enables easy sharing and reproduction of system state

### Modular Configuration
- Each `.nix` file in `config/` represents a specific system aspect
- Allows for easy customization and maintenance

## 6. Common Tasks

### Adding New Packages
1. Edit `config/pkgs.nix`
2. Add package to `environment.systemPackages`

### Managing Flatpaks
- Configure in `config/flatpak.nix`
- Use declarative Flatpak management

### VPN and Networking
- Tailscale configured in `config/tailscale.nix`
- Wireless configuration in `config/iwd.nix`

## 7. Troubleshooting

### Common Issues
- Ensure Nix Flakes are enabled
- Check hardware compatibility
- Validate configuration syntax

### Debugging
- Use `nixos-rebuild build --flake .#theseus --show-trace` for detailed build logs
- Consult NixOS documentation for specific error resolution

## 8. References
- [NixOS Documentation](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [SOPS-NIKS Documentation](https://github.com/Mic92/sops-nix)

## 9. Contributing
- Fork the repository
- Create a feature branch
- Submit pull requests with clear descriptions

**Note:** Always test configurations thoroughly before applying system-wide changes.
