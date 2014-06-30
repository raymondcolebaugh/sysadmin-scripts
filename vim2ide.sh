#/bin/bash
# Prepare vim for development
# ...according to my preferences
# author: raymond colebaugh

PACKAGES="vim exuberant-ctags "

# Install necessary packages
sudo apt-get install -y $PACKAGES

# Download more plugins
mkdir -p ~/.vim/{autoload,bundle} && cd ~/.vimrc
curl -LSso autoload/pathogen.vim \
    https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim
cd bundle
for url in majutsushi/tagbar scrooloose/nerdtree.git tpope/vim-rails.git \
        vim-bundler.git tpope/vim-fugitive.git rodjek/vim-puppet; do
    git clone git://github.com/${url}
done

# Get vim preferences
for file in vimrc vimrc-x; do
    wget https://raw.githubusercontent.com/raymondcolebaugh/dotfiles/master/${file}
    mv $file ~/.${file}
done

# Aliases
cat >> ~/.bashrc << HERE

# enable Blowfish encryption
alias vix="vi -u ~/.vimrc-x -x"

# Enable less-style vim for syntax highlighting.
if [ -e /usr/share/vim/vim73/macros/less.sh ]; then
    alias less="/usr/share/vim/vim73/macros/less.sh"
fi

HERE

