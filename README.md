# air-gapped-dotfiles

```text
개인적인 작업에는 helix를 쓰고 있다. neovim configuration이나 deps break에 대응하기가 번거로워서  
```

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
