# Your Git workflow with automated repository fetching

This plugin automates the process of fetching updates from remote git repositories, making your coding life a little bit smoother.

Useful when you deal with git repositories that get frequent updates. Instead of the tedious 'git fetch' routine, this handle it for you in the background.

## Installation

Using [`tpm`](https://github.com/tmux-plugins/tpm/): on your `.tmux.conf` source this:
```sh
set -g @plugin 'thepante/tmux-git-autofetch'
```
And install it with `<prefix> + I`

Now add a cron job with:
```sh
~/.tmux/plugins/tmux-git-autofetch/git-autofetch.tmux --add-cron
```

Check that it got correctly listed with:
```sh
crontab -l
```

Done. Every 3 minutes, your repositories will now be automatically fetched in background.

## Notes
- It only fetches! It doesn't pull. To display the status use whatever you want. Eg: I have [gitmux](https://github.com/arl/gitmux) on my tmux status bar.
- You can edit the interval: run `crontab -e` and edit the cron frequency. By default every 3 minutes (`*/3`).
- For private repositories be sure to get properly configured the SSH credentials for them, otherwise could not being fetched.
- Config options would be added soon.

