# Musical Palm Tree - Comprehensive Setup and Recovery Documentation

This document provides a guide for setting up and maintaining the Musical Palm Tree project.

## 1. Installation Guide

### 1.1. Running the Setup Script (`setup.sh`)
The `setup.sh` script is designed for initial setup. It includes enhanced logging and error handling.

**Usage:**
```bash
bash setup.sh
```

**Non-Interactive Mode:**
```bash
NONINTERACTIVE=1 bash setup.sh
```

### 1.2. Termux-Specific Installation (`termux/install.sh`)
Handles the core installation within the Termux environment.

**Usage:**
```bash
bash termux/install.sh
```

## 2. Recovery and Troubleshooting

*   **Check Logs:** Check log files in `$HOME/.logs/musical-palm-tree/`.
*   **GitHub Copilot:** Authenticate by running `:Copilot setup` in Neovim.
*   **Cron Jobs:** Ensure `crond` is running.

## 3. Quick Reference

*   **Run main setup:** `bash setup.sh`
*   **Start webhook server:** `python3 $REPO_DIR/termux/webhook_server.py &`
