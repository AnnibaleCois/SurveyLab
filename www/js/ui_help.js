/* User interface scripts - help snippets loads, v 4.0, 01/09/2025 */
/* Annibale Cois (annibale.cois@mrc.ac.za)*/    

const helpfiles = ["explore","design","sample","strategy","power","survey","analyse","upload","visualise","users"];

let file = "";

$(document).ready(function () {
  for (let i = 0; i < helpfiles.length; i++) {
    let file = helpfiles[i];
    $("#help_" + file).load("./help/help_pages.html #" + file);
  }
});