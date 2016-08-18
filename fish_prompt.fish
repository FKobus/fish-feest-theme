# name: feest
# by FKobus
# License: public domain

function _git_status_cmd
  set -l git_branch (command git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
  if test -n "$git_branch"
    # echo (set_color cyan) "("$git_branch")"
    echo (set_color cyan) $git_branch
  end
end

function _show_me_the_fish
  set -l git_branch (command git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
  if test -n "$git_branch"
    set -l git_status (git status --porcelain ^/dev/null)
    set the_fish ""
    if test -n "$git_status"
      if git status --porcelain ^/dev/null | grep '^.[^ ]' >/dev/null
        # status is dirty
        set the_fish (set_color red)'⋊>'
      else
        # status is staged
        set the_fish (set_color yellow)'⋊>'
      end
    else
      set the_fish (set_color green)'⋊>'
    end
  else 
    set the_fish (set_color yellow)"⋊>"
  end
  echo $the_fish
end
function _remote_hostname
  # echo (whoami)
  if test -n "$SSH_CONNECTION"
    echo " (ssh)"
  end
end

function _local_hostname
  echo (set_color yellow) (hostname)
end

function _get_tmux_window
  tmux lsw | grep active | sed 's/\*.*$//g;s/: / /1' | awk '{ print $2 "-" $1 }' -
end

function _get_screen_window
  set initial (screen -Q windows; screen -Q echo "")
  set middle (echo $initial | sed 's/  /\n/g' | grep '\*' | sed 's/\*\$ / /g')
  echo $middle | awk '{ print $2 "-" $1 }' -
end

function _is_multiplexed
  set multiplexer ""
  if test -z $TMUX
  else
    set multiplexer "tmux"
  end
  if test -z $WINDOW
  else
    set multiplexer "screen"
  end
  echo $multiplexer
end

function flushdns -d "Flushes OS X DNS cache"
  sudo killall -HUP mDNSResponder
end

function updatedb -d "Updates 'locate' database"
  sudo /usr/libexec/locate.updatedb
end

function gc 
  git commit -am "$argv"
end  

function fish_prompt
  set -l cyan (set_color cyan)
  set -l brown (set_color brown)
  set -l normal (set_color normal)
  set -l yellow (set_color yellow)
  set -l arrow "λ"
  # set -l cwd (set_color $fish_color_cwd)(prompt_pwd)
  set -l cwd (set_color $fish_color_cwd)(basename (prompt_pwd))

  set multiplexer (_is_multiplexed)

  switch $multiplexer
    case screen
      set pane (_get_screen_window)
    case tmux
      set pane (_get_tmux_window)
   end

  if test -z $pane
    set window ""
  else
    set window " ($pane)"
  end

  echo -n -s (_show_me_the_fish) (_local_hostname) (_remote_hostname) $normal ' ' $cwd ' →' $yellow $window (_git_status_cmd) $normal ' ' $arrow ' '
end
