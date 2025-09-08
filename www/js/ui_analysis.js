/* User interface scripts - survey page, v 1.0, 14/09/2024 */
/* Annibale Cois (annibale.cois@mrc.ac.za)*/    


function updateAnalysis(){
 
  let newunitcost = "-";
    if (survey_rr[0]*survey_rr[1] > 0) {
      newunitcost = Math.round(document.getElementById("unitcost_rea_analyse").innerHTML/(survey_rr[0]*survey_rr[1])*100*100*100)/100;
    }
    
    document.getElementById("unitcost_rea_analyse").innerHTML = newunitcost;
    document.getElementById("anhrr").innerHTML = survey_rr[0] + "%";
    document.getElementById("anirr").innerHTML = survey_rr[1] + "%";
    document.getElementById("antrr").innerHTML = survey_rr[0]*survey_rr[1]/100 + "%";
}


Shiny.addCustomMessageHandler("handler_survey_collect",
  function(data) {
    survey_responses = data[0];        // Full table of responses
    survey_items = data[1];            // Tool items
    survey_type = data[2];             // Type of tool items
    survey_varlist = data[3];          // Variables include in table of responses
    survey_hconsent = data[4];         // Number of consenting households
    survey_iconsent = data[5];         // Number of consenting individuals
    survey_rr = data[6];               // Response rates (household, Individual)
    survey_rrr = data[7];              // Response rates per region (household, Individual)
    survey_trr = data[8];              // Response rates per town (household, Individual)
    survey_dsize = data[9]             // Number of records in the response dataset
    survey_time = data[10]             // Time of teh curremnt survey
    
    document.getElementById("anhrr").innerHTML = survey_rr[0] + "%";
    document.getElementById("anirr").innerHTML = survey_rr[1] + "%";
    document.getElementById("antrr").innerHTML = Math.round(survey_rr[0]*survey_rr[1]/100*10)/10 + "%";
    document.getElementById("unitcost_rea_analyse").innerHTML = Math.round(document.getElementById("totcost_analyse").innerHTML/survey_iconsent*100)/100;
    
    document.getElementById("dataset_share").innerHTML = survey_dsize > 0 ? "Available" : "None available";
    document.getElementById("size_share").innerHTML = survey_dsize > 0 ? survey_dsize : "---";
    document.getElementById("time_share").innerHTML = survey_dsize > 0 ? survey_time : "---";
    
    if (eupload == 1) { 
      document.getElementById("result_share").disabled =  survey_dsize > 0 ? false : true;
    } else {
      document.getElementById("result_share").disabled = true;
    }
    
    document.getElementById("surveyprogress").style.visibility = "visible";
    document.getElementById("surveyspinner").style.visibility = "hidden";
    
    let HbarColors = ["#A6BDDB","#A6BDDB","#A6BDDB","#A6BDDB","#A6BDDB"];
    let IbarColors = ["#2B8CBE","#2B8CBE","#2B8CBE","#2B8CBE","#2B8CBE"];
    let pColors = ["#2CA25F","#DE2D26"];
    let totrr = Math.round(survey_rr[0]*survey_rr[1]/100*10)/10;
    let ntotrr = Math.round((100 - totrr)*10)/10;
    
    new Chart("rr", {
      type: "horizontalBar",
      data: {
        labels: ["Response (" + totrr + "%)", "Non response (" +  ntotrr + "%)"],
        datasets: [{
          backgroundColor: pColors,
          data: [totrr, 100 - totrr]
        }]
      },
      options: {
        maintainAspectRatio: false,
        title: {display: false},
        legend: {
            display: false 
        }
      }
    });
    
    new Chart("regrr", {
  type: "bar",
  data: {
    labels: survey_rrr.Region,
    datasets: [{
      label:"Household",
      backgroundColor: HbarColors,
      data: survey_rrr.HRR
    },{
      label:"individual",
      backgroundColor: IbarColors,
      data: survey_rrr.IRR
    }
    ]
  },
  options: {
    maintainAspectRatio: false,
    legend: {display: true},
    title: {display: false},
    scales: {
      yAxes: [{
        ticks: {
          precision: 0,
          beginAtZero: true,
          max: 100,
          steps: 10
        }
      }]
    }
  }
  
});
    
const survey_trr_t = survey_trr.Town.map((town, i) => ({
  Town: town,
  Region: survey_trr.Region_Name[i],
  HRR: survey_trr.HRR[i],
  IRR: survey_trr.IRR[i],
  TRR: Math.round(survey_trr.HRR[i]*survey_trr.IRR[i]/100) 
}));

var tablerr = new Tabulator("#towrr", {
  height:"250px",
  layout:"fitDataFill",
  groupBy:"Region",
  columns:[
    {title:"Town", field:"Town", width:150},
    {title:"Household [%]", field:"HRR"},
    {title:"Individual [%]", field:"IRR"},
    {title:"Total[%]", field:"TRR", width:450, formatter:"progress", formatterParams:{color:["#DE2D26", "#E6550D", "#2CA25F"], legend: true, legendAlign: "left"}, sorter:"number"}
    ],
  data: survey_trr_t
});

}); 

Shiny.addCustomMessageHandler("handler_analysis_sample",
  function(data) {
    TABLE = data[0];        // Sample statistics
    var table = new Tabulator("#ansamplestimates", {
    data:TABLE, //assign data to table
    autoColumns:true //create columns from data field names
});
  }   
);  

Shiny.addCustomMessageHandler("handler_analysis_pop",
  function(data) {
    TABLE = data[0];        // Population values
    var table = new Tabulator("#anpopestimates", {
    data:TABLE, //assign data to table
    autoColumns:true //create columns from data field names
});
  }   
);  

function sampleAnalysis(FORM){
  VARS = [FORM.anvar.value, FORM.angroup.value,Math.random()*1000];
  Shiny.setInputValue('survey_sample_vars',VARS);
}

function popAnalysis(FORM){
  VARS = [FORM.antarget.value, Math.random()*1000];
  Shiny.setInputValue('survey_pop_vars',VARS);
}
