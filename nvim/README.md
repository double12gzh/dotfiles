<h1 align="center">My Neovim Configuration</h1>

## Install
```bash
    git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/opt/packer.nvim && \
    nvim -V --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
    nvim --headless -c 'TSInstall' +"sleep 30" +qa
    nvim --headless -c 'TSUpdate' +"sleep 15" +qa
```

## Q&A
- debug
```bash
:checkhealth
:PackerSync
:MasonLog
:Mason
```

- Font
```bash
Hack Nerd Font
Operator Mono Lig
```

- Alacritty Font Config
```bash
# Font configuration
font:
  # Normal (roman) font face
  normal:
    # Font family
    #
    # Default:
    #   - (macOS) Menlo
    #   - (Linux/BSD) monospace
    #   - (Windows) Consolas
    family: Hack Nerd Font

    # The `style` can be specified to pick a specific face.
    style: Regular
```

- todo
```bash
# install stylus
npm install stylus --save
npm install stylus-loader --save

# install actionlint
bash <(curl https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash)

# install ruby
sudo apt install ruby-full

# install buildifier
go install github.com/bazelbuild/buildtools/buildifier@latest

pip install cmake-format==0.2.0
cargo install stylua
sudo apt install php-fpm
npm install -g fixjson
sudo apt install snapd &&sudo snap install shfmt
npm install -g prettier
curl -sS https://webinstall.dev/shfmt | bash
```
