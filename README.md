# Mirror git repos to Gitlab

This script will mirror any git repo to a gitlab server. This repo is setup to run the gitlab ci pipeline on a cron job to get updates from all repos.


## Requirements
- bash
- git
- curl
- Environment Variables:
  ```bash
  # Fill in the values with your info to use the script

  # gitlab user access token, needs api & write repo permissions
  export MIRROR_GITLAB_TOKEN=<ACCESS_TOKEN_HERE>
  # URL that will be the new remote of the repo (minus the name). NOTE: NO `/` at the end
  export MIRROR_GITLAB_URL=https://gitlab-ci-token:<ACCESS_TOKEN_HERE>@<SERVER_DOMAIN>/<GROUP_NAME>
  # The group id you want the mirrors to save to
  export MIRROR_GITLAB_NAMESPACE_ID=<GROUP_ID>
  ```

## Usage
- Add repos, 1 per line in a file called `repos.txt`
- Run to mirror all repos in the file `./mirror-to-gitlab.sh`
