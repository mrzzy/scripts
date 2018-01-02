#!/usr/bin/perl
use strict;
use warnings;

print("IOENV\n");
print("Setup IO programming enviroment\n");

#Installing
print("Installing Command Line tools...\n");
system("xcode-select --install");

#Install Brew
print("Installing Package Manager...\n");
system('/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"');

#Install Tools
print("Installing Editor & Terminal Multiplexer...\n");

system("brew update --force");
system("brew install python python3");
system("pip2 install neovim --upgrade");
system("pip3 install neovim --upgrade");
system("brew install neovim tmux");

my $nvim_config = <<'END_OF_FILE';

"
" ~/etc/nvim/init.vim
" NeoVim Configuration
" 
" Made by Zhu Zhan Yan
" Copyright (c) 2017.
" 

"Editing Settings
set autoread
set ruler
set number
set smartcase
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set noshowmode
set showtabline=2
set wildmode=longest,list,full
set wildmenu
set laststatus=2

"File Settings
set encoding=utf8
set path+=/usr/local/include/,/usr/local/include/c++/7.1.0/,/usr/include/
filetype plugin on
filetype plugin indent on
autocmd Filetype scheme set tabstop=2
autocmd Filetype make set noexpandtab

"Display Settings
set hlsearch
set background=dark
colorscheme desert

"Keyboard Bindings
let g:mapleader = ","
nmap <leader>a :args<cr>
nmap <leader>aa :argedit
nmap <leader>aq :argdelete %<cr>
nmap <leader>an :next<cr>
nmap <leader>aN :Next<cr>
nmap <leader>a< :rewind<cr>
nmap <leader>a. :last<cr>
nmap <leader>a, :argdo
nmap <leader>b :ls<cr>
nmap <leader>bq :bdelete<cr>
nmap <leader>bn :bnext<cr>
nmap <leader>bN :bNext<cr>
nmap <leader>b, :blast<cr>
nmap <leader>b. :brewind<cr>
nmap <leader>bx :bufdo
nmap <leader>t :tabs<cr>
nmap <leader>tt :tabnew<cr>
nmap <leader>tq :tabclose<cr>
nmap <leader>tn :tabnext<cr>
nmap <leader>tN :tabNext<cr>
nmap <leader>t, :tabrewind<cr>
nmap <leader>t. :tablast<cr>
nmap <leader>t> :tabmove -1<cr>
nmap <leader>t< :tabmove +1<cr>
nmap <leader>s :setl spell<cr>
nmap <leader>sn ]s
nmap <leader>sN [s
nmap <leader>ss z=
nmap <leader>/n :noh<cr>
nmap <leader>/i :set ignorecase!<cr>
nmap <leader>hl :setl background=light<cr>
nmap <leader>hd :setl background=dark<cr>
nmap <leader>\ :set colorcolumn=80<cr>

"Plugin
call plug#begin('~/.local/share/nvim/plugged')
Plug 'Shougo/denite.nvim'

Plug 'Shougo/deoplete.nvim'
Plug 'zchee/deoplete-jedi'
Plug 'Shougo/neoinclude.vim'
Plug 'artur-shaik/vim-javacomplete2'
Plug 'landaire/deoplete-swift'
Plug 'zchee/deoplete-clang'
"Plug 'autozimu/LanguageClient-neovim'
Plug 'clojure-vim/async-clj-omni'
Plug 'carlitux/deoplete-ternjs'
Plug 'fszymanski/deoplete-abook'
Plug 'Shougo/neco-syntax'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'sebastianmarkow/deoplete-rust'
Plug 'tpope/vim-repeat'
Plug 'neomake/neomake'

Plug 'mileszs/ack.vim'

Plug 'altercation/vim-colors-solarized'
Plug 'vim-airline/vim-airline'

call plug#end()

"Plugin Configuration
let g:deopleteA#enable_smart_case=1
let g:deoplete#auto_complete_delay=25

let g:deoplete#sources#clang#libclang_path="/usr/local/Cellar/llvm/4.0.1/lib/libclang.dylib"
let g:deoplete#sources#clang#clang_header="/usr/local/Cellar/llvm/4.0.1/include/clang"

"Plugin Bindings
nmap <leader>cc :call deoplete#toggle()<cr>
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

let g:UltiSnipsExpandTrigger="<C-x>"

"Plugin Display Setting
colorscheme solarized

"Plugin File Settings
autocmd InsertLeave * pclose
autocmd InsertEnter * call deoplete#enable()
autocmd FileType java setlocal omnifunc=javacomplete#Complete
autocmd CursorHold,BufEnter,BufWritePost * Neomake
END_OF_FILE
open(my $file, '>', '~/.config/nvim/init.vim');
print($file, $nvim_config);
close($file);

my $tmux_config = <<'END_OF_FILE';
#
# ~/etc/tmux/tmux.conf
# Usr Config - Tmux Config
#
# Made by Zhu Zhan Yan.
# Copyright (c) 2016. All Rights Reserved.
#

#Src
source-file /Users/zzy/Etc/tmux/tmuxline.conf

#Set
set-option -g base-index 0
set-option -wg automatic-rename on
set-option -g set-titles on
set-option -g status-keys vi
set-option -g buffer-limit 10
set-option -g set-clipboard on
set-option -g default-shell /bin/bash
set-option -g default-terminal screen-256color
set-option -g prefix M-w
set-option -g renumber-windows on
set-option -g focus-events on
set-option -wg clock-mode-style 24
set-option -wg mode-keys vi
set-option -sg escape-time 0

#Kdb
bind-key M-q suspend-client
bind-key '"' select-layout even-horizontal
bind-key "=" select-layout even-vertical
bind-key "'" select-layout tiled
bind-key b break-pane
bind-key B join-pane -s :!
bind-key % capture-pane
bind-key M-a choose-client
bind-key C-a choose-session "switch-client -t %%"
bind-key A choose-tree
bind-key a display-pane
bind-key d detach-client
bind-key D choose-client "detach-client -t %%"
bind-key q kill-pane
bind-key Q kill-window
bind-key C-q choose-session "kill-session -t %%"
bind-key M-q kill-server
bind-key "#" last-window
bind-key W new-window -a
bind-key w new-window -a -c "#{pane_current_path}"
bind-key e new-session
bind-key ) next-layout
bind-key ( previous-layout
bind-key [ previous-window
bind-key ] next-window
bind-key } swap-window -t +
bind-key { swap-window -t -
bind-key -r < resize-pane -L 
bind-key -r + resize-pane -D
bind-key -r > resize-pane -R
bind-key -r - resize-pane -U
bind-key h select-pane -L
bind-key j select-pane -D
bind-key l select-pane -R
bind-key k select-pane -U
bind-key r rotate-window -D
bind-key R rotate-window -U
bind-key S split-window -v
bind-key V split-window -h
bind-key p split-window -v "bash -c 'vim /tmp/npd.txt'"
bind-key s split-window -v -c "#{pane_current_path}"
bind-key v split-window -h -c "#{pane_current_path}"
bind-key H swap-pane -s bottom-left
bind-key J swap-pane -s bottom
bind-key K swap-pane -s top
bind-key L swap-pane -s right
bind-key x swap-pane -s -
bind-key I list-commands
bind-key i list-sessions
bind-key c copy-mode
bind-key -n M-e send-prefix
END_OF_FILE
open($file, '>', '~/.tmux.conf');
print($file, $tmux_config);
close($file); 

#Install Plugins
print("Installing Plugins...\n");
system("curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim");
system("nvim +UpdateRemotePlugins +PlugUpdate +qall");

#Install Documentation
print("Installing Documentation (C++)...\n");
system("git clone https://github.com/jeaye/stdman && cd stdman && ./configure && make install");
system("rm -rf stdman");

#Setup Workspace
print("Creating Workspace...\n");
system("cd ~/Desktop; mkdir IOENV; cd IOENV");
my $makefile = <<'END_OF_FILE';
#IO MAKEFILE
SRC=
PDCT=
PDCT:=./$(PDCT)
CFLAGS=
CDFLAGS=
COFLAGS=

d:
	g++ $(CFLAGS) $(CDFLAGS) -o $(PDCT) $(SRC)

o:  
	g++ $(CFLAGS) $(COFLAGS) -o $(PDCT) $(SRC)

e:
	time $(PDCT) <in.txt &>prof.txt

t:
	$(PDCT) <in.txt &1>out.txt &2>err.txt
	diff out.txt exp.txt
END_OF_FILE
open($file, '>', './IOENV/makefile');
print($file, $makefile);
close($file); 

print("IO Enviroment Setup COMPLETE!\n");
