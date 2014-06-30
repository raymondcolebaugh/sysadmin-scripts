#/bin/bash
# Prepare vim for development
# ...according to my preferences
# author: raymond colebaugh

PACKAGES="vim exuberant-ctags "

# Install necessary packages
sudo apt-get install -y "$PACKAGES"

# Download more plugins
mkdir -p ~/.vim/{autoload,bundle} && cd ~/.vimrc
curl -LSso autoload/pathogen.vim \
    https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim
cd bundle
for url in majutsushi/tagbar scrooloose/nerdtree.git tpope/vim-rails.git \
        vim-bundler.git tpope/vim-fugitive.git rodjek/vim-puppet; do
    git clone git://github.com/${url}
done
#git clone git://github.com/majutsushi/tagbar
#git clone git://github.com/scrooloose/nerdtree.git
#git clone git://github.com/tpope/vim-rails.git
#git clone git://github.com/tpope/vim-bundler.git
#git clone git://github.com/tpope/vim-fugitive.git
#git clone git://github.com/rodjek/vim-puppet

# Get vim preferences
for url in vimrc vimrc-x; do
    git clone https://github.com/raymondcolebaugh/dotfiles/blob/master/${url}
done

# Aliases
cat >> ~/.bashrc <<- HERE

    # enable Blowfish encryption
    alias vix="vi -u ~/.vimrc-x -x"

    # Enable less-style vim for syntax highlighting.
    if [ -e /usr/share/vim/vim73/macros/less.sh ]; then
        alias less="/usr/share/vim/vim73/macros/less.sh"
    fi

HERE

