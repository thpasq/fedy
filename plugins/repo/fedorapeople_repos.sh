# Name: Fedora People repositories
# Command: fedorapeople_repos

fedorapeople_repos() {
while :
do
    fedorapeople_repos_list
    repos=$(show_dialog --list --checklist --width=900 --height=600 --title="Fedora People repositories" --text="The following repositories are listed from repos.fedorapeople.org and are unofficial. Add them at your own risk." --no-headers --hide-column="2" --print-column="2" --column "Select:CHK" --column "URL" --column "Name" --column "Description" --column "Status" --button="Back:1" --button="Add selected:0" "${repolist[@]}")
    if [[ $? -eq 0 ]]; then
        selrepo=$(echo $repos | tr "|" "\n")
        for repourl in $selrepo; do
            config_repo "$repourl"
        done
    else
        break
    fi
done
}

fedorapeople_repos_list() {
unset repolist
show_msg "Fetching repo list"
get_file_quiet "http://repos.fedorapeople.org/index.html" "fedorapeople.htm"
repourls=($(cat "fedorapeople.htm" | tr ' ' '\n' | grep "fedora-$fver" | grep .*http\:\/\/repos.fedorapeople.org\/repos\/.*\.repo.* | cut -d\' -f 2 | uniq))
for repourl in ${repourls[@]}; do
    repoup=${repourl%/*.repo}
    repofile=${repourl##*/}
    reponame=$(grep "\"$repoup\"" "fedorapeople.htm" | tail -n 1 | cut -d\" -f 3 | sed -e 's/^>//g' -e 's/<\/a>//g' -e 's/<\/td>//g')
    repodesc=$(grep -A1 "\"$repoup\"" "fedorapeople.htm" | tail -n 1 | sed -e 's/^[ \t]*//' -e 's/<td>//g' -e 's/<\/td>//g')
    check_repo "$repofile"
    if [[ $? -eq 0 ]]; then
        repostat="Added"
    else
        repostat="Not added"
    fi
    repolist=( "${repolist[@]}" FALSE "$repourl" "$reponame" "$repodesc" "$repostat" )
done
}
