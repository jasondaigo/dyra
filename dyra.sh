#!/usr/bin/env bash
read -e -p "edit hostname: " -i "http://127.0.0.1:8008" host
echo $host
echo -n "enter access_token: " 
read access_token
## host can be changed to different host ip/port (or FQDN, if api endpoint is exposed there)
# more api commands here https://matrix-org.github.io/synapse/latest/usage/administration/admin_api/index.html
submenu-users() {
    echo -ne "
SUBMENU
1) list all users # This is an inline comment
2) list specific user 
3) purge user media 
4) admin/deadmin
5) set user email addresse (primary)
6) reset password/logout sessions
7) deactivate account (also mark erased) ## read https://matrix-org.github.io/synapse/latest/admin_api/user_admin_api.html#deactivate-account
8) re-activate account
b) back 
e) exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
	while true; do
	read -p "save output file? '(y/n)'" yn
	case $yn in
        [Yy]* ) curl --header "Authorization: Bearer ${access_token}" -XGET $host/_synapse/admin/v2/users | python3 -mjson.tool >> userlist.txt; echo output saved as ./userlist.txt; break;;
        [Nn]* ) curl --header "Authorization: Bearer ${access_token}" -XGET $host/_synapse/admin/v2/users | python3 -mjson.tool; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
	submenu-users
;;
    2)
	echo user_id:
	read userid
	curl --header "Authorization: Bearer ${access_token}" -XGET $host/_synapse/admin/v2/users/$userid | python3 -mjson.tool
	submenu-users
        ;;
    3)
	echo user id:
	read user_id
	curl --header "Authorization: Bearer ${access_token}" -XDELETE $host/_synapse/admin/v1/users/$user_id/media | python3 -mjson.tool
	submenu-users
        ;;
    4)
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
	echo user id:
	read user_id
	echo email addresse:
	read email_id
	curl --header "Authorization: Bearer ${access_token}" -XPUT -d '{"threepids": [{"medium": "email","address": "'$email_id'"}]}' $host/_synapse/admin/v2/users/$user_id | python3 -mjson.tool
	submenu-users
        ;;
    6)
	echo user id:
	read user_id
	echo new password:
	read new_pass 
	curl --header "Authorization: Bearer ${access_token}" -XPOST -d '{"new_password": "'$new_pass'", "logout_devices": true}'  $host/_synapse/admin/v1/reset_password/$user_id | python3 -mjson.tool
	submenu-users
        ;;
    7)
	echo user id:
	read user_id
	curl  --header "Authorization: Bearer ${access_token}" -XPOST -d '{"erase": true }' $host/_synapse/admin/v1/deactivate/$user_id | python3 -mjson.tool	
	submenu-users
        ;;
    8)
	echo user id:
	read user_id
	echo new_password:
	read new_pass
	curl --header "Authorization: Bearer ${access_token}" -XPUT -d '{"deactivated": false, "password": "'$new_pass'"}' $host/_synapse/admin/v2/users/$user_id | python3 -mjson.tool
        ;;
    b)
        mainmenu
        ;;
    e)
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
5) move/rename room 
6) delete room 
b) back 
e) exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
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
	echo room id:
	read room_id
	curl --header "Authorization: Bearer ${access_token}" -XGET $host/_synapse/admin/v1/rooms/$room_id | python3 -mjson.tool
	submenu-rooms
        ;;
    3)
	echo room id:
	read room_id
	echo event id:
	read event_id
	curl --header "Authorization: Bearer ${access_token}" -XPOST -d '{"delete_local_events": true}' $host/_synapse/admin/v1/purge_history/\{$room_id}/\{$event_id} | python3 -mjson.tool
	submenu-rooms
        ;;
    4)
	echo purge id:
	read purge_id
	curl --header "Authorization: Bearer ${access_token}" -X GET  $host/_synapse/admin/v1/purge_history_status/{$purge_id} | python3 -mjson.tool
	submenu-rooms
        ;;
    5)
	echo room id:
	read room_id
	echo new room owner:
	read new_room_owner
	echo new room name:
	read new_room_name
	curl --header "Authorization: Bearer ${access_token}" -XDELETE -d '{"new_room_user_id":"'"${new_room_owner}"'","room_name":"'"${new_room_name}"'", "block": true, "purge": true }' $host/_synapse/admin/v1/rooms/\{$room_id} | python3 -mjson.tool
	submenu-rooms
	;;
    6)
	echo room id:
	read room_id
	curl --header "Authorization: Bearer ${access_token}" -XDELETE -d '{"block": true,  "purge": true}' $host/_synapse/admin/v2/rooms/\{$room_id} | python3 -mjson.tool
	submenu-rooms
	;;
    b)
        mainmenu
        ;;
    e)
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
b) back
e) exit
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
	curl --header "Authorization: Bearer ${access_token}" -X GET $host/_synapse/admin/v1/registration_tokens | python3 -mjson.tool
	submenu-tokens
        ;;
    3)
	curl --header "Authorization: Bearer ${access_token}" -X POST -H "Content-Type: application/json" -d {} $host/_synapse/admin/v1/registration_tokens/new | python3 -mjson.tool
	submenu-tokens
        ;;
    4)
	echo token id:
	read token_id
	curl --header "Authorization: Bearer ${access_token}" -X DELETE  $host/_synapse/admin/v1/registration_tokens/\{$token_id} | python3 -mjson.tool
	submenu-tokens
        ;;
    b)
        mainmenu
        ;;
    e)
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
3) delete report
4) purge remote media
5) purge local media
6) redact event
b) back
e) exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
	curl -XGET $host/_synapse/admin/v1/server_version | python3 -mjson.tool
	submenu-misc
        ;;
    2)
	curl --header "Authorization: Bearer ${access_token}" -XGET "$host/_synapse/admin/v1/event_reports?from=0&limit=10" | python3 -mjson.tool
	submenu-misc
        ;;
    3)
	echo report id:
	read report_id
	curl --header "Authorization: Bearer ${access_token}" -X DELETE  $host/_synapse/admin/v1/event_reports/\{$report_id} | python3 -mjson.tool
	submenu-misc
        ;;
    4)
	echo epoch timestamp: '(see https://www.epochconverter.com)'
	read epochms
	curl --header "Authorization: Bearer ${access_token}" -XPOST $host/_synapse/admin/v1/purge_media_cache?before_ts=$epochms | python3 -mjson.tool
	submenu-misc
        ;;
    5)
	echo server name:
	read server_name
	echo epoch timestamp: '(in milliseconds ,see https://www.epochconverter.com)'
	read epochms
	curl --header "Authorization: Bearer ${access_token}" -XPOST $host/_synapse/admin/v1/media/$server_name/delete?before_ts=$epochms | python3 -mjson.tool
	submenu-misc
        ;;
    6)
	echo room id:
	read room_id
	echo event id:
	read event_id
	curl --header "Authorization: Bearer ${access_token}" -XPUT -d '{"reason": "spamming"}' $host/_matrix/client/v3/rooms/${room_id}/redact/$event_id/{$RANDOM} | python3 -mjson.tool
	submenu-misc
        ;;
    b)
        mainmenu
        ;;
    e)
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
e) exit
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
    e)
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
