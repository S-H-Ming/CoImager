<?php
$file = fopen("blink.txt","w")or die("Unable open file");
fwrite($file,"FALSE");
fclose($file);
$fp=fopen("clientList.txt","w")or die("Unable open file");
fwrite($fp,"");
fclose($fp);
?>