
function mirror_repo {
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

    curl --header "PRIVATE-TOKEN: ${MIRROR_GITLAB_TOKEN}" -H "Accept: application/json" -H "Content-type: application/json" -X POST -d "{ \"namespace_id\": \"${MIRROR_GITLAB_NAMESPACE_ID}\", \"name\": \"$repo_name\", \"visibility\": \"public\", \"description\": \"Mirror of ${1}\" }" "https://${MIRROR_GITLAB_DOMAIN}/api/v4/projects"

    git clone --mirror $1
    cd  ${repo}.git
    git remote add mirror ${MIRROR_GITLAB_URL}/${repo_name}
    git push --mirror mirror
    cd ..
    rm -rf ${repo}.git
}

while IFS="" read -r p || [ -n "$p" ]
do
  mirror_repo $p
done < repos.txt
