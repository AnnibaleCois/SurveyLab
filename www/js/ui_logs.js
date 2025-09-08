/* User interface scripts - logs page, v 4.0, 01/09/2025 */
/* Annibale Cois (annibale.cois@mrc.ac.za)*/    


Shiny.addCustomMessageHandler("handler_logs",
  function(data) {
    let message = data[0];
    let user = data[1];
    let where = data[2];
    const textarea = document.getElementById('serverlogs');
    const newText = `${new Date().toLocaleTimeString()}, ` + user + `, ` + where + `: ` + message +`\n`;
    textarea.value += newText;
    textarea.scrollTop = textarea.scrollHeight;
});

function resetLogs(){
  const textarea = document.getElementById('serverlogs');
  textarea.value = '';
}
