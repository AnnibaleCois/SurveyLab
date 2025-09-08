/* User interface scripts - share page, v 4.0, 01/09/2025 */
/* Annibale Cois (annibale.cois@mrc.ac.za)*/    

function shareEstimates(FORM){
  VARS = [0, FORM.estimate_share.value, FORM.lb_share.value, FORM.ub_share.value, FORM.notes_share.value];
  Shiny.setInputValue('estimates_share',VARS);
}

function shareResults(){
  Shiny.setInputValue('results_share_trigger',Math.random());
}

function resetShareEstimates(){
  VARS = [-1];
  Shiny.setInputValue('estimates_share',VARS);
}

function deleteShareEstimates(){
  let selectedData = SHARETABLE.getSelectedData(); //get array of currently selected data
  let dshared = [];
  if (selectedData.length > 0) {
  for (i = 0; i < selectedData.length; i++) {
    dshared.push(selectedData[i].N) 
  }
  }
  Shiny.setInputValue('delete_share',[dshared,Math.random()]);
}

function refreshShareEstimates(){
  Shiny.setInputValue('refresh_share_trigger',Math.random());
}

function transformToPairValueFormat(data) {
  const obj = data; // Assuming only one object in the array
  const keys = Object.keys(obj);
  const length = obj[keys[0]].length;
  const result = [];
  for (let i = 0; i < length; i++) {
    const entry = {};
    keys.forEach(key => {
      entry[key] = obj[key][i];
    });
    result.push(entry);
  }
  return result;
}

function transformToColumnFormat(data) {
  if (!data || !Array.isArray(data.rows) || data.rows.length === 0) return {};

  const result = {};
  const keys = Object.keys(data.rows[0]);

  keys.forEach(key => {
    result[key] = data.rows.map(row => row[key]);
  });

  return result;
}

function transformToMatrix(data) {
  if (!data || !Array.isArray(data.rows) || data.rows.length === 0) return [];

  const keys = Object.keys(data.rows[0]).sort((a,b) => a - b); // ensure numeric order
  const matrix = data.rows.map(row => keys.map(k => row[k]));

  return matrix;
}

 // Plugin to add padding to Y-axis
    Chart.plugins.register({
      beforeUpdate: function(chart) {
        const yScale = chart.scales['y-axis-0'];
        if (!yScale) return;

        const data = chart.data.datasets.reduce((all, ds) => all.concat(ds.data), []);
        const min = Math.min.apply(null, data);
        const max = Math.max.apply(null, data);

        const range = max - min;
        const padding = range * 0.1; // 10% padding

        yScale.options.ticks.min = min - padding;
        yScale.options.ticks.max = max + padding;
      }
    });

Shiny.addCustomMessageHandler("handler_shared_table",
  function(data) {
    // Table
    TABLE = transformToPairValueFormat(data[0]);
    var table = new Tabulator("#sharedtable", {
    selectableRows:1,
    rowHeader:{formatter:"rowSelection", titleFormatter:false, headerSort:false, resizable: false, frozen:true, headerHozAlign:"center", hozAlign:"center"},
    height: "300px",
    data:TABLE, //assign data to table
    autoColumns:true //create columns from data field names
  });
  SHARETABLE = table;
  
  // Plot 
  
  var estimateData = data[0].Estimate.map(x => parseFloat(x));
  var lbData = data[0].lb.map(x => parseFloat(x));
  var ubData = data[0].ub.map(x => parseFloat(x));
  var labels = Array.from({length: parseInt(data[1])}, (_, i) => i + 1);
  
  var errorBarPlugin = {  // Plugin to draw error bars
    afterDatasetsDraw: function(chart) {
      var ctx = chart.chart.ctx;
      var xScale = chart.scales['x-axis-0'];
      var yScale = chart.scales['y-axis-0'];
      
      ctx.save();
      ctx.strokeStyle = '#000000';
      ctx.lineWidth = 1;
      ctx.setLineDash([5, 3]);
  
      estimateData.forEach(function(value, index) {
        var x = xScale.getPixelForValue(labels[index]);
        var yTop = yScale.getPixelForValue(ubData[index]);
        var yBottom = yScale.getPixelForValue(lbData[index]);
  
        // Vertical line
        ctx.beginPath();
        ctx.moveTo(x, yTop);
        ctx.lineTo(x, yBottom);
        ctx.stroke();
  
        // Caps
        var capWidth = 5;
        ctx.beginPath();
        ctx.moveTo(x - capWidth, yTop);
        ctx.lineTo(x + capWidth, yTop);
        ctx.moveTo(x - capWidth, yBottom);
        ctx.lineTo(x + capWidth, yBottom);
        ctx.stroke();
      });
  
      ctx.restore();
    }
  };
 
  new Chart("sharedplot", {
    type: "line",
    data: {
      labels: labels,
      datasets: [
        {
          label:"Lower bound",
          data: lbData,
          fill: false,
          borderColor:'#FFFFFF00', // invisible line
          pointStyle: 'line',
          pointBackgroundColor: '#000000',
          pointBorderColor:'#000000',
          pointBorderWidth: 3,  
          pointRadius: 5,  
          tension: 0.1
        },
        {
          label:"Upper bound",
          data: ubData,
          fill: false,
          borderColor:'#FFFFFF00', // invisible line
          pointStyle: 'line',
          pointBackgroundColor: '#000000',
          pointBorderColor:'#000000',
          pointBorderWidth: 3,  
          pointRadius: 5,  
          tension: 0.1
        },
        {
          label:"Estimate",
          data: estimateData,
          fill: false,
          borderColor: '#FFFFFF00',
          pointStyle: 'circle',
          pointBackgroundColor: '#DE2D26',
          pointBorderColor:'#DE2D26',
          pointRadius: 5, 
          tension: 0.1
        }
      ]
    },
    options: {
      responsive: true,
      plugins: {legend: {display: false}},
      scales: {
        xAxes: [{ticks: {autoSkip: false}, scaleLabel: {display: true, labelString: "Survey"}}],
        yAxes: [{scaleLabel: {display: true, labelString: "Estimate"}}]
      }
    },
    plugins: [errorBarPlugin]
  }) 

 }
);
