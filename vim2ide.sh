#/bin/bash
# Prepare vim for development
# ...according to my preferences
# author: raymond colebaugh

PACKAGES="vim exuberant-ctags "
PATHOGEN='https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim'

if [ "$1" == 'install' ]; then
    # Install necessary packages
    sudo apt-get install -y $PACKAGES
fi

# Download more plugins
if [ ! -d ~/.vim/autoload ];
then
    mkdir -p ~/.vim/{autoload,bundle} && cd ~/.vim
    curl -LSso autoload/pathogen.vim ${PATHOGEN}
else
    cd ~/.vim
fi
cd bundle
for url in majutsushi/tagbar scrooloose/nerdtree.git tpope/vim-rails.git \
        tpope/vim-fugitive.git rodjek/vim-puppet tpope/vim-surround.git \
        scrooloose/syntastic.git; do
    git clone git://github.com/${url}
done

# Get vim preferences
if [ ! -f ~/.vimrc-x ]; then
    for file in vimrc vimrc-x; do
        wget https://raw.githubusercontent.com/raymondcolebaugh/dotfiles/master/${file}
        mv $file ~/.${file}
    done
fi

# Aliases
grep '~/\.vimrc-x' ~/.bashrc
if [ $? -ne 0 ]; then
    cat >> ~/.bashrc << HERE

# enable Blowfish encryption
alias vix="vi -u ~/.vimrc-x -x"

# Enable less-style vim for syntax highlighting.
if [ -e /usr/share/vim/vim73/macros/less.sh ]; then
    alias less="/usr/share/vim/vim73/macros/less.sh"
fi

HERE
fi

