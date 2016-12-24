// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
// import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

var elmDiv = document.getElementById("elm-container");
var app = Elm.Main.embed(elmDiv);

/* Text search helpers */
var lastTimeoutId;
app.ports.scrollToElement.subscribe(function(value){
    if (lastTimeoutId) {
        window.clearTimeout(lastTimeoutId);
    }
    var element = document.getElementById(value);

    if (element) {
        element.scrollIntoView();
    }

    lastTimeoutId = window.setTimeout(function(){
        app.ports.resetKeysBeingTyped.send("nothing");
    }, 1000);
});



// /* Pause */
// app.ports.pause.subscribe(function(){
//     var player = document.getElementsByTagName("audio")[0];
//     if (!player)  {return;}
//     if (player.paused) {
//         player.play();
//     } else {
//         player.pause();
//     }
// });

// /* Album Art */
// app.ports.lookupAlbumArt.subscribe(function(albumName){
//     // console.log("searching for album art...");
//     // dbUtils.findById(albumName + "-album").then(function(doc){
//     //     app.ports.updateAlbumArt.send(doc.picture);
//     // });
// });

