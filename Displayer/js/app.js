var sequence = '01010101010101010101';
// < 0 even > means DARK, < 1 odd > means BRIGHT
var intSeq;
var timer;
var message;
var display;

flag = true;

function start(){
  var body = document.getElementsByTagName("body")[0]; 
  if(body.webkitRequestFullScreen){
    body.webkitRequestFullScreen(); 
  }
  // Show FullScreen
  message = document.getElementById("sequence_id");
  display = document.getElementById("display");
  intSeq = parseInt(sequence, 2);
  message.innerHTML += intSeq;
  message.style.visibility = "visible";
  timer = setInterval(twinkle, 500);
}

function twinkle(){

  if(intSeq <= 0){
    clearInterval(timer);
  }

  if(intSeq%2 == 0){
    display.style.background = "black";
  }
  else{
    display.style.background = "white";
  }
  
  intSeq = intSeq >> 1;
}

  