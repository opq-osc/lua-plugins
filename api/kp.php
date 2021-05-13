<?php
ini_set('display_errors', true);
error_reporting(E_ALL);
date_default_timezone_set('Asia/Shanghai');
global $user_online;

function load_data() {
    global $user_online;
    $data = file_get_contents($user_online);
    $data = json_decode($data, true);
    $json = array();
    if (sizeof($data) > 0) {
        foreach ((array) $data as $single_data) {
            if (date('mdHis') - date('mdHis',strtotime(date('Y-').$single_data["time"])) < 60) {
                if (strpos(json_encode($json),$single_data['ip'])) {
                    continue;
                }
                $json[] = array(
                    "ip" => $single_data["ip"],
                    "ua" => $single_data["ua"],
                    "time" => $single_data["time"]
                );
            }
        }
    }
    $data = array_unique($json, SORT_REGULAR);
    return $data;
}

function save_data($data) {
    global $user_online;
    $old_data = load_data();
    if (!strpos(json_encode($old_data),$data['ip'])) {
        array_push($old_data, $data);
        $old_data = array_unique($old_data, SORT_REGULAR);
    }
    file_put_contents($user_online, json_encode($old_data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT));
}


preg_match('/(\d+)\-.*/',$_GET['g'],$matches);
$user_online = $matches[1];
$user_online = $user_online.".txt";
if ($user_online == '.txt') {
    exit();
}

$action = isset($_GET['action'])?$_GET['action']:'s';
if ($action == "s") {
    $json = array(
        "ip" => getenv('REMOTE_ADDR'),
        "ua" => getenv('HTTP_USER_AGENT'),
        "time" => date('m-d H:i:s')
    );

    header('Content-type: image/jpg');
    echo file_get_contents("1.jpg");

    if (file_exists($user_online)) {
        save_data($json);
    } else {
        file_put_contents($user_online,'[]');
        save_data($json);
    }
    exit();
} elseif ($action == "p") {
    echo json_encode(load_data());
    exit();
} else {
    exit("error!");
}

?>