parse_git_branch() {
    Branch=$(git branch 2>/dev/null | grep '^*' | colrm 1 2)
    # TODO: Remove the Factom specific stuff here
    FD=$(echo $Branch | grep -Eio "FD-[0-9]+")
    if [ "$FD" = "" ]; then
            if [ "$Branch" = "" ]; then
                    echo ""
            else
                    echo \($Branch\)
            fi
    else
            echo \($FD\)
    fi
}