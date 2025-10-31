#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting cache cleanup and tools update...${NC}"

# Function to clear macOS cache and Trash
clear_cache() {
  echo -e "${GREEN}Clearing macOS caches and Trash...${NC}"
  rm -rf ~/Library/Caches/* ~/.Trash/* 2>/dev/null
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Cache and Trash cleared successfully.${NC}"
  else
    echo -e "${RED}Failed to clear cache or Trash.${NC}"
  fi
}

# Function to clean up Docker
cleanup_docker() {
  if command -v docker >/dev/null 2>&1; then
    echo -e "${GREEN}Cleaning up Docker containers, images, volumes, and networks...${NC}"

    docker rm -f $(docker ps -aq) 2>/dev/null || true
    docker rmi -f $(docker images -q) 2>/dev/null || true
    docker volume rm $(docker volume ls -q) 2>/dev/null || true
    docker network rm $(docker network ls -q | grep -vE 'bridge|host|none') 2>/dev/null || true
    docker system prune -af --volumes

    echo -e "${GREEN}Docker cleanup completed.${NC}"
  else
    echo -e "${YELLOW}Docker not found, skipping Docker cleanup.${NC}"
  fi
}

# Function to update Homebrew and related tools
update_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    echo -e "${GREEN}Updating Homebrew and installed packages...${NC}"
    rustup update
    brew update && brew upgrade
    brew upgrade --cask
    brew cleanup
    echo -e "${GREEN}Homebrew update completed.${NC}"
  else
    echo -e "${YELLOW}Homebrew not found, skipping Homebrew update.${NC}"
  fi
}

# Function to update Oh-My-Zsh
update_omz() {
  if command -v omz >/dev/null 2>&1; then
    echo -e "${GREEN}Updating Oh-My-Zsh...${NC}"
    omz update
    echo -e "${GREEN}Oh-My-Zsh updated.${NC}"
  else
    echo -e "${YELLOW}Oh-My-Zsh not found, skipping update.${NC}"
  fi
}

# Function to update 'uv' utility (if applicable)
update_uv() {
  if command -v uv >/dev/null 2>&1; then
    echo -e "${GREEN}Updating uv...${NC}"
    uv self update
    echo -e "${GREEN}uv updated.${NC}"
  else
    echo -e "${YELLOW}uv utility not found, skipping update.${NC}"
  fi
}

# Main execution
clear_cache
cleanup_docker
update_homebrew
update_omz
update_uv

echo -e "${YELLOW}All tasks completed.${NC}"
