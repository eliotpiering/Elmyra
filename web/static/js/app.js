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
// var lastTimeoutId;
// app.ports.scrollToElement.subscribe(function(value){
//     if (lastTimeoutId) {
//         window.clearTimeout(lastTimeoutId);
//     }
//     var element = document.getElementById(value);

//     if (element) {
//         element.scrollIntoView();
//     }

//     lastTimeoutId = window.setTimeout(function(){
//         app.ports.resetKeysBeingTyped.send("nothing");
//     }, 1000);
// });

// app.ports.upload.subscribe(function(value){
//     var files = document.getElementById("file-upload");
//     ajaxPost(files, function(res){
//         console.log(res);
//     });
// });

// function ajaxPost (form, callback) {
//     var url = form.action,
//         xhr = new XMLHttpRequest();

//     //This is a bit tricky, [].fn.call(form.elements, ...) allows us to call .fn
//     //on the form's elements, even though it's not an array. Effectively
//     //Filtering all of the fields on the form
//     // var params = [].filter.call(form.elements, function(el) {
//     //     //Allow only elements that don't have the 'checked' property
//     //     //Or those who have it, and it's checked for them.
//     //     return typeof(el.checked) === 'undefined' || el.checked;
//     //     //Practically, filter out checkboxes/radios which aren't checekd.
//     // })
//     //     // .filter(function(el) { return !!el.name; }) //Nameless elements die.
//     //     //     .filter(function(el) { return el.disabled; }) //Disabled elements die.
//     // .map(function(el) {
//     //     //Map each field into a name=value string, make sure to properly escape!
//     //     return encodeURIComponent(el.name) + '=' + encodeURIComponent(el.value);
//     // }).join('&'); //Then join all the strings by &

//     xhr.open("POST", url);
//     xhr.setRequestHeader("Content-type", "application/x-form-urlencoded");

//     //.bind ensures that this inside of the function is the XHR object.
//     xhr.onload = callback.bind(xhr); 

//     //All preperations are clear, send the request!
//     // xhr.send();
//     xhr.send(params);
// }


/* Pause */
app.ports.pause.subscribe(function(){
    var player = document.getElementsByTagName("audio")[0];
    if (!player)  {return;}
    if (player.paused) {
        player.play();
    } else {
        player.pause();
    }
});

// /* Album Art */
// app.ports.lookupAlbumArt.subscribe(function(albumName){
//     // console.log("searching for album art...");
//     // dbUtils.findById(albumName + "-album").then(function(doc){
//     //     app.ports.updateAlbumArt.send(doc.picture);
//     // });
// });

