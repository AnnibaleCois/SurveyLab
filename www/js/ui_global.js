/* User interface scripts - global variables, v 4.0, 10/06/2025 */
/* Annibale Cois (annibale.cois@mrc.ac.za) */    

// Interface status

let int_currentTown_sample = 1;
let int_currentTown_explore = 0;
let int_currentHousehold = "";
let int_currentMembers = [];
let int_currentSampled = [];
let int_newSampled = [];

// Other flags

let oth_download = 0

// Environment

let ntowns = 0;

// Sample 

let sam_currentSample_tlist = [];
let sam_currentSample_tsize = 0;

let sam_currentSample_hlist = [];
let sam_currentSample_hsize = [0];

let sam_currentSample_ilist = [];
let sam_currentSample_isize = [0];

let sam_currentSample_tisize = 0;
let sam_currentSample_thsize = 0;

// Strategy

let mon_targetRegions = [1,1,1,1,1];

// Data collection tool    

let tool_items = [];
let tool_qnum = 0;
let tool_mnum = 0;
let tool_qtime = 0;
let tool_qscale = 1;

// Survey  

let survey_setupcost = 0;
let survey_collectcost = 0;
let survey_totcost = 0;
let survey_unitcost = 0;

let survey_responses = [];        // Full table of responses
let survey_items = [];            // Tool items
let survey_type = [];             // Type of tool items
let survey_varlist = [];          // Variables included in table of responses
let survey_varquest = [];         // Variables corresponding to questionnaire items
let survey_hconsent = 0;          // Number of consenting households
let survey_iconsent = 0;          // Number of consenting individuals
let survey_rr = [];               // Response rates (household, Individual)
let survey_rrr = [];              // Response rates per region (household, Individual)
let survey_trr = [];              // Response rates per town (household, Individual)

let survey_collected = [];        // List of towns surveyed
let nhsampled = 0;
let nisampled = 0;
let nhsampledp = "";
let nisampledp = "";

// Parameters

let tool_quest = [];    // Available questions
let tool_meas = [];     // Available measurements
let tq = 0;             // Time for administering a question
let tm = 0;             // Time for administering a measurement

let itemtime = 0;       // Base time for each item of the questionnaire
let qqprogress = 0;     // Multiplier of base time for self-report items
let qmprogress = 0;     // Multiplier of base time for measurement items

let categorical = [];   // Categorical variables in P dataset
let continuous = [];    // Continuous variables in P dataset

// Global tables

let USERTABLE = null;
let SHARETABLE = null;

//Other settings 

let eupdate = 0;

// Get initial values of parameters from R (constant within session, initialised at inception)
Shiny.addCustomMessageHandler("handler_parameters_initialize",
  function(data) {
    tool_quest = data[0];
    tool_meas = data[1];
    tool_items = data[2];
    tool_tq = Number(data[3]);
    tool_tm = Number(data[4]);
    envir_towns = data[5];
    itemtime = data[6];
    qqprogress = data[7]; 
    qmprogress = data[8];
    categorical = data[9];
    continuous = data[10];
    tcolors = data[11];
    ntowns = data[12];
    regioncolors = data[13];
    regioncolors_accent = data[14];
    tool_qscale = data[14];
    eupload = Number(data[16]);

    sam_currentSample_hlist = [];
    sam_currentSample_ilist = [];
    sam_currentSample_hsize = [0];
    sam_currentSample_isize = [0];

    for (let i = 0; i < 110; i++) {
      sam_currentSample_hlist.push([]);
      sam_currentSample_ilist.push([]);
      sam_currentSample_hsize.push(0);
      sam_currentSample_isize.push(0);
    }
  }   
);   

