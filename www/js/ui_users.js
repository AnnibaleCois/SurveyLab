/* User interface scripts - users page, v 4.0, 01/09/2025 */
/* Annibale Cois (annibale.cois@mrc.ac.za)*/    

Shiny.addCustomMessageHandler("handler_users_table",
  function(data) {
    // Table
    TABLE = transformToPairValueFormat(data[0]);
    var table = new Tabulator("#usertable", {
    selectableRows:1,
    rowHeader:{formatter:"rowSelection", titleFormatter:false, resizable: false, frozen:true, headerHozAlign:"center", hozAlign:"center"},
    height: "300px",
    data:TABLE, //assign data to table
    autoColumns:true //create columns from data field names
  });
  USERTABLE = table;
 }
);

Shiny.addCustomMessageHandler("handler_users_current",
  function(data) {
    document.getElementById("currentusers").innerHTML = data[0];
  }
);

function addUser(FORM){
  Shiny.setInputValue('add_users',[FORM.user_user.value,FORM.name_user.value,FORM.permissions_user.value]);
}

function addUserbase(FORM){ 
  Shiny.setInputValue('add_userbase',[FORM.file_user.value, document.getElementById("confirm_user").checked,Math.random()]);
}

function removeUsers(){
  let selectedData = USERTABLE.getSelectedData(); //get array of currently selected data
  let dusers = [];
  if (selectedData.length > 0) {
    for (i = 0; i < selectedData.length; i++) {
      dusers.push(selectedData[i].user) 
    }
  }
  Shiny.setInputValue('delete_users',dusers);
}

