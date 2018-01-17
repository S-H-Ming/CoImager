<?php
$file = fopen("blink.txt","w")or die("Unable open file");
fwrite($file,"TRUE");
fclose($file);
?>