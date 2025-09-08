/* User interface scripts - settings pages, v 4.0, 01/09/2025 */
/* Annibale Cois (annibale.cois@mrc.ac.za)*/    

let thrp = {}; 
let tirp = {}; 

Shiny.addCustomMessageHandler("handler_settings_tables",
  function(data) {
    // Tables
    TABLE1 = transformToPairValueFormat(data[0]);
    var table1 = new Tabulator("#hrespprobtable", {
    height: "150px",
    data:TABLE1, //assign data to table
    columns: [
      {title:"Wealth Tertile", field:"0"},
      {title:"Consent", field:"1", editor:"input"},
      {title:"Refusal", field:"2", editor:"input"},
      {title:"Absent", field:"3", editor:"input"}
    ]
  });
  thrp = table1;
  
  TABLE2 = transformToPairValueFormat(data[1]);
    var table2 = new Tabulator("#irespprobtable", {
    height: "120px",
    data:TABLE2, //assign data to table
    columns: [
      {title:"Sex", field:"0"},
      {title:"0-4", field:"1", editor:"input"},
      {title:"5-9", field:"2", editor:"input"},
      {title:"10-14", field:"3", editor:"input"},
      {title:"15-24", field:"4", editor:"input"},
      {title:"25-34", field:"5", editor:"input"},
      {title:"35-44", field:"6", editor:"input"},
      {title:"45-54", field:"7", editor:"input"},
      {title:"55-64", field:"8", editor:"input"},
      {title:"65+", field:"9", editor:"input"}
    ]
  });
  tirp = table2;
  document.getElementById("fatiguecoeff").value = data[2];
  document.getElementById("randomseeds").value = data[3];
  
 }
);

function updateSettings() {
  let updatedData1 = thrp.getData();
  let uthrp = {rows: updatedData1};
  let uthrp1 = transformToMatrix(uthrp)
 
  let updatedData2 = tirp.getData();
  let utirp = {rows: updatedData2};
  let utirp1 = transformToMatrix(utirp)
 
  let fatig = document.getElementById("fatiguecoeff").value;
  let rseed = document.getElementById("randomseeds").value;
  
  Shiny.setInputValue('update_settings',[[uthrp1],[utirp1],[fatig],[rseed]]);
  
}

function resetSettings() {
  Shiny.setInputValue('default_settings_trigger', Math.random());
}

