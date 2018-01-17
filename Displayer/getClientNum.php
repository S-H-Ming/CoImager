<?php
header("Content-Type:application/json; charset=utf-8");

$connectNum = 0;
$file = fopen("clientList.txt","r");

if( $file && $_GET["getCNum"] == "TRUE"){
	
	$ids = array();
	while(!feof($file)) array_push($ids,trim(fgets($file)));
	fclose($file);
	
	$data = ['ID' => $ids];
	echo json_encode($data);
}else{
	echo "Failed!";
}
?>