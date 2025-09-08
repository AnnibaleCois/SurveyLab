/* User interface scripts - explore page, v 3.0, 04/2024 */
/* Annibale Cois (annibalecois@gmail.com) */    

// Show/hide map layers and reset to initial status 

function showhide(x) {
  let y;
  if (document.getElementById("breg").checked) {
    y = document.getElementById("stateLabels");
    y.style.visibility = "visible";
    y = document.getElementById("regions");
    y.style.visibility = "visible";
  } else {
    y = document.getElementById("stateLabels");
    y.style.visibility = "hidden";
    y = document.getElementById("regions");
    y.style.visibility = "hidden";
  };
  
  if (document.getElementById("btow").checked) {
    y = document.getElementById("burgLabels");
    y.style.visibility = "visible";
    y = document.getElementById("icons");
    y.style.visibility = "visible";
  } else {
    y = document.getElementById("burgLabels");
    y.style.visibility = "hidden";
    y = document.getElementById("icons");
    y.style.visibility = "hidden";
  };
  
  if (document.getElementById("bele").checked) {
    y = document.getElementById("terrs");
    y.style.visibility = "visible";
  } else {
    y = document.getElementById("terrs");
    y.style.visibility = "hidden";
  } ;

  if (document.getElementById("briv").checked) {
    y = document.getElementById("rivers");
    y.style.visibility = "visible";
    y = document.getElementById("lakes");
    y.style.visibility = "visible";
  } else {
    y = document.getElementById("rivers");
    y.style.visibility = "hidden";
    y = document.getElementById("lakes");
    y.style.visibility = "hidden";
  };    
  
  if (document.getElementById("btem").checked) {
    y = document.getElementById("temperature");
    y.style.visibility = "visible";
  } else {
    y = document.getElementById("temperature");
    y.style.visibility = "hidden";
  };  
  
  if (document.getElementById("bhaz").checked) {
    y = document.getElementById("hazards");
    y.style.visibility = "visible";
  } else {
    y = document.getElementById("hazards");
    y.style.visibility = "hidden";
  }; 
  
  
}

function resetlayers(x) {
  y = document.getElementById("breg");
  y.checked = true;
  y = document.getElementById("btow");
  y.checked = true;       
  y = document.getElementById("bele");
  y.checked = false;
  y = document.getElementById("briv");
  y.checked = false;
  y = document.getElementById("btem");
  y.checked = false;
  y = document.getElementById("bhaxm");
  y.checked = false;
  showhide("reset");
}
  
// Popup management 

  // Creates tables from json arrays

function tableMaker(o) {
  var keys = Object.keys(o[0]);
  rowMaker = (a,t) => a.reduce((p,c,i,a) => p + (i === a.length-1 ? "<" + t + ">" + c + "</" + t + "></tr>": "<" + t + ">" + c + "</" + t + ">"),"<tr>");
  rows = o.reduce((r,c) => r + rowMaker(keys.reduce((v,k) => v.concat(c[k]),[]),"td"), rowMaker(keys,"th"));
  return "<table>" + rows + "</table>";
};

  // Generate content for the Region info popup 

Shiny.addCustomMessageHandler("handler_popup_region",
    function(data) {
      let rstat = data[0];
      let tstat = data[1];
      document.getElementById('rname').innerHTML = rstat.Region_Name;
      document.getElementById('renv').innerHTML = rstat.Eoffice;  
      document.getElementById('rclin').innerHTML = rstat.Mclinic;     
      document.getElementById('rhos').innerHTML = rstat.Hospital;
      document.getElementById('recap').innerHTML = rstat.Capital;
      document.getElementById('rpop').innerHTML = rstat.Population;
      document.getElementById('rwea').innerHTML = rstat.Mean_Wealth;
      document.getElementById('rgini').innerHTML = rstat.Gini_Wndex;
      var table = new Tabulator("#rtowns", {
      data:tstat, //assign data to table
      autoColumns:true, //create columns from data field names
      height: "200px"
      });
      
      let regionmap = "img/" + rstat.Region_Code + ".png";
      //document.getElementById('regmap').innerHTML = "<img src='"+ regionmap +"' width= 410 style = 'margin-bottom: 20px;' />";  
      document.getElementById('rpopup').style.background = "url('" + regionmap + "')";
  }                               
); 

  // Set the current value of the region 

function rstats(regname) {
    Shiny.setInputValue("regionstats", regname);
};


