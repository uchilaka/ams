# frozen_string_literal: true

# set arguments for all 'brew install --cask' commands
cask_args appdir: '~/Applications', require_sha: true

# brew install
tap 'homebrew/cask' || true
brew 'tree'
tap 'heroku/brew' || true
brew 'heroku'
brew 'ruby-build'
brew 'asdf'

# install only on specified OS
brew 'tree' if OS.mac?
brew 'gnutls' if OS.mac?
brew 'foreman' if OS.mac?

cask 'docker'
cask 'ngrok'
