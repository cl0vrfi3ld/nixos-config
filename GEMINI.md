# NixOS Configuration for Framework 16
## 1. Project Overview

### Purpose
A comprehensive, modular NixOS system configuration for a Framework 16 laptop, designed to provide a reproducible, customizable, and efficient development environment.
### Key Technologies
- **Operating System**: NixOS (Linux)
- **Package Management**: Nix Package Manager
- **Configuration Management**: Nix Flakes
- **Secrets Management**: SOPS (Secrets OPerationS)
- **Infrastructure as Code**: Declarative system configuration

### Hardware Configuration
- **Device**: Framework 16 Laptop
- **Processor**: AMD 7040 Series
- **GPU**: AMD Radeon RX 7700S
- **Operating System Channel**: NixOS Unstable

## 2. Project Structure

### Main Directories
- `config/`: Modular system configuration files
- `secrets/`: Encrypted secrets management
- `cachix/`: Nix binary cache configurations

### Configuration Modules
Each `.nix` file in the `config/` directory represents a specific system aspect:

#### Networking
- `networking.nix`: Core network configuration
- `iwd.nix`: Internet wireless daemon setup
- `tailscale.nix`: Tailscale VPN configuration
- `mullvad.nix`: Mullvad VPN settings
- `proxies.nix`: Network proxy configurations

#### System Management
- `pkgs.nix`: System-wide package installations
- `flatpak.nix`: Declarative Flatpak management
- `optimisations.nix`: System performance tuning
- `nh.nix`: Nix helper CLI configuration

#### Development & Platforms
- `android.nix`: Android development environment
- `waydroid.nix`: Android container support
- `steam.nix`: Gaming platform configuration

#### User Experience
- `fonts.nix`: System font configurations
- `plymouth.nix`: Boot screen settings
- `dualsense.nix`: DualSense device configuration

#### Specialized Tools
- `ai.nix`: Locally hosted AI configurations
- `sops.nix`: Secrets encryption and management

## 3. Getting Started

### Prerequisites
- NixOS (Unstable channel)
- Git
- Nix package manager with Flakes support

### Installation
1. Clone the repository
   ```bash
   git clone https://github.com/your-username/nixos-config.git
   cd nixos-config
   ```

2. Build and switch to the configuration
   ```bash
   sudo nixos-rebuild switch --flake .#theseus
   ```

## 4. Development Workflow

### Configuration Management
- Modify specific `.nix` files in the `config/` directory for targeted changes
- Use SOPS for managing encrypted secrets
- Leverage Nix Flakes for reproducible builds

### Testing Changes
1. Validate configuration
   ```bash
   nix flake check
   ```

2. Build without switching
   ```bash
   sudo nixos-rebuild build --flake .#theseus
   ```

3. Switch to new configuration
   ```bash
   sudo nixos-rebuild switch --flake .#theseus
   ```

### Secrets Management
- Utilize SOPS for encrypting sensitive information
- Refer to `secrets/README.md` for detailed guidance

## 5. Common Tasks

### Adding Packages
1. Edit `config/pkgs.nix`
2. Add package to `environment.systemPackages`

### Managing Flatpaks
- Configure in `config/flatpak.nix`
- Use declarative Flatpak management

### VPN Configuration
- Configure Tailscale in `config/tailscale.nix`
- Set up wireless networks in `config/iwd.nix`

## 6. Troubleshooting

### Common Issues
- Ensure Nix Flakes are enabled
- Verify hardware compatibility
- Check configuration syntax

### Debugging
- Use `nixos-rebuild build --flake .#theseus --show-trace` for detailed logs
- Consult NixOS documentation for specific error resolution

## 7. References
- [NixOS Documentation](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes Guide](https://nixos.wiki/wiki/Flakes)
- [sops-nix Repository](https://github.com/Mic92/sops-nix)
- [Framework 16 NixOS Support](https://github.com/NixOS/nixos-hardware)

## 8. Contributing
- Fork the repository
- Create a feature branch
- Submit pull requests with clear descriptions

**Note:** Always test configurations thoroughly before system-wide application.

## 9. Deployment Notes
- This configuration is specifically tailored for a Framework 16 laptop
- Modifications may be required for different hardware
- Follow NixOS best practices for system updates and maintenance
