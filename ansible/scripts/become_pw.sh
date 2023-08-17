if [ -z "$ANSIBLE_BECOME_PASSWORD" ]; then
    while : ; do
        # TODO use secret
        echo -n "ANSIBLE_BECOME_PASSWORD: "; stty -echo; read -s SESSION_PASSWORD; stty echo; echo
        export ANSIBLE_BECOME_PASSWORD=$SESSION_PASSWORD
        OUTPUT="$(ansible localhost -m "ping" --become -e ansible_become_password='{{ lookup("env", "ANSIBLE_BECOME_PASSWORD") }}')"
        if [ "$?" -eq 0 ]; then
            break
        fi
        echo $OUTPUT
    done
fi
