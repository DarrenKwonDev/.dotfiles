# .dotfiles

## overall dev setup

asdf로 language versioning 을 활용하고 
term split은 editor 내장 기능을 사용하되 분리가 필요하면 wezterm에서 곧장 분리한다.
zellij나 tmux 둘 다 조작하기가 번거롭다고 생각    

## helix

개인적인 작업에는 helix를 쓰고 있다.  
PATH에 lsp만 잘 잡아주면 작업하는데 불편하지 않다.  
무엇보다 neovim configuration이나 deps break에 대응하는데 시간을 쏟고 싶지 않다  

## vim

폐쇄망 환경(ex - 증권사에서 제공하는 DMA) 내에서 개발을 해야 하는 경우  
순수한 vim과 ctag 같은 기본적인 도구만으로 개발을 해야 하는 상황이 있음.  
특히, DMA 라면 vscode 등 IDE가 원격 접속하기 위해 생성된 프로세스 마저도
latency에 기여하여 매매에 영향을 미치기도 한다.

### vim work view

 - [ ] \<Leader\>tl: Generate tagbar using ctags for current buffer
 - [ ] Show buffer list at the top
 - [ ] Split horizontally and navigate windows using Termius (if Termius is not allowed, use tmux)
 - [ ] highlight 'call', '콜', 'put', '풋' keyword to prevent error-prone code  

<img src="./work_view.png" alt="work view" />

