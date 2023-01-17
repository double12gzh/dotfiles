<h1 align="center">
    dotfiles
</h1>

# Prerequest

- Install Perl
- Install Test::Output `cpanm install Test::Output`
- Install Test::More `cpanm install Test::More`
- Install [GNU stow](https://www.gnu.org/software/stow/)

```bash
# NOTE: make sure perl is installed
# NOTE: also, cpanm install Test::Output and Test::More

bash install_stow.sh
```

# Usage

- clone this repo

```bash
git clone git@github.com:double12gzh/.forked_dotfiles.git ~
```

- create symlink

```bash
stow */

# or 

stow Git
```

# Ref

- -D: remove the created symlink.
- -S: create assigned symlink.
- -R: remove & recreate assigned symlink.
