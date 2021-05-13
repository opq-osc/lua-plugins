<?php
error_reporting(E_ALL);
date_default_timezone_set('Asia/Shanghai');
ini_set('user_agent', 'Spirit');

require_once 'vendor/autoload.php';
use UAParser\Parser;

$user_online = $_GET['g'];
$or = file_get_contents("服务器API/kp.php?action=p&g=".$user_online ."-dsssss");
$data = json_decode($or,true);
file_put_contents("kp/" .date('mdHis')."-".$user_online.".txt", json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT));
$json = array();
foreach ((array)$data as $user) {
    $ip = $user["ip"];
    $ua = $user["ua"];
    $time = $user["time"];

    $parser = Parser::create();
    $result = $parser->parse($ua);

    $ua = $result->device->brand ." ".$result->device->model . "/" . $result->os->toString();;
    // $ua = $result->originalUserAgent;

    $file_contents = file_get_contents('http://ip.taobao.com/outGetIpInfo?accessKey=alibaba-inc&ip='.$ip);
    $result = json_decode($file_contents,true)["data"];
    $ip = preg_replace('~(.*?):(.*?):.*~',"$1:$2:**:****",$ip);
    $ip = preg_replace('~(\d+)\.(\d+)\.(\d+)\.(\d+)~',"$1.$2.*.*",$ip);
    $addr = $result["country"] != "中国" ? $result["country"]:$result["region"]. ' ' .  $result["city"] . ' ' . $result["isp"];
    $json[] = array(
        "ip" => $ip,
        "addr" => $addr,
        "ua" => $ua,
        "time" => $time
    );
}
echo json_encode($json, JSON_PRETTY_PRINT);
