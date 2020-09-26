// main.js

document.getElementById("demo").innerHTML = "Hello JavaScript!";

var counter = 0;
function count() {
	// body...
	counter++;
	document.getElementById("counter").innerHTML = "Counter: " + counter;
}