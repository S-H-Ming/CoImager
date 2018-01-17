var sequence = '01010101010101';  // 14 interals
// < 0 even > means DARK, < 1 odd > means BRIGHT
var intSeq;
var twinkleTimer;
var checkTimer;
var message;
var display;


function start(){
  /*
  var body = document.getElementsByTagName("body")[0]; 
  if(body.webkitRequestFullScreen){
    body.webkitRequestFullScreen(); 
  }
  */
  // Show FullScreen
  message = document.getElementById("sequence_id");
  display = document.getElementById("display");
  //intSeq = parseInt("<?php echo $seq; ?>", 2);
  message.style.visibility = "visible";
  console.log(intSeq);
  checkTimer = setInterval(loadDoc,500);
}

function loadDoc(){
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function(){
		if(this.readyState == 4 && this.status == 200) checkIfBlink(this);
	};
	xhttp.open("GET",'blink.txt');
	xhttp.send();
}

function checkIfBlink(xhttp){
	if(xhttp.responseText == "TRUE"){
		clearInterval(checkTimer);
		twinkleTimer = setInterval(twinkle, 200); // each interval for 0.5 sec
	}
	else {
		console.log("No Blink ask");
	}
}

function waitBlink(){
	
}

function twinkle(){
	console.log("twinkle");
  if(intSeq <= 0)clearInterval(twinkleTimer);

  if(intSeq%2 == 0)display.style.background = "black";
  else display.style.background = "white";
  
  intSeq = intSeq >> 1;
}

  