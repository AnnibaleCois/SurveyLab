/* User interface scripts - design page, v 1.0, 01/05/2023 */
/* Annibale Cois (acois@sun.ac.za)*/    

/* Sortable */

$("#tool, #quest, #meas").sortable({
          connectWith: ".connectedSortable"
        }).disableSelection();

$("#tool, #quest, #meas").sortable({
                      update: function( event, ui ) {
                        tool_items = $("#tool").sortable("toArray", {attribute: "data"}).map(Number); 
                        tool_qnum = 0; tool_mnum = 0;
                        tool_quest.QCODE.forEach(function(elem) {if (tool_items.includes(elem)) {tool_qnum = tool_qnum + 1;}});
                        tool_meas.QCODE.forEach(function(elem) {if (tool_items.includes(elem)) {tool_mnum = tool_mnum + 1;}});
                        tool_qtime = Number(tool_qnum) * tool_tq + Number(tool_mnum) * tool_tm; 
                        
                        Shiny.setInputValue("tool_qnum", tool_qnum);
                        Shiny.setInputValue("tool_mnum", tool_mnum);
                        Shiny.setInputValue("tool_items", tool_items);
                        
                        document.getElementById("qitems_design").innerHTML = tool_qnum;
                        document.getElementById("mitems_design").innerHTML = tool_mnum;
                        document.getElementById("time_design").innerHTML = tool_qtime + " [min]";
                        
                        document.getElementById("qitems_survey").innerHTML = tool_qnum;
                        document.getElementById("mitems_survey").innerHTML = tool_mnum;
                        document.getElementById("time_survey").innerHTML = tool_qtime + " [min]";
                        
                        document.getElementById("qitems_analyse").innerHTML = tool_qnum;
                        document.getElementById("mitems_analyse").innerHTML = tool_mnum;
                        document.getElementById("time_analyse").innerHTML = tool_qtime + " [min]";
                        
                      }
                  })

/* Other */

function updateTools(items){
  document.getElementById("tool").innerHTML = "";
  document.getElementById("quest").innerHTML = "";
  document.getElementById("meas").innerHTML = "";
  tool_qnum = 0;
  tool_mnum = 0;

  for(let i = 0; i < tool_quest.QCODE.length; i++) {
    if (!items.includes(tool_quest.QCODE[i])) {
      $("#quest").append("<li class='qi' data='"+ tool_quest.QCODE[i] + "'>" + tool_quest.ITEM[i] + "</li>");
    } else {
      $("#tool").append("<li class='qi' data='"+ tool_quest.QCODE[i] + "'>" + tool_quest.ITEM[i] + "</li>");  
      tool_qnum = tool_qnum + 1;
    }
  };  
  
  for(var i = 0; i < tool_meas.QCODE.length; i++) {
    if (!items.includes(tool_meas.QCODE[i])) {
      $("#meas").append("<li class='mi' data='"+ tool_meas.QCODE[i] + "'>" + tool_meas.ITEM[i] + "</li>");
    } else {
      $("#tool").append("<li class='mi' data='"+ tool_meas.QCODE[i] + "'>" + tool_meas.ITEM[i] + "</li>");
      tool_mnum = tool_mnum + 1;
    }
  }; 
  
  tool_qtime = Number(tool_qnum) * tool_tq + Number(tool_mnum) * tool_tm;  // Total administration time

  // Sync tool on R side
  
  Shiny.setInputValue('tool_qnum', tool_qnum);
  Shiny.setInputValue('tool_mnum', tool_mnum);
  Shiny.setInputValue('tool_items', items);

}

function resetTool(){
  tool_items = [];
  updateTools(tool_items);
}

function saveTool(){
        let displayed_tool = $('#tool').sortable('toArray', {attribute: 'data'});
        tool_items = displayed_tool;
}

function loadTool(){

}

Shiny.addCustomMessageHandler("handler_survey_questvar",
    function(data) {
      let LOUT = "";
      let CLOUT = "<option value='NONE'>None</option><option value='REGION'>Region</option><option value='TOWN'>Town</option><option value='SUBURB'>Suburb</option>";
      let item = data[0];
      let variable = data[1];
      let citem = data[2];
      let cvariable = data[3];
      for (let i = 1; i < item.length; i++) {
          LOUT = LOUT + "<option value='" + variable[i] + "'>" + item[i] +"</option>";
      }
      
      for (let j = 1; j < citem.length; j++) {
         CLOUT = CLOUT + "<option value='" + cvariable[j] + "'>" + citem[j] +"</option>";
      }
      
     // Update outcome list in power tab
     document.getElementById('eoutcome').innerHTML = LOUT;  
     // Update outcome list in share tab
     //document.getElementById('outcome_share').innerHTML =  LOUT;  
     // Update outcome and group lists in analysis tab
     document.getElementById('anvar').innerHTML = LOUT;  
     document.getElementById('angroup').innerHTML = CLOUT;  

    }
)
