<!DOCTYPE html>
<?php

$fp = fopen("clientList.txt","a");
$clients = array();
$seq = rand(10240,11263); // 10100000000000 ~ 10101111111111, bias(1010) + 10 digits

// Get the unique Sequence Code
if(flock($fp, LOCK_EX)){
	while($code = fgets($fp)){
		$clients[$code] = " ";
	}
	while(array_key_exists($seq,$clients)){
		$seq = rand(10240,11263);
	}
	flock($fp, LOCK_UN);
}

// Write to the Record File
if(flock($fp, LOCK_EX)){
	fwrite($fp,decbin($seq).PHP_EOL);
	flock($fp, LOCK_UN);
}
fclose($fp);
?>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="pragma" content="no-cache"> 
  <title>CoImager - Display</title>
  <link rel="stylesheet" type="text/css" href="css/style.css">
  <script type="text/javascript" src="js/app.js"></script>
  <script type="text/javascript">
	intSeq = <?php echo $seq; ?>;
  </script>
</head>
<body>
  <canvas id="display">
    
  </canvas>
  <div id="message">
    <button onclick="start()" style="font-size: 20px;">Get ID</button>
    <div id="sequence_id">
    your ID: <?php echo $seq; ?>
    </div>
  </div>
</body>
</html>
