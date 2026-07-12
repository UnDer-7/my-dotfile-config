dkkk() {
    echo "⚠️  This will stop all containers, remove them, and delete all volumes."
    read "reply?Are you sure you want to continue? (y/N) "
    if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
        docker stop $(docker ps -q) && docker rm $(docker ps -a -q) && docker volume rm $(docker volume ls -q) && docker ps -a && docker volume ls
    else
        echo "Operation cancelled."
    fi
}
