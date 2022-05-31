#!/usr/bin/env bash
host=http://127.0.0.1:8008 ## <-- could be changed to different host ip/port (or url, if api endpoint is exposed)
# more api commands here https://matrix-org.github.io/synapse/latest/usage/administration/admin_api/index.html
submenu-users() {
    echo -ne "
SUBMENU
1) list all users 
2) list specific user 
3) purge user media 
4) admin/ deadmin
5) change user email addresse (primary)
6) back 
0) Exit
Choose an option:  "
    read -r ans
    case $ans in
    1)	echo enter access token:
	read access_token
	while true; do
	read -p "save output file? '(y/n)'" yn
	case $yn in
        [Yy]* ) curl --header "Authorization: Bearer ${access_token}" -XGET $host/_synapse/admin/v2/users | python3 -mjson.tool >> userlist.txt; echo output saved as userlist.txt; break;;
        [Nn]* ) curl --header "Authorization: Bearer ${access_token}" -XGET $host/_synapse/admin/v2/users | python3 -mjson.tool; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
	submenu-users
;;
    2)
	echo access token:
	read access_token
	echo user_id:
	read userid
	curl --header "Authorization: Bearer ${access_token}" -XGET $host/_synapse/admin/v2/users/$userid | python3 -mjson.tool
	submenu-users
        ;;
    3)
	echo access token:
	read access_token
	echo event limit: '(number of events to get purged)'
	read event_limit
	echo user id:
	read user_id
	curl --header "Authorization: Bearer ${access_token}" -XDELETE $host/_synapse/admin/v1/users/$user_id/media?limit=$event_limit | python3 -mjson.tool
	submenu-users
        ;;
    4)
	echo enter access token:
        read access_token
	echo user id:
	read user_id
        while true; do
        read -p "make admin? 'y/n'" yn
        case $yn in
        [Yy]* ) curl --header "Authorization: Bearer ${access_token}" -XPUT -d '{"admin": true}' $host/_synapse/admin/v1/users/$user_id/admin | python3 -mjson.tool; break;;
        [Nn]* ) curl --header "Authorization: Bearer ${access_token}" -XPUT -d '{"admin": false}' $host/_synapse/admin/v1/users/$user_id/admin | python3 -mjson.tool; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
	submenu-users
        ;;
    5)
	echo access token:
	read access_token
	echo user id:
	read user_id
	echo email addresse:
	read email_id
	curl --header "Authorization: Bearer ${access_token}" -XPUT -d '{"threepids": [{"medium": "email","address": "'$email_id'"}]}' $host/_synapse/admin/v2/users/$user_id | python3 -mjson.tool
	submenu-users
        ;;
    6)
        mainmenu
        ;;
    0)
        echo "have a nice day :-)"
        exit 0
        ;;
    *)
        echo "Wrong option."
        exit 1
        ;;
    esac
}

submenu-rooms() {
    echo -ne "
SUBMENU
1) list all rooms
2) list room details 
3) purge room history
4) purge status 
5) back 
0) Exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
	echo Access Token:
	read access_token
	while true; do
	read -p "save output file? 'y/n'" yn
	case $yn in
        [Yy]* ) curl --header "Authorization: Bearer ${access_token}" -XGET $host/_synapse/admin/v1/rooms?order_by=size | python3 -mjson.tool >> roomlist.txt; echo output saved as roomlist.txt; break;;
        [Nn]* ) curl --header "Authorization: Bearer ${access_token}" -XGET $host/_synapse/admin/v1/rooms?order_by=size | python3 -mjson.tool; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
	submenu-rooms
        ;;
    2)
	echo access token:
	read access_token
	echo room id:
	read room_id
	curl --header "Authorization: Bearer ${access_token}" -XGET $host/_synapse/admin/v1/rooms/$room_id | python3 -mjson.tool
	submenu-rooms
        ;;
    3)
	echo access token:
	read access_token
	echo room id:
	read room_id
	echo event id:
	read event_id
	curl --header "Authorization: Bearer ${access_token}" -XPOST -d '{"delete_local_events": true}' $host/_synapse/admin/v1/purge_history/\{$room_id}/\{$event_id} | python3 -mjson.tool
	submenu-rooms
        ;;
    4)
	echo access token:
	read access_token
	echo purge id:
	read purge_id
	curl --header "Authorization: Bearer ${access_token}" -X GET  $host/_synapse/admin/v1/purge_history_status/{$purge_id} | python3 -mjson.tool
	submenu-rooms
        ;;
    5)
        mainmenu
        ;;
    0)
        echo "have a nice day :-)"
        exit 0
        ;;
    *)
        echo "Wrong option."
        exit 1
        ;;
    esac
}

submenu-tokens() {
    echo -ne "
SUBMENU
1) get user access token
2) list all registration tokens
3) create new registration token
4) delete registration token
5) back
0) Exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
	echo user id:
	read user_id
	echo password:
	read user_pass
curl -XPOST -d '{"type":"m.login.password", "user":"'"${user_id}"'", "password":"'"${user_pass}"'"}' $host/_matrix/client/r0/login | python3 -mjson.tool
	submenu-tokens
        ;;
    2)
	echo access token:
	read access_token
	curl --header "Authorization: Bearer ${access_token}" -X GET $host/_synapse/admin/v1/registration_tokens | python3 -mjson.tool
	submenu-tokens
        ;;
    3)
	echo access token:
	read access_token
	curl --header "Authorization: Bearer ${access_token}" -X POST -H "Content-Type: application/json" -d {} $host/_synapse/admin/v1/registration_tokens/new | python3 -mjson.tool
	submenu-tokens
        ;;
    4)
	echo enter admin access token:
	read access_token
	echo token id:
	read token_id
	curl --header "Authorization: Bearer ${access_token}" -X DELETE  $host/_synapse/admin/v1/registration_tokens/\{$token_id} | python3 -mjson.tool
	submenu-tokens
        ;;
    5)
        mainmenu
        ;;
    0)
        echo "have a nice day :-)"
        exit 0
        ;;
    *)
        echo "Wrong option."
        exit 1
        ;;
    esac
}

submenu-misc() {
    echo -ne "
SUBMENU
1) server version 
2) event reports
3) purge remote media
4) purge local media
5) redact event
6) back
0) Exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
	curl -XGET $host/_synapse/admin/v1/server_version | python3 -mjson.tool
	submenu-misc
        ;;
    2)
	echo access token:
	read access_token
	curl --header "Authorization: Bearer ${access_token}" -XGET "$host/_synapse/admin/v1/event_reports?from=0&limit=10" | python3 -mjson.tool
	submenu-misc
        ;;
    3)
	echo access token:
	read access_token
	echo epoch timestamp: '(see https://www.epochconverter.com)'
	read epochms
	curl --header "Authorization: Bearer ${access_token}" -XPOST $host/_synapse/admin/v1/purge_media_cache?before_ts=$epochms | python3 -mjson.tool
	submenu-misc
        ;;
    4)
	echo access token:
	read access_token
	echo server name:
	read server_name
	echo epoch timestamp: '(see https://www.epochconverter.com)'
	read epochms
	curl --header "Authorization: Bearer ${access_token}" -XPOST $host/_synapse/admin/v1/media/$server_name/delete?before_ts=$epochms | python3 -mjson.tool
	submenu-misc
        ;;
    5)
	echo access token:
	read access_token
	echo room id:
	read room_id
	echo event id:
	read event_id
	curl --header "Authorization: Bearer ${access_token}" -XPUT -d '{"reason": "spamming"}' $host/_matrix/client/v3/rooms/${room_id}/redact/$event_id/{$RANDOM} | python3 -mjson.tool
	submenu-misc
        ;;
    6)
        mainmenu
        ;;
    0)
        echo "have a nice day :-)"
        exit 0
        ;;
    *)
        echo "Wrong option."
        exit 1
        ;;
    esac
}

mainmenu() {
    echo -ne "
MAIN MENU
1) users
2) rooms
3) tokens
4) misc
0) exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
        submenu-users
        mainmenu
        ;;
    2)
        submenu-rooms
        mainmenu
        ;;
    3)
        submenu-tokens
        mainmenu
        ;;
    4)
        submenu-misc
        mainmenu
        ;;
    0)
        echo "have a nice day :-)"
        exit 0
        ;;
    *)
        echo "Wrong option."
        exit 1
        ;;
    esac
}

mainmenu
