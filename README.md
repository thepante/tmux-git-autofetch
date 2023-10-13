# Your Git workflow with automated repository fetching

This plugin automates the process of fetching updates from remote git repositories, making your coding life a little bit smoother.

Useful when you deal with git repositories that get frequent updates. Instead of the tedious 'git fetch' routine, this handle it for you in the background.

![demo](demo.gif)
_(play the gif and look top-right just along with `master`: it fetches and the status got updated)_

## Installation

Using [`tpm`](https://github.com/tmux-plugins/tpm/): on your `.tmux.conf` add this line:
```sh
set -g @plugin 'thepante/tmux-git-autofetch'
```
Afterward, install it by pressing `<prefix> + I`.

This installation adds a cron job and a zsh hook to automate the fetching process.

## Usage

Once installed, your repositories will be automatically fetched in the background every 3 minutes.

## Notes
- This plugin only fetches updates; it does not perform git pulls nor display info about it.<br>You can display the status using any method you prefer. For instance, you can integrate it with [gitmux](https://github.com/arl/gitmux) for your tmux status bar.
- You can edit the fetching interval by editing the crontab: `crontab -e` and edit the frequency. Default is every 3 minutes (`*/3`).
- For private repositories: ensure that your SSH credentials are correctly configured to avoid fetching rejections.
- Config options would be added soon.

