#! /bin/bash

function mirror_repo {
  echo "Mirror $1"
  readarray -d / -t parts < <(printf '%s' "$1")

  read -ra namespace <<< "${parts[@]:3}"
  namespace=${namespace[@]::${#namespace[@]}-1}
  namespace=${namespace// /__}  # if there are subgroups
  repo=${parts[-1]}
  # Remove trailing .git if exists
  if [[ $repo =~ \.git$ ]]; then
          repo=${repo::-4}
  fi
  repo_name="${namespace}__${repo}"

  echo $repo_name

  api_resp=$(curl --silent --header "PRIVATE-TOKEN: ${MIRROR_GITLAB_TOKEN}" -H "Accept: application/json" -H "Content-type: application/json" -X POST -d "{ \"namespace_id\": \"${MIRROR_GITLAB_NAMESPACE_ID}\", \"name\": \"$repo_name\", \"visibility\": \"public\", \"description\": \"Mirror of ${1}\" }" "https://${MIRROR_GITLAB_DOMAIN}/api/v4/projects")

  # Add a tralling / if needed
  [[ $MIRROR_PATH != *\/ && ! -z $MIRROR_PATH ]] && MIRROR_PATH=${MIRROR_PATH}/
  # Create dir paths if set
  [[ ! -z $MIRROR_PATH ]] && mkdir -p $MIRROR_PATH

  REPO_PATH=${MIRROR_PATH}${repo_name}
  # Check if repo exists
  if [ -d $REPO_PATH ]; then
    echo "Fetching $1"
    cd  ${REPO_PATH}
    git fetch --prune --quiet origin
    # Re set mirror url just in case its needed
    git remote set-url mirror ${MIRROR_GITLAB_URL}/${repo_name}
  else
    echo "Cloning $1"
    git clone --quiet --mirror $1 ${REPO_PATH}
    cd  ${REPO_PATH}
    git remote add mirror ${MIRROR_GITLAB_URL}/${repo_name}
  fi

  git push --quiet --prune --mirror mirror
  cd -
  if [ "$MIRROR_CLEANUP" = true ] ; then
    rm -rf ${REPO_PATH}
  fi
}

# Set defaults
MIRROR_CLEANUP=${MIRROR_CLEANUP:=false}

while IFS="" read -r line || [ -n "$1" ]
do
  # ignore blank lines and lines that start with #
  [[ -z "$line" || $line =~ ^#.* ]] && continue

  mirror_repo $line
done < repos.txt
