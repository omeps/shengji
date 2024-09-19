function callback(data) {
    document.getElementById("got").innerHTML = data;
    console.log("it worked")
}
var xmlHttp = new XMLHttpRequest();
xmlHttp.onreadystatechange = function() { 
    if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
        callback(xmlHttp.responseText);
}
xmlHttp.open("GET", "rand", true); // true for asynchronous 
xmlHttp.send(null);
