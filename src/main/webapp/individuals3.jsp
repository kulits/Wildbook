<%@ page contentType="text/html; charset=utf-8" language="java"
         import="com.drew.imaging.jpeg.JpegMetadataReader,com.drew.metadata.Metadata,com.drew.metadata.Tag,org.ecocean.mmutil.MediaUtilities,
javax.jdo.datastore.DataStoreCache, org.datanucleus.jdo.*,javax.jdo.Query,
org.datanucleus.api.rest.orgjson.JSONObject,
org.datanucleus.ExecutionContext,
		 org.joda.time.DateTime,org.ecocean.*,org.ecocean.social.*,org.ecocean.servlet.ServletUtilities,java.io.File, java.util.*, org.ecocean.genetics.*,org.ecocean.security.Collaboration, com.google.gson.Gson,
org.datanucleus.api.rest.RESTUtils, org.datanucleus.api.jdo.JDOPersistenceManager" %>

<%
String blocker = "";
String context="context0";
context=ServletUtilities.getContext(request);
  //handle some cache-related security
  response.setHeader("Cache-Control", "no-cache"); //Forces caches to obtain a new copy of the page from the origin server
  response.setHeader("Cache-Control", "no-store"); //Directs caches not to store the page under any circumstance
  response.setDateHeader("Expires", 0); //Causes the proxy cache to see the page as "stale"
  response.setHeader("Pragma", "no-cache"); //HTTP 1.0 backward compatibility

  //setup data dir
  String rootWebappPath = getServletContext().getRealPath("/");
  File webappsDir = new File(rootWebappPath).getParentFile();
  File shepherdDataDir = new File(webappsDir, CommonConfiguration.getDataDirectoryName(context));
  //if(!shepherdDataDir.exists()){shepherdDataDir.mkdirs();}
  File encountersDir=new File(shepherdDataDir.getAbsolutePath()+"/encounters");
  //if(!encountersDir.exists()){encountersDir.mkdirs();}
  //File thisEncounterDir = new File(encountersDir, number);

//setup our Properties object to hold all properties
  Properties props = new Properties();
  //String langCode = "en";
  String langCode=ServletUtilities.getLanguageCode(request);



  //load our variables for the submit page

 // props.load(getClass().getResourceAsStream("/bundles/" + langCode + "/individuals.properties"));
  props = ShepherdProperties.getProperties("individuals.properties", langCode,context);

	Properties collabProps = new Properties();
 	collabProps=ShepherdProperties.getProperties("collaboration.properties", langCode, context);


  String markedIndividualTypeCaps = props.getProperty("markedIndividualTypeCaps");
  String nickname = props.getProperty("nickname");
  String nicknamer = props.getProperty("nicknamer");
  String alternateID = props.getProperty("alternateID");
  String sex = props.getProperty("sex");
  String setsex = props.getProperty("setsex");
  String numencounters = props.getProperty("numencounters");
  String encnumber = props.getProperty("number");
  String dataTypes = props.getProperty("dataTypes");
  String date = props.getProperty("date");
  String size = props.getProperty("size");
  String spots = props.getProperty("spots");
  String location = props.getProperty("location");
  String mapping = props.getProperty("mapping");
  String mappingnote = props.getProperty("mappingnote");
  String setAlternateID = props.getProperty("setAlternateID");
  String setNickname = props.getProperty("setNickname");
  String unknown = props.getProperty("unknown");
  String noGPS = props.getProperty("noGPS");
  String update = props.getProperty("update");
  String additionalDataFiles = props.getProperty("additionalDataFiles");
  String delete = props.getProperty("delete");
  String none = props.getProperty("none");
  String addDataFile = props.getProperty("addDataFile");
  String sendFile = props.getProperty("sendFile");
  String researcherComments = props.getProperty("researcherComments");
  String edit = props.getProperty("edit");
  String matchingRecord = props.getProperty("matchingRecord");
  String tryAgain = props.getProperty("tryAgain");
  String addComments = props.getProperty("addComments");
  String record = props.getProperty("record");
  String getRecord = props.getProperty("getRecord");
  String allEncounters = props.getProperty("allEncounters");
  String allIndividuals = props.getProperty("allIndividuals");

  String name = request.getParameter("number").trim();
  Shepherd myShepherd = new Shepherd(context);


	List<Collaboration> collabs = Collaboration.collaborationsForCurrentUser(request);

%>
<%
if (request.getParameter("number")!=null) {
	myShepherd.beginDBTransaction();
		if(myShepherd.isMarkedIndividual(name)){
			MarkedIndividual indie=myShepherd.getMarkedIndividual(name);
			Vector myEncs=indie.getEncounters();
			int numEncs=myEncs.size();

			if (request.getParameter("refreshDependentProperties") != null) {
				indie.refreshDependentProperties(context);
				myShepherd.getPM().makePersistent(indie);
				myShepherd.commitDBTransaction();
/*  i cannot get this to effect the results of the rest api.  :(  TODO
				DataStoreCache cache = myShepherd.getPM().getPersistenceManagerFactory().getDataStoreCache();
				if (cache != null) {
					System.out.println("cache evict!!!");
					//cache.evictAll();
					cache.evict(indie);
				}
*/
				System.out.println("refreshDependentProperties() forced via individuals.jsp");
			}

			boolean visible = indie.canUserAccess(request);

			if (!visible) {
  			ArrayList<String> uids = indie.getAllAssignedUsers();
				ArrayList<String> possible = new ArrayList<String>();
				for (String u : uids) {
					Collaboration c = null;
					if (collabs != null) c = Collaboration.findCollaborationWithUser(u, collabs);
					if ((c == null) || (c.getState() == null)) {
						User user = myShepherd.getUser(u);
						String fullName = u;
						if (user.getFullName()!=null) fullName = user.getFullName();
						possible.add(u + ":" + fullName.replace(",", " ").replace(":", " ").replace("\"", " "));
					}
				}
				String cmsg = "<p>" + collabProps.getProperty("deniedMessage") + "</p>";
				cmsg = cmsg.replace("'", "\\'");

				if (possible.size() > 0) {
    			String arr = new Gson().toJson(possible);
					blocker = "<script>$(document).ready(function() { $.blockUI({ message: '" + cmsg + "' + _collaborateMultiHtml(" + arr + ") }) });</script>";
				} else {
					cmsg += "<p><input type=\"button\" onClick=\"window.history.back()\" value=\"BACK\" /></p>";
					blocker = "<script>$(document).ready(function() { $.blockUI({ message: '" + cmsg + "' }) });</script>";
				}
			}



}
		myShepherd.rollbackDBTransaction();
}
%>

  <style type="text/css">
    <!--
    .style1 {
      color: #000000;
      font-weight: bold;
    }

    table.adopter {
      border-width: 1px 1px 1px 1px;
      border-spacing: 0px;
      border-style: solid solid solid solid;
      border-color: black black black black;
      border-collapse: separate;
      background-color: white;
    }

    table.adopter td {
      border-width: 1px 1px 1px 1px;
      padding: 3px 3px 3px 3px;
      border-style: none none none none;
      border-color: gray gray gray gray;
      background-color: white;
      -moz-border-radius: 0px 0px 0px 0px;
      font-size: 12px;
      color: #330099;
    }

    table.adopter td.name {
      font-size: 12px;
      text-align: center;
    }

    table.adopter td.image {
      padding: 0px 0px 0px 0px;
      border-width: 0px 0px 0px 0px;
      margin: 0px;
    }

    div.scroll {
      height: 200px;
      overflow: auto;
      border: 1px solid #666;
      background-color: #ccc;
      padding: 8px;
    }

table.tissueSample {
    border-width: 1px;
    border-spacing: 2px;
    border-color: gray;
    border-collapse: collapse;
    background-color: white;
}
table.tissueSample th {
    border-width: 1px;
    padding: 1px;
    border-style: solid;
    border-color: gray;
    background-color: #99CCFF;
    -moz-border-radius: ;
}
table.tissueSample td {
    border-width: 1px;
    padding: 2px;
    border-style: solid;
    border-color: gray;
    background-color: white;
    -moz-border-radius: ;
}


	.collab-private {
		background-color: #FDD;
	}

	.collab-private td {
		background-color: transparent !important;
	}

	.collab-private .collab-icon {
		position: absolute;
		left: -15px;
		z-index: -1;
		width: 13px;
		height: 13px;
		background: url(images/lock-icon-tiny.png) no-repeat;
	}

	tr.clickable:hover td {
		background-color: #EFA !important;
	}

    -->
  </style>


    <jsp:include page="header.jsp" flush="true"/>


  <!--
    1 ) Reference to the files containing the JavaScript and CSS.
    These files must be located on your server.
  -->

  <script type="text/javascript" src="highslide/highslide/highslide-with-gallery.js"></script>
  <link rel="stylesheet" type="text/css" href="highslide/highslide/highslide.css"/>

  <!--
    2) Optionally override the settings defined at the top
    of the highslide.js file. The parameter hs.graphicsDir is important!
  -->

  <script type="text/javascript">
    hs.graphicsDir = 'highslide/highslide/graphics/';

    hs.transitions = ['expand', 'crossfade'];
    hs.outlineType = 'rounded-white';
    hs.fadeInOut = true;
    //hs.dimmingOpacity = 0.75;

    hs.align = 'auto';
  	hs.anchor = 'top';

    //define the restraining box
    hs.useBox = true;
    hs.width = 810;
    hs.height = 250;

    //block right-click user copying if no permissions available
    <%
    if(request.getUserPrincipal()==null){
    %>
    hs.blockRightClick = true;
    <%
    }
    %>

    // Add the controlbar
    hs.addSlideshow({
      //slideshowGroup: 'group1',
      interval: 5000,
      repeat: false,
      useControls: true,
      fixedControls: 'fit',
      overlayOptions: {
        opacity: 0.75,
        position: 'bottom center',
        hideOnMouseOut: true
      }
    });

  </script>

<!--  FACEBOOK SHARE BUTTON -->
<div id="fb-root"></div>
<script type="text/javascript">(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>

<!-- GOOGLE PLUS-ONE BUTTON -->
<script type="text/javascript">
  (function() {
    var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
    po.src = 'https://apis.google.com/js/plusone.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
  })();
</script>

<script src="javascript/underscore-min.js"></script>
<script src="javascript/backbone-min.js"></script>
<script src="javascript/core.js"></script>
<script src="javascript/classes/Base.js"></script>

<link rel="stylesheet" href="javascript/tablesorter/themes/blue/style.css" type="text/css" media="print, projection, screen" />

<link rel="stylesheet" href="css/pageableTable.css" />
<script src="javascript/tsrt.js"></script>

<style>
.ptcol-maxYearsBetweenResightings {
	width: 100px;
}
.ptcol-numberLocations {
	width: 100px;
}
</style>

<link href='http://fonts.googleapis.com/css?family=Source+Sans+Pro:200,600,200italic,600italic&subset=latin,vietnamese' rel='stylesheet' type='text/css'>
<script src="http://d3js.org/d3.v3.min.js"></script>
<script src="javascript/bubbleDiagram/d3-transform.js"></script>
<script src="http://phuonghuynh.github.io/js/bower_components/cafej/src/extarray.js"></script>
<script src="http://phuonghuynh.github.io/js/bower_components/cafej/src/misc.js"></script>
<script src="http://phuonghuynh.github.io/js/bower_components/cafej/src/micro-observer.js"></script>
<script src="http://phuonghuynh.github.io/js/bower_components/microplugin/src/microplugin.js"></script>
<script src="javascript/bubbleDiagram/bubble-chart.js"></script>
<script src="javascript/bubbleDiagram/central-click.js"></script>
<script src="javascript/bubbleDiagram/lines.js"></script>
<script src="javascript/bubbleDiagram/index.js"></script>
<script src="javascript/relationshipDiagrams/familyTree.js"></script>
<link rel="stylesheet" href="css/familyTree.css">
<link rel="stylesheet" href="css/bubbleDiagram.css">

<script type="text/javascript">

var testColumns = {
	//rowNum: { label: '#', val: _colRowNum },
	date: { label: 'Date', val: _colEncDate },
	location: { label: 'Location' },
	dataTypes: { label: 'Data types', val: _colDataTypes },
	alternateID: { label: 'Alt ID', val: cleanValue },
	sex: { label: 'Sex' },
	occ: { label: 'Occurring with', val: _colOcc },
	behavior: { label: 'Behavior' },
};

/*
$(document).keydown(function(k) {
	if ((k.which == 38) || (k.which == 40)) k.preventDefault();
	if (k.which == 38) return tableDn();
	if (k.which == 40) return tableUp();
});

*/
var colDefn = [
	{
		key: 'date',
		label: 'Date',
		value: _colEncDate,
		sortValue: _colEncDateSort,
		sortFunction: function(a,b) { return parseFloat(a) - parseFloat(b); }
	},
	{
		key: 'location',
		label: 'Location',
	},
	{
		key: 'dataTypes',
		label: 'Data types',
		value: _colDataTypes,
		sortValue: _colDataTypesSort,
	},
	{
		key: 'alternateID',
		label: 'Alt ID',
		value: cleanValue,
	},
	{
		key: 'sex',
		label: 'Sex',
	},
	{
		key: 'occ',
		label: 'Occurring with',
		value: _colOcc,
	},
	{
		key: 'behavior',
		label: 'Behavior',
	}

];


var howMany = 10;
var start = 0;
var results = [];

var sortCol = -1;
var sortReverse = true;


var sTable = false;

function doTable() {
	for (var i = 0 ; i < searchResults.length ; i++) {
		searchResults[i] = new wildbook.Model.Encounter(searchResults[i]);
		//searchResultsObjects[i] = new wildbook.Model.MarkedIndividual(searchResults[i]);
	}

	sTable = new SortTable({
		data: searchResults,
		perPage: howMany,
		sliderElement: $('#results-slider'),
		columns: colDefn,
	});

	$('#results-table').addClass('tablesorter').addClass('pageableTable');
	var th = '<thead><tr>';
		for (var c = 0 ; c < colDefn.length ; c++) {
			var cls = 'ptcol-' + colDefn[c].key;
			if (!colDefn[c].nosort) {
				if (sortCol < 0) { //init
					sortCol = c;
					cls += ' headerSortUp';
				}
				cls += ' header" onClick="return headerClick(event, ' + c + ');';
			}
			th += '<th class="' + cls + '">' + colDefn[c].label + '</th>';
		}
	$('#results-table').append(th + '</tr></thead>');


	if (howMany > searchResults.length) howMany = searchResults.length;

	for (var i = 0 ; i < howMany ; i++) {
		var r = '<tr onClick="return rowClick(this);" class="clickable pageableTable-visible">';
		for (var c = 0 ; c < colDefn.length ; c++) {
			r += '<td class="ptcol-' + colDefn[c].key + '"></td>';
		}
		r += '</tr>';
		$('#results-table').append(r);
	}

	sTable.initSort();
	sTable.initValues();


	newSlice(sortCol, sortReverse);

	$('#progress').hide();
	sTable.sliderInit();
	show();

	$('#results-table').on('mousewheel', function(ev) {  //firefox? DOMMouseScroll
		if (!sTable.opts.sliderElement) return;
		ev.preventDefault();
		var delta = Math.max(-1, Math.min(1, (event.wheelDelta || -event.detail)));
		if (delta != 0) nudge(-delta);
	});

}

function rowClick(el) {
	console.log(el);
	var w = window.open('encounters/encounter.jsp?number=' + el.getAttribute('data-id'), '_blank');
	w.focus();
	return false;
}

function headerClick(ev, c) {
	start = 0;
	ev.preventDefault();
	console.log(c);
	if (sortCol == c) {
		sortReverse = !sortReverse;
	} else {
		sortReverse = false;
	}
	sortCol = c;

	$('#results-table th.headerSortDown').removeClass('headerSortDown');
	$('#results-table th.headerSortUp').removeClass('headerSortUp');
	if (sortReverse) {
		$('#results-table th.ptcol-' + colDefn[c].key).addClass('headerSortUp');
	} else {
		$('#results-table th.ptcol-' + colDefn[c].key).addClass('headerSortDown');
	}
console.log('sortCol=%d sortReverse=%o', sortCol, sortReverse);
	newSlice(sortCol, sortReverse);
	show();
}


function show() {
	$('#results-table td').html('');
	for (var i = 0 ; i < results.length ; i++) {
		$('#results-table tbody tr')[i].setAttribute('data-id', searchResults[results[i]].get('catalogNumber'));
		var private = searchResults[results[i]].get('_sanitized') || false;
		var title = 'Encounter ' + searchResults[results[i]].get('catalogNumber');
		if (private) {
			$($('#results-table tbody tr')[i]).addClass('collab-private');
			title += ' [private]';
		} else {
			$($('#results-table tbody tr')[i]).removeClass('collab-private');
		}
		$('#results-table tbody tr')[i].title = title;
		for (var c = 0 ; c < colDefn.length ; c++) {
			$('#results-table tbody tr')[i].children[c].innerHTML = sTable.values[results[i]][c];
			$('#results-table tbody tr')[i].children[c].innerHTML = sTable.values[results[i]][c];
		}
	}

	sTable.sliderSet(100 - (start / (searchResults.length - howMany)) * 100);
}

function newSlice(col, reverse) {
	results = sTable.slice(col, start, start + howMany, reverse);
}


function nudge(n) {
	start += n;
	if ((start + howMany) > sTable.matchesFilter.length) start = sTable.matchesFilter.length - howMany;
	if (start < 0) start = 0;
console.log('start -> %d', start);
	newSlice(sortCol, sortReverse);
	show();
}
/*
function xnudge(n) {
	start += n;
	if (start < 0) start = 0;
	if (start > searchResults.length - 1) start = searchResults.length - 1;
	newSlice(sortCol, sortReverse);
	show();
}
*/

function tableDn() {
	return nudge(-1);
	start--;
	if (start < 0) start = 0;
	newSlice(sortCol, sortReverse);
	show();
}

function tableUp() {
	return nudge(1);
	start++;
	if (start > searchResults.length - 1) start = searchResults.length - 1;
	newSlice(sortCol, sortReverse);
	show();
}

////////


$("#communityTable").hide();
$("#familyTable").hide();
$("#cooccurrenceTable").hide();
$("#encountersTable").hide();
$("#innerEncountersTable").hide();

$(document).ready( function() {
	wildbook.init(function() { doTable(); });

  $("#familyDiagramTab").click(function (e) {
    e.preventDefault()
    $("#familyDiagram").show();
    $("#communityDiagram").hide();
    $("#communityTable").hide();
    $("#familyDiagramTab").addClass("active");
    $("#communityDiagramTab").removeClass("active");
    $("#communityTableTab").removeClass("active");
  });

  $("#communityDiagramTab").click(function (e) {
    e.preventDefault()
    $("#familyDiagram").hide();
    $("#communityDiagram").show();
    $("#communityTable").hide();
    $("#familyDiagramTab").removeClass("active");
    $("#communityDiagramTab").addClass("active");
    $("#communityTableTab").removeClass("active");
  });

  $("#communityTableTab").click(function (e) {
    e.preventDefault()
    $("#familyDiagram").hide();
    $("#communityDiagram").hide();
    $("#communityTable").show();
    $("#familyDiagramTab").removeClass("active");
    $("#communityDiagramTab").removeClass("active");
    $("#communityTableTab").addClass("active");
  });

  $("#cooccurrenceDiagramTab").click(function (e) {
    e.preventDefault()
    $("#cooccurrenceDiagram").show();
    $("#cooccurrenceTable").hide();
    $("#cooccurrenceDiagramTab").addClass("active");
    $("#cooccurrenceTableTab").removeClass("active");
  });

  $("#cooccurrenceTableTab").click(function (e) {
    e.preventDefault()
    $("#cooccurrenceTable").show();
    $("#cooccurrenceDiagram").hide();
    $("#cooccurrenceTableTab").addClass("active");
    $("#cooccurrenceDiagramTab").removeClass("active");
  });

  $("#bioSamplesTableTab").click(function (e) {
    e.preventDefault()
    $("#bioSamplesTable").show();
    $("#encountersTable").hide();
    $("#innerEncountersTable").hide();
    $("#bioSamplesTableTab").addClass("active");
    $("#encountersTableTab").removeClass("active");
  });

  $("#encountersTableTab").click(function (e) {
    e.preventDefault()
    $("#encountersTable").show();
    $("#innerEncountersTable").show();
    $("#bioSamplesTable").hide();
    $("#encountersTableTab").addClass("active");
    $("#bioSamplesTableTab").removeClass("active");
  });

});



function _colIndividual(o) {
	//var i = '<b><a target="_new" href="individuals.jsp?number=' + o.individualID + '">' + o.individualID + '</a></b> ';
	var i = '<b>' + o.individualID + '</b> ';
	if (!extra[o.individualID]) return i;
	i += (extra[o.individualID].firstIdent || '') + ' <i>';
	i += (extra[o.individualID].genusSpecies || '') + '</i>';
	return i;
}


function _colNumberEncounters(o) {
	if (!extra[o.individualID]) return '';
	var n = extra[o.individualID].numberEncounters;
	if (n == undefined) return '';
	return n;
}

/*
function _colYearsBetween(o) {
	return o.get('maxYearsBetweenResightings');
}
*/

function _colNumberLocations(o) {
	if (!extra[o.individualID]) return '';
	var n = extra[o.individualID].locations;
	if (n == undefined) return '';
	return n;
}


function _colTaxonomy(o) {
	if (!o.get('genus') || !o.get('specificEpithet')) return 'n/a';
	return o.get('genus') + ' ' + o.get('specificEpithet');
}


function _colRowNum(o) {
	return o._rowNum;
}


function _colThumb(o) {
	if (!extra[o.individualID]) return '';
	var url = extra[o.individualID].thumbUrl;
	if (!url) return '';
	return '<div style="background-image: url(' + url + ');"><img src="' + url + '" /></div>';
}



function _textExtraction(n) {
	var s = $(n).text();
	var skip = new RegExp('^(none|unassigned|)$', 'i');
	if (skip.test(s)) return 'zzzzz';
	return s;
}




/////////////////////////////////////////////////////////////////////////////
var encs;
var resultsTable;


var tableContents = document.createDocumentFragment();

function xdoTable() {
	resultsTable = new pageableTable({
		columns: testColumns,
		tableElement: $('#results-table'),
		sliderElement: $('#results-slider'),
		tablesorterOpts: {
			//headers: { 1: {sorter: false} },
			textExtraction: _textExtraction,
		},
	});

	resultsTable.tableInit();

	encs = new wildbook.Collection.Encounters();
	var addedCount = 0;
	encs.on('add', function(o) {
		var row = resultsTable.tableCreateRow(o);
		row.click(function() { var w = window.open('encounters/encounter.jsp?number=' + row.data('id'), '_blank'); w.focus(); });
		row.addClass('clickable');
		row.appendTo(tableContents);
		addedCount++;
/*
		var percentage = Math.floor(addedCount / searchResults.length * 100);
console.log(percentage);
$('#progress').html(percentage);
*/
		if (addedCount >= searchResults.length) {
			$('#results-table').append(tableContents);
		}
	});

	_.each(searchResults, function(o) {
//console.log(o);
		encs.add(new wildbook.Model.Encounter(o));
	});
	$('#progress').remove();
	resultsTable.tableShow();

/*
	encs.fetch({
		//fields: { individualID: 'newMatch' },
		success: function() {
			$('#progress').remove();
			resultsTable.tableShow();
		}
	});
*/

}


function _colDataTypes(o) {
	var dt = '';
	if (o.get('hasImages')) dt += '<img title="images" src="images/Crystal_Clear_filesystem_folder_image.png" />';
	if (o.get('hasTissueSamples')) dt += '<img title="tissue samples" src="images/microscope.gif" style="padding: 0px 1px 0px 1px;" />';
	if (o.get('hasMeasurements')) dt += '<img title="measurements" src="images/ruler.png" />';
	return dt;
}

function _colDataTypesSort(o) {
	var dt = '';
	if (o.get('hasImages')) dt += ' images';
	if (o.get('hasTissueSamples')) dt += ' tissues';
	if (o.get('hasMeasurements')) dt += ' measurements';
	return dt;
}


function _colEncDate(o) {
	var icon = '<span class="collab-icon"></span>';
	return icon + wildbook.flexibleDate(o.get('date'));
}


function _colEncDateSort(o) {
	var d = wildbook.parseDate(o.get('date'));
	if (!d) return 0;
	return d.getTime();
}


function _colOcc(o) {
	var occ = o.get('occurrences');
	if (!occ || (occ.length < 1)) {return '';}
	return occ.join(', ');
}


function _colRowNum(o) {
	return o._rowNum;
}


function _colThumb(o) {
	var url = o.thumbUrl();
	if (!url) return '';
	return '<div style="background-image: url(' + url + ');"><img src="' + url + '" /></div>';
	return '<div style="background-image: url(' + url + ');"></div>';
	return '<img src="' + url + '" />';
}


function _colModified(o) {
	var m = o.get('modified');
	if (!m) return '';
	var d = wildbook.parseDate(m);
	if (!wildbook.isValidDate(d)) {return '';}
	return d.toISOString().substring(0,10);
}

function _colCreationDate(o) {
	var m = o.get('dwcDateAdded');
	if (!m) return '';
	var d = wildbook.parseDate(m);
	if (!wildbook.isValidDate(d)) {return '';}
	return d.toISOString().substring(0,10);
}



function _textExtraction(n) {
	var s = $(n).text();
	var skip = new RegExp('^(none|unassigned|)$', 'i');
	if (skip.test(s)) return 'zzzzz';
	return s;
}


function cleanValue(obj, fieldName) {
	var v = obj.get(fieldName);
	var empty = /^(null|unknown|none|undefined)$/i;
	if (empty.test(v)) v = '';
	return v;
}


function dataTypes(obj, fieldName) {
	var dt = [];
	_.each(['measurements', 'images'], function(w) {
		//if (obj[w] && obj[w].models && (obj[w].models.length > 0)) dt.push(w.substring(0,1));
		if (obj.get(w) && (obj.get(w).length > 0)) dt.push(w.substring(0,1));
	});
	return dt.join(', ');
}

</script>

<%-- Main Div --%>
<div class="container row maincontent">
  <%=blocker%>
  <%-- Header Row --%>
  <div class="jumbotron">
    <%
    myShepherd.beginDBTransaction();
    try {
      if (myShepherd.isMarkedIndividual(name)) {


        MarkedIndividual sharky = myShepherd.getMarkedIndividual(name);
        boolean isOwner = ServletUtilities.isUserAuthorizedForIndividual(sharky, request);

        %>
        <h1><img src="images/wild-me-logo-only-100-100.png" width="75px" height="75px" align="absmiddle"/> <%=markedIndividualTypeCaps%> <%=sharky.getIndividualID()%></h1>
        <p class="caption"><em><%=props.getProperty("description") %></em></p>

    <%-- Social Media Buttons --%>
    <div>
      <!-- Google PLUS-ONE button -->
      <g:plusone size="small" annotation="none"></g:plusone>
      <!--  Twitter TWEET THIS button -->
      <a href="https://twitter.com/share" class="twitter-share-button" data-count="none">Tweet</a>
      <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
      <!-- Facebook LIKE button -->
      <div class="fb-share-button" data-href="http://<%=CommonConfiguration.getURLLocation(request) %>/individuals.jsp?number=<%=request.getParameter("number") %>" data-type="button_count"></div>
      <%
      if(CommonConfiguration.isIntegratedWithWildMe(context)){
        %>
        <a href="http://fb.wildme.org/wildme/public/profile/<%=CommonConfiguration.getProperty("wildMeDataSourcePrefix", context) %><%=sharky.getIndividualID()%>" target="_blank"><img src="images/wild-me-link.png" /></a>
        <%
      }
      %>
      <%-- End of Social Media   --%>
    </div>
  <%-- End of Header Row --%>
  </div>

  <%-- Body Row --%>
  <div class="row">
    <%-- Main Left Column --%>
    <div class="col-sm-8">
      <%-- Descriptions --%>
      <div class="row">
        <div class="col-md-4">
          <%
          if (CommonConfiguration.allowNicknames(context)) {

            String myNickname = "";
            if (sharky.getNickName() != null) {
              myNickname = sharky.getNickName();
            }
            String myNicknamer = "";
            if (sharky.getNickNamer() != null) {
              myNicknamer = sharky.getNickNamer();
            }
            %>

            <p><%=nickname %>: <%=myNickname%><%if (isOwner && CommonConfiguration.isCatalogEditable(context)) {%><a id="nickname" style="color:blue;cursor: pointer;"><img align="absmiddle" width="20px" height="20px" style="border-style: none;" src="images/Crystal_Clear_action_edit.png" /></a><%}%></p>

            <p><%=nicknamer %>: <%=myNicknamer%></p>
            <%
          }
          %>
          <!-- Now prep the nickname popup dialog -->
          <div id="dialogNickname" title="<%=setNickname %>" style="display:none">
          <table border="1" cellpadding="1" cellspacing="0" bordercolor="#FFFFFF">

            <tr>
              <td align="left" valign="top">
                <form name="nameShark" method="post" action="IndividualSetNickName">
                  <input name="individual" type="hidden"
                    value="<%=request.getParameter("number")%>"> <%=nickname %>:
                    <input name="nickname" type="text" id="nickname" size="15"
                      maxlength="50"><br> <%=nicknamer %>: <input name="namer" type="text" id="namer" size="15" maxlength="50"><br> <input
                      name="Name" type="submit" id="Name" value="<%=update %>"></form>
                    </td>
                  </tr>
                </table>
              </div>
              <!-- nickname popup dialog script -->
              <script>
              var dlgNick = $("#dialogNickname").dialog({
                autoOpen: false,
                draggable: false,
                resizable: false,
                width: 500
              });

              $("a#nickname").click(function() {
                dlgNick.dialog("open");
              });
              </script>
        </div>
        <div class="col-md-4">
            <%
              String sexValue="";
              if(sharky.getSex()!=null){sexValue=sharky.getSex();}
              %>
              <p><%=sex %>: <%=sexValue %> <%if (isOwner && CommonConfiguration.isCatalogEditable(context)) {%><a id="sex" style="color:blue;cursor: pointer;"><img align="absmiddle" width="20px" height="20px" style="border-style: none;" src="images/Crystal_Clear_action_edit.png" /></a><%}%><br />
              <%
                //edit sex
                if (CommonConfiguration.isCatalogEditable(context) && isOwner) {%>

                <!-- Now prep the sex popup dialog -->
                <div id="dialogSex" title="<%=setsex %>" style="display:none">
                <table border="1" cellpadding="1" cellspacing="0" bordercolor="#FFFFFF">

                  <tr>
                    <td align="left" valign="top">
                      <form name="setxsexshark" action="IndividualSetSex" method="post">

                        <select name="selectSex" size="1" id="selectSex">
                          <option value="unknown"><%=props.getProperty("unknown") %></option>
                          <option value="male"><%=props.getProperty("male") %></option>
                          <option value="female"><%=props.getProperty("female") %></option>
                        </select><br> <input name="individual" type="hidden" value="<%=name%>" id="individual" />
                        <input name="Add" type="submit" id="Add" value="<%=update %>" />
                      </form>
                    </td>
                  </tr>
                </table>
              </div>
              <!-- sex popup dialog script -->
              <script>
                var dlgSex = $("#dialogSex").dialog({
                autoOpen: false,
                draggable: false,
                resizable: false,
                width: 500
                });

                $("a#sex").click(function() {
                dlgSex.dialog("open");
                });
              </script>
              <%}%>
            </p>

            <!-- start birth date -->
            <a name="birthdate"></a>
            <%
              String timeOfBirth="";
              //System.out.println("Time of birth is: "+sharky.getTimeOfBirth());
              if(sharky.getTimeOfBirth()>0){
              String timeOfBirthFormat="yyyy-MM-d";
              if(props.getProperty("birthdateJodaFormat")!=null){
              timeOfBirthFormat=props.getProperty("birthdateJodaFormat");
              }
              timeOfBirth=(new DateTime(sharky.getTimeOfBirth())).toString(timeOfBirthFormat);
              }

              String displayTimeOfBirth=timeOfBirth;
              //if(displayTimeOfBirth.indexOf("-")!=-1){displayTimeOfBirth=displayTimeOfBirth.substring(0,displayTimeOfBirth.indexOf("-"));}

              %>
              <p><%=props.getProperty("birthdate")  %>:
              <%=displayTimeOfBirth%> <%if (isOwner && CommonConfiguration.isCatalogEditable(context)) {%><a style="color:blue;cursor: pointer;" id="birthdate"><img align="absmiddle" width="20px" height="20px" style="border-style: none;" src="images/Crystal_Clear_action_edit.png" /></a><%}%>
            </p>

            <!-- Now prep the birth date popup dialog -->
            <div id="dialogBirthDate" title="<%=props.getProperty("setBirthDate") %>" style="display:none">
            <table border="1" cellpadding="1" cellspacing="0" bordercolor="#FFFFFF">

              <tr><td align="left" valign="top">
                <strong>
                  <font color="#990000"> <%=props.getProperty("clickDate")%>
                </font>
              </strong>
              <br /><%=props.getProperty("dateFormat")%>
              <br /> <font size="-1"><%=props.getProperty("leaveBlank")%></font>
            </td></tr>

            <tr>
              <td align="left" valign="top">
                <form name="set_birthdate" method="post" action="IndividualSetYearOfBirth">

                  <input name="individual" type="hidden" value="<%=request.getParameter("number")%>" />
                  <%=props.getProperty("birthdate")  %>:
                  <input name="timeOfBirth" type="text" id="timeOfBirth" size="15" maxlength="150" value="<%=timeOfBirth %>" />

                  <br /> <input name="birthy" type="submit" id="birthy" value="<%=update %>"></form>
                </td>
              </tr>
            </table>

          </div>
          <!-- birth date popup dialog script -->
          <script>
            var dlgBirthDate = $("#dialogBirthDate").dialog({
            autoOpen: false,
            draggable: false,
            resizable: false,
            width: 600
            });

            $("a#birthdate").click(function() {
            dlgBirthDate.dialog("open");
            });
          </script>
          </p>
          <!-- end birth date -->

          <!-- start death date -->
          <a name="deathdate"></a>
          <%
          String timeOfDeath="";
          if(sharky.getTimeofDeath()>0){
          String timeOfDeathFormat="yyyy-MM-d";
          if(props.getProperty("deathdateJodaFormat")!=null){
          timeOfDeathFormat=props.getProperty("deathdateJodaFormat");
          }
          timeOfDeath=(new DateTime(sharky.getTimeofDeath())).toString(timeOfDeathFormat);
          }
          String displayTimeOfDeath=timeOfDeath;
          //if(displayTimeOfDeath.indexOf("-")!=-1){displayTimeOfDeath=displayTimeOfDeath.substring(0,displayTimeOfDeath.indexOf("-"));}

          %>
          <p><%=props.getProperty("deathdate")  %>:
          <%=displayTimeOfDeath%> <%if (isOwner && CommonConfiguration.isCatalogEditable(context)) {%><a style="color:blue;cursor: pointer;" id="deathdate"><img align="absmiddle" width="20px" height="20px" style="border-style: none;" src="images/Crystal_Clear_action_edit.png" /></a><%}%>
          </p>

          <!-- Now prep the death date popup dialog -->
          <div id="dialogDeathDate" title="<%=props.getProperty("setDeathDate") %>" style="display:none">
          <table border="1" cellpadding="1" cellspacing="0" bordercolor="#FFFFFF">

          <tr><td align="left" valign="top">
            <strong>
              <font color="#990000"> <%=props.getProperty("clickDate")%>
            </font>
          </strong>
          <br /><%=props.getProperty("dateFormat")%>
          <br /> <font size="-1"><em><%=props.getProperty("leaveBlank")%></em></font>

          </td></tr>

          <tr>
          <td align="left" valign="top">
            <form name="set_deathdate" method="post" action="IndividualSetYearOfDeath">
              <input name="individual" type="hidden" value="<%=request.getParameter("number")%>" />
              <%=props.getProperty("deathdate")  %>:
              <input name="timeOfDeath" type="text" id="timeOfDeath" size="15" maxlength="150" value="<%=timeOfDeath %>" /><br /> <input name="deathy" type="submit" id="deathy" value="<%=update %>"></form>
            </td>
          </tr>
          </table>

          </div>
          <!-- death date popup dialog script -->
          <script>
          var dlgDeathDate = $("#dialogDeathDate").dialog({
          autoOpen: false,
          draggable: false,
          resizable: false,
          width: 600
          });

          $("a#deathdate").click(function() {
          dlgDeathDate.dialog("open");
          });
          </script>
          </p>
          <!-- end death date -->
        </div>
        <div class="col-md-4">
          <a name="alternateid"></a>
          <%
          String altID="";
          if(sharky.getAlternateID()!=null){
            altID=sharky.getAlternateID();
          }

          %>
          <p><img align="absmiddle" src="images/alternateid.gif"> <%=alternateID %>:
          <%=altID%> <%if (isOwner && CommonConfiguration.isCatalogEditable(context)) {%><a style="color:blue;cursor: pointer;" id="alternateID"><img align="absmiddle" width="20px" height="20px" style="border-style: none;" src="images/Crystal_Clear_action_edit.png" /></a><%}%>
        </p>
        <!-- Now prep the alternateId popup dialog -->
        <div id="dialogAlternateID" title="<%=setAlternateID %>" style="display:none">
        <table border="1" cellpadding="1" cellspacing="0" bordercolor="#FFFFFF">

          <tr>
            <td align="left" valign="top">
              <form name="set_alternateid" method="post" action="IndividualSetAlternateID">
                <input name="individual" type="hidden" value="<%=request.getParameter("number")%>" /> <%=alternateID %>:
                <input name="alternateid" type="text" id="alternateid" size="15" maxlength="150" value="<%=altID %>" /><br /> <input name="Name" type="submit" id="Name" value="<%=update %>"></form>
              </td>
            </tr>
          </table>

        </div>
        <!-- alternateId popup dialog script -->
        <script>
        var dlg = $("#dialogAlternateID").dialog({
          autoOpen: false,
          draggable: false,
          resizable: false,
          width: 600
        });

        $("a#alternateID").click(function() {
          dlg.dialog("open");
        });
        </script>

        <%
        if(CommonConfiguration.showProperty("showTaxonomy",context)){

          String genusSpeciesFound=props.getProperty("notAvailable");
          if(sharky.getGenusSpecies()!=null){genusSpeciesFound=sharky.getGenusSpecies();}
          %>
          <p><img align="absmiddle" src="images/taxontree.gif">
            <%=props.getProperty("taxonomy")%>: <em><%=genusSpeciesFound%></em>
          </p>
          <%
        }
        %>

        </div>

      </div>
      <%-- End Descriptions --%>






      <%-- TODO does this vv go here? --%>
      <%
      if (sharky.getDynamicProperties() != null) {
      //let's create a TreeMap of the properties
      StringTokenizer st = new StringTokenizer(sharky.getDynamicProperties(), ";");
      while (st.hasMoreTokens()) {
      String token = st.nextToken();
      int equalPlace = token.indexOf("=");
      String nm = token.substring(0, (equalPlace));
      String vl = token.substring(equalPlace + 1);
      %>
      <p class="para"><img align="absmiddle" src="images/lightning_dynamic_props.gif"> <strong><%=nm%>
      </strong><br/> <%=vl%>
      <%
      if (isOwner && CommonConfiguration.isCatalogEditable(context)) {
      %>
      <font size="-1"><a
      href="http://<%=CommonConfiguration.getURLLocation(request) %>/individuals.jsp?number=<%=request.getParameter("number").trim()%>&edit=dynamicproperty&name=<%=nm%>#dynamicproperty"><img align="absmiddle" width="20px" height="20px" style="border-style: none;" src="images/Crystal_Clear_action_edit.png" /></a></font>
      <%
      }
      %>
      </p>

      <%
      }
      }
      %>

      <%-- TODO RELATIONSHIP GRAPHS --%>
      <div>
        <a name="socialRelationships"></a>
        <p><strong><%=props.getProperty("social")%></strong></p>
        <%
        if (isOwner && CommonConfiguration.isCatalogEditable(context)) {
        %>
        <p class="para">
        	<a id="addRelationship" class="launchPopup">
        		<img align="absmiddle" width="24px" style="border-style: none;" src="images/Crystal_Clear_action_edit_add.png"/>
        	</a>
        	<a id="addRelationship" class="launchPopup">
        		<%=props.getProperty("addRelationship") %>
        	</a>
        </p>
        <%
        }
        %>

        <!-- start relationship popup code -->
        <%
        if (isOwner && CommonConfiguration.isCatalogEditable(context)) {
        %>
        <div id="dialogRelationship" title="<%=props.getProperty("setRelationship")%>" style="display:none; z-index: 99999 !important">

        <form id="setRelationship" action="RelationshipCreate" method="post">
        <table cellspacing="2" bordercolor="#FFFFFF" >

        <%
        	String markedIndividual1Name="";
        String markedIndividual2Name="";
        String markedIndividual1Role="";
        String markedIndividual2Role="";
        String type="";
        String startTime="";
        String endTime="";
        String bidirectional="";
        String markedIndividual1DirectionalDescriptor="";
        String markedIndividual2DirectionalDescriptor="";
        String communityName="";

        //if(myShepherd.isRelationship(request.getParameter("type"), request.getParameter("markedIndividualName1"), request.getParameter("markedIndividualName2"), request.getParameter("markedIndividualRole1"), request.getParameter("markedIndividualRole2"),false)){

        	if(request.getParameter("persistenceID")!=null){

        	//Relationship myRel=myShepherd.getRelationship(request.getParameter("type"), request.getParameter("markedIndividualName1"), request.getParameter("markedIndividualName2"), request.getParameter("markedIndividualRole1"), request.getParameter("markedIndividualRole2"));

        	Object identity = myShepherd.getPM().newObjectIdInstance(org.ecocean.social.Relationship.class, request.getParameter("persistenceID"));

        	Relationship myRel=(Relationship)myShepherd.getPM().getObjectById(identity);

        	if(myRel.getMarkedIndividualName1()!=null){
        		markedIndividual1Name=myRel.getMarkedIndividualName1();
        	}
        	if(myRel.getMarkedIndividualName2()!=null){
        		markedIndividual2Name=myRel.getMarkedIndividualName2();
        	}
        	if(myRel.getMarkedIndividualRole1()!=null){
        		markedIndividual1Role=myRel.getMarkedIndividualRole1();
        	}
        	if(myRel.getMarkedIndividualRole2()!=null){
        		markedIndividual2Role=myRel.getMarkedIndividualRole2();
        	}
        	if(myRel.getType()!=null){
        		type=myRel.getType();
        	}
        	if(myRel.getMarkedIndividual1DirectionalDescriptor()!=null){
        		markedIndividual1DirectionalDescriptor=myRel.getMarkedIndividual1DirectionalDescriptor();
        	}
        	if(myRel.getMarkedIndividual2DirectionalDescriptor()!=null){
        		markedIndividual2DirectionalDescriptor=myRel.getMarkedIndividual2DirectionalDescriptor();
        	}

        	if(myRel.getStartTime()>-1){
        		startTime=(new DateTime(myRel.getStartTime())).toString();
        	}
        	if(myRel.getEndTime()>-1){
        		endTime=(new DateTime(myRel.getEndTime())).toString();
        	}

        	if(myRel.getBidirectional()!=null){
        		bidirectional=myRel.getBidirectional().toString();
        	}

        	if(myRel.getRelatedSocialUnitName()!=null){
        		communityName=myRel.getRelatedSocialUnitName();
        	}


        }
        %>

            <tr>
              	<td width="200px">
                  <strong><%=props.getProperty("type")%></strong><br />
                  <div style="font-size: smaller;">(<%=props.getProperty("required")%>)</div></td>
                <td>
                	<select name="type">
        			<%
        				List<String> types=CommonConfiguration.getIndexedPropertyValues("relationshipType",context);
        				int numTypes=types.size();
        				for(int g=0;g<numTypes;g++){

        					String selectedText="";
        					if(type.equals(types.get(g))){selectedText="selected=\"selected\"";}
        			%>
                  		<option <%=selectedText%>><%=types.get(g)%></option>
                  	<%
                  		}
                  	%>
                  	</select>


                </td>
             </tr>
             <tr>
             	<td>

                  <strong><%=props.getProperty("individualID1")%></strong><br />
                   <div style="font-size: smaller;">(<%=props.getProperty("required")%>)</div>
                   </td>
                  <td>

                     <%
                               	if((markedIndividual1Name.equals(""))&&(markedIndividual2Name.equals(""))){
                               %>
                       			<%=sharky.getIndividualID()%><input type="hidden" name="markedIndividualName1" value="<%=sharky.getIndividualID()%>"/>

                       		<%
                       			               			}
                       			               		            else if(!markedIndividual1Name.equals(sharky.getIndividualID())){
                       			               		%>
                		<input name="markedIndividualName1" type="text" size="20" maxlength="100" value="<%=markedIndividual1Name%>" />
               		<%
                			}
                		        	else{
                		%>
               			<%=markedIndividual1Name%><input type="hidden" name="markedIndividualName1" value="<%=sharky.getIndividualID()%>"/>
               		<%
               			}
               		%>
               </td>
           	</tr>
           	<tr>
             	<td>
                  <strong><%=props.getProperty("individualRole1")%></strong>
                  <br /> <div style="font-size: smaller;">(<%=props.getProperty("required")%>)</div>
                 </td>
                 <td>

                 <select name="markedIndividualRole1">
        			<%
        				List<String> roles=CommonConfiguration.getIndexedPropertyValues("relationshipRole",context);
        				int numRoles=roles.size();
        				for(int g=0;g<numRoles;g++){

        					String selectedText="";
        					if(markedIndividual1Role.equals(roles.get(g))){selectedText="selected=\"selected\"";}
        			%>
                  		<option <%=selectedText%>><%=roles.get(g)%></option>
                  	<%
                  		}
                  	%>
                  	</select>

                 </td>

                 <td>
                 	<%=props.getProperty("markedIndividual1DirectionalDescriptor")%>
                 </td>
                 <td>
                 	<input name="markedIndividual1DirectionalDescriptor" type="text" size="20" maxlength="100" value="<%=markedIndividual1DirectionalDescriptor%>" />
                 </td>

           	</tr>

            <tr>
             	<td><strong><%=props.getProperty("individualID2")%></strong></td>
                <td>
           			<%
           				if(!markedIndividual2Name.equals(sharky.getIndividualID())){
           			%>
                		<input name="markedIndividualName2" type="text" size="20" maxlength="100" value="<%=markedIndividual2Name%>" />
               		<%
                			}
                		        	else{
                		%>
               			<%=markedIndividual2Name%><input type="hidden" name="markedIndividualName2" value="<%=sharky.getIndividualID()%>"/>
               		<%
               			}
               		%>
               </td>
           	</tr>
           	<tr>
             	<td>

                  <strong><%=props.getProperty("individualRole2")%></strong>
                  <br /> <div style="font-size: smaller;">(<%=props.getProperty("required")%>)</div></td>
                  <td>
                  	<select name="markedIndividualRole2">
        			<%
        				for(int g=0;g<numRoles;g++){

        					String selectedText="";
        					if(markedIndividual2Role.equals(roles.get(g))){selectedText="selected=\"selected\"";}
        			%>
                  		<option <%=selectedText%>><%=roles.get(g)%></option>
                  	<%
                  		}
                  	%>
                  	</select></td>
               <td>
                 	<%=props.getProperty("markedIndividual2DirectionalDescriptor")%>
                 </td>
                 <td>
                 	<input name="markedIndividual2DirectionalDescriptor" type="text" size="20" maxlength="100" value="<%=markedIndividual2DirectionalDescriptor%>" />
                 </td>
           	</tr>

           <tr>
             	<td>

                  <strong><%=props.getProperty("relatedCommunityName")%></strong></td><td><input name="relatedCommunityName" type="text" size="20" maxlength="100" value="<%=communityName%>" />
               </td>
           	</tr>

           	   <tr>
             	<td>

                  <strong><%=props.getProperty("startTime")%></strong></td>
                  <td><input name="startTime" type="text" size="20" maxlength="100" value="<%=startTime%>" />
               </td>
               </tr>
               <tr>
               <td>

                 <strong><%=props.getProperty("endTime")%></strong></td>
                  <td><input name="endTime" type="text" size="20" maxlength="100" value="<%=endTime%>" />
               </td>

           	</tr>

           	<tr>
             	<td>

                  <strong><%=props.getProperty("bidirectional")%></strong>
               </td>
               <td>
                  	<select name="bidirectional">


                  		<option value=""></option>
                  		<%
                  			String selected="";
                  		          	if(bidirectional.equals("true")){
                  		          		selected="selected=\"selected\"";
                  		          	}
                  		%>
                  		<option value="true" <%=selected%>>true</option>
                  		<%
                  			selected="";
                  		          	if(bidirectional.equals("false")){
                  		          		selected="selected=\"selected\"";
                  		          	}
                  		%>
                  		<option value="false" <%=selected%>>false</option>
                  	</select>

               </td>
           	</tr>


            <tr><td colspan="2">
                    	<input name="EditRELATIONSHIP" type="submit" id="EditRELATIONSHIP" value="<%=props.getProperty("update") %>" />
           			</td>
           	</tr>


              </td>
            </tr>
          </table>

          <%
            	if(request.getParameter("persistenceID")!=null){
            %>
          	<input name="persistenceID" type="hidden" value="<%=request.getParameter("persistenceID")%>"/>
          <%
          	}
          %>

        </form>
        </div>
                                 		<!-- popup dialog script -->
        <script>
        var dlgRel = $("#dialogRelationship").dialog({
          autoOpen: false,
          draggable: false,
          resizable: false,
          width: 600
        });

        $("a#addRelationship").click(function() {
          dlgRel.dialog("open");
          //$("#setRelationship").find("input[type=text], textarea").val("");


        });
        </script>
        <%
           	}

           //setup the javascript to handle displaying an edit tissue sample dialog box
           if( (request.getParameter("edit")!=null) && request.getParameter("edit").equals("relationship")){
           %>
        <script>
        dlgRel.dialog("open");
        </script>

        <%
          	}

          //end relationship code

          List<Relationship> relationships=myShepherd.getAllRelationshipsForMarkedIndividual(sharky.getIndividualID());

          if(relationships.size()>0){
          %>

      <div>
        <ul class="nav nav-tabs">
          <li id="familyDiagramTab"  class="active">
            <a href="#familyDiagram">Familial Diagram</a>
          </li>
          <li id="communityDiagramTab">
            <a href="#communityDiagram"><%=props.getProperty("social")%> Diagram</a>
          </li>
          <li id="communityTableTab">
            <a href="#communityTable"><%=props.getProperty("social")%> Table</a>
          </li>
        </ul>
      </div>

      <div id="familyDiagram" class="diagramContainer">
        <% String individualID = sharky.getIndividualID();%>
        <script type="text/javascript">

        setupFamilyTree(<%=individualID%>);
        </script>
      </div>

      <div id="communityTable" class="mygrid-wrapper-div diagramContainer">
        <table width="100%" class="tissueSample">
        <th><strong><%=props.getProperty("roles")%></strong></th><th><strong><%=props.get("relationshipWith")%></strong></th><th><strong><%=props.getProperty("type")%></strong></th><th><strong><%=props.getProperty("community")%></strong></th>
        <%
        	if (isOwner && CommonConfiguration.isCatalogEditable(context)) {
        %>
        <th><%=props.getProperty("numSightingsTogether")%></th>
        <th><strong><%=props.getProperty("edit")%></strong></th><th><strong><%=props.getProperty("remove")%></strong></th>
        <%
        	}
        %>

        </tr>
        <%
        	int numRels=relationships.size();
        for(int f=0;f<numRels;f++){
        	Relationship myRel=relationships.get(f);
        	String indieName1=myRel.getMarkedIndividualName1();
        	String indieName2=myRel.getMarkedIndividualName2();
        	String otherIndyName=indieName2;
        	String thisIndyRole="";
        	String otherIndyRole="";
        	if(myRel.getMarkedIndividualRole1()!=null){thisIndyRole=myRel.getMarkedIndividualRole1();}
        	if(myRel.getMarkedIndividualRole2()!=null){otherIndyRole=myRel.getMarkedIndividualRole2();}
        	if(otherIndyName.equals(sharky.getIndividualID())){
        		otherIndyName=indieName1;
        		thisIndyRole=myRel.getMarkedIndividualRole2();
        		otherIndyRole=myRel.getMarkedIndividualRole1();
        	}
        	MarkedIndividual otherIndy=myShepherd.getMarkedIndividual(otherIndyName);
        	String type="";
        	if(myRel.getType()!=null){type=myRel.getType();}

        	String community="";
        	if(myRel.getRelatedSocialUnitName()!=null){community=myRel.getRelatedSocialUnitName();}
        %>
        	<tr>
        	<td><em><%=thisIndyRole %></em>-<%=otherIndyRole %></td>
        	<td>
        	<a target="_blank" href="http://<%=CommonConfiguration.getURLLocation(request) %>/individuals.jsp?number=<%=otherIndy.getIndividualID()%>"><%=otherIndy.getIndividualID() %></a>
        		<%
        		if(otherIndy.getNickName()!=null){
        		%>
        		<br /><%=props.getProperty("nickname") %>: <%=otherIndy.getNickName()%>
        		<%
        		}
        		if(otherIndy.getAlternateID()!=null){
        		%>
        		<br /><%=props.getProperty("alternateID") %>: <%=otherIndy.getAlternateID()%>
        		<%
        		}
        		if(otherIndy.getSex()!=null){
        		%>
        			<br /><span class="caption"><%=props.getProperty("sex") %>: <%=otherIndy.getSex() %></span>
        		<%
        		}

        		if(otherIndy.getHaplotype()!=null){
        		%>
        			<br /><span class="caption"><%=props.getProperty("haplotype") %>: <%=otherIndy.getHaplotype() %></span>
        		<%
        		}
        		%>
        	</td>
        	<td><%=type %></td>
        	<td><a href="socialUnit.jsp?name=<%=community%>"><%=community %></a></td>

        	<%
        	if (isOwner && CommonConfiguration.isCatalogEditable(context)) {

        		String persistenceID=myShepherd.getPM().getObjectId(myRel).toString();

        		//int bracketLocation=persistenceID.indexOf("[");
        		//persistenceID=persistenceID.substring(0,bracketLocation);

        	%>
        	<td>
        	<%=myShepherd.getNumCooccurrencesBetweenTwoMarkedIndividual(otherIndy.getIndividualID(),sharky.getIndividualID()) %>

        	</td>



        	<td>
        		<a href="http://<%=CommonConfiguration.getURLLocation(request) %>/individuals.jsp?number=<%=request.getParameter("number") %>&edit=relationship&type=<%=myRel.getType()%>&markedIndividualName1=<%=myRel.getMarkedIndividualName1() %>&markedIndividualRole1=<%=myRel.getMarkedIndividualRole1() %>&markedIndividualName2=<%=myRel.getMarkedIndividualName2() %>&markedIndividualRole2=<%=myRel.getMarkedIndividualRole2()%>&persistenceID=<%=persistenceID%>"><img width="24px" style="border-style: none;" src="images/Crystal_Clear_action_edit.png" /></a>
        	</td>
        	<td>
        		<a onclick="return confirm('Are you sure you want to delete this relationship?');" href="RelationshipDelete?type=<%=myRel.getType()%>&markedIndividualName1=<%=myRel.getMarkedIndividualName1() %>&markedIndividualRole1=<%=myRel.getMarkedIndividualRole1() %>&markedIndividualName2=<%=myRel.getMarkedIndividualName2() %>&markedIndividualRole2=<%=myRel.getMarkedIndividualRole2()%>&persistenceID=<%=persistenceID%>"><img style="border-style: none;" src="images/cancel.gif" /></a>
        	</td>
        	<%
        	}
        	%>

        	</tr>
        <%


        }
        %>

        </table>
      </div>
        <br/>
        <%
        }
        else {
        %>
        	<p class="para"><%=props.getProperty("noSocial") %></p><br />
        <%
        }
        //

        %>



        <%-- TODO cooccurrence table starts here --%>
        <a name="cooccurrence"></a>
        <p><strong><%=props.getProperty("cooccurrence")%></strong></p>
        <div class="cooccurrences">
          <% String individualID = sharky.getIndividualID();%>
          <script type="text/javascript">

          getData(<%=individualID%>);
          </script>

          <ul class="nav nav-tabs">
            <li id="cooccurrenceDiagramTab" class="active">
              <a href="#cooccurrenceDiagram"><%=props.getProperty("cooccurrence")%> Diagram</a>
            </li>
            <li id="cooccurrenceTableTab">
              <a href="#cooccurrenceTable"><%=props.getProperty("cooccurrence")%> Table</a>
            </li>
          </ul>

          <div id="cooccurrenceDiagram">
            <div class="diagramContainer">
              <div class="bubbleChart">
                <div id="buttons" class="btn-group btn-group-sm" role="group">
                  <button type="button" class="btn btn-default" id="zoomIn"><span class="glyphicon glyphicon-plus"></span></button>
                  <button type="button" class="btn btn-default" id="zoomOut"><span class="glyphicon glyphicon-minus"></span></button>
                  <button type="button" class="btn btn-default" id="reset">Reset</button>
                </div>
              </div>
            </div>
          </div>
        </div>


        <%
        List<Map.Entry> otherIndies=myShepherd.getAllOtherIndividualsOccurringWithMarkedIndividual(sharky.getIndividualID());

        if(otherIndies.size()>0){

        //ok, let's iterate the social relationships
        %>


      <div id="cooccurrenceTable" class="mygrid-wrapper-div diagramContainer">
        <table width="100%" class="tissueSample table">
        <th><strong><%=props.get("sightedWith") %></strong></th><th><strong><%=props.getProperty("numSightingsTogether") %></strong></th></tr>
        <%

        Iterator<Map.Entry> othersIterator=otherIndies.iterator();
        while(othersIterator.hasNext()){
        	Map.Entry indy=othersIterator.next();
        	MarkedIndividual occurIndy=myShepherd.getMarkedIndividual((String)indy.getKey());
        	%>
        	<tr><td>
        	<a target="_blank" href="http://<%=CommonConfiguration.getURLLocation(request) %>/individuals.jsp?number=<%=occurIndy.getIndividualID()%>"><%=occurIndy.getIndividualID() %></a>
        		<%
        		if(occurIndy.getSex()!=null){
        		%>
        			<br /><span class="caption"><%=props.getProperty("sex") %>: <%=occurIndy.getSex() %></span>
        		<%
        		}

        		if(occurIndy.getHaplotype()!=null){
        		%>
        			<br /><span class="caption"><%=props.getProperty("haplotype") %>: <%=occurIndy.getHaplotype() %></span>
        		<%
        		}
        		%>
        	</td>
        	<td><%=((Integer)indy.getValue()).toString() %></td></tr>
        	<%
        }
        %>
        </table>
      </div>
        <%
        }
        else {
        %>
        	<p class="para"><%=props.getProperty("noCooccurrences") %></p><br />
        <%
        }
        //



          if (isOwner) {
        %>
        <br />
        <p>
        <strong><img align="absmiddle" src="images/48px-Crystal_Clear_mimetype_binary.png" /> <%=additionalDataFiles %></strong>
        <%if ((sharky.getDataFiles()!=null)&&(sharky.getDataFiles().size() > 0)) {%>
        </p>
        <table>
          <%
            Vector addtlFiles = sharky.getDataFiles();
            for (int pdq = 0; pdq < addtlFiles.size(); pdq++) {
              String file_name = (String) addtlFiles.get(pdq);
          %>

          <tr>
            <td><a href="/<%=CommonConfiguration.getDataDirectoryName(context) %>/individuals/<%=sharky.getName()%>/<%=file_name%>"><%=file_name%>
            </a></td>
            <td>&nbsp;&nbsp;&nbsp;[<a
              href="IndividualRemoveDataFile?individual=<%=name%>&filename=<%=file_name%>"><%=delete %>
            </a>]
            </td>
          </tr>

          <%}%>
        </table>
        <%} else {%> <%=none %>
        </p>
        <%
          }
          if (CommonConfiguration.isCatalogEditable(context)) {
        %>
        <form action="IndividualAddFile" method="post"
              enctype="multipart/form-data" name="addDataFiles"><input
          name="action" type="hidden" value="fileadder" id="action"> <input
          name="individual" type="hidden" value="<%=sharky.getName()%>"
          id="individual">

          <p><%=addDataFile %>:</p>

          <p><input name="file2add" type="file" size="50"></p>

          <p><input name="addtlFile" type="submit" id="addtlFile"
                    value="<%=sendFile %>"></p></form>
        <%
          }




          }
        %>




        </td>
        </tr>


        </table>

        </td>
        </tr>
        </table>
      </div>
      <%-- End of Relationship Graphs --%>

      <%-- Start Encounter Table --%>
      <div class="encountersBioSamples">
        <ul class="nav nav-tabs">
          <li id="bioSamplesTableTab" class="active">
            <a href="#bioSammplesTable"><%=props.getProperty("tissueSamples") %></a>
          </li>
          <li id="encountersTableTab">
            <a href="#encountersTable"><%=sharky.totalEncounters()%> <%=numencounters %></a>
          </li>
        </ul>

        <div id="encountersTable">
          <table id="encounter_report" width="100%">
            <tr>
              <td align="left" valign="top">

                <p><strong><%=sharky.totalEncounters()%>
              </strong>
              <%=numencounters %>
            </p>


            <%
            Encounter[] dateSortedEncs = sharky.getDateSortedEncounters();

            ArrayList<HashMap> myEncs = new ArrayList<HashMap>();

            int total = dateSortedEncs.length;
            for (int i = 0; i < total; i++) {
              HashMap henc = new HashMap();
              Encounter enc = dateSortedEncs[i];

              boolean visible = true; //enc.canUserAccess(request);  ///TODO technically we dont need this encounter-level locking!!!
              Vector encImages = enc.getAdditionalImageNames();
              String imgName = "";

              //String encSubdir = thisEnc.subdir();
              imgName = "/"+CommonConfiguration.getDataDirectoryName(context)+"/encounters/" + enc.subdir() + "/thumb.jpg";

              henc.put("visible", visible);
              henc.put("thumbUrl", imgName);
              henc.put("date", enc.getDate());
              henc.put("location", enc.getLocation());
              if ((enc.getImages()!=null) && (enc.getImages().size()>0)) henc.put("hasImages", true);
              if ((myShepherd.getAllTissueSamplesForEncounter(enc.getCatalogNumber())!=null) && (myShepherd.getAllTissueSamplesForEncounter(enc.getCatalogNumber()).size()>0)) henc.put("hasTissueSamples", true);

              //if (enc.hasMeasurements()) henc.put("hasMeasurements", true);
              if ((myShepherd.getMeasurementsForEncounter(enc.getCatalogNumber())!=null) && (myShepherd.getMeasurementsForEncounter(enc.getCatalogNumber()).size()>0)) henc.put("hasMeasurements", true);

              henc.put("catalogNumber", enc.getEncounterNumber());
              henc.put("alternateID", enc.getAlternateID());
              henc.put("sex", enc.getSex());

              /*
              if (CommonConfiguration.useSpotPatternRecognition(context)) {
              %>
              <%if (((enc.getSpots().size() == 0) && (enc.getRightSpots().size() == 0)) && (isOwner)) {%>
              <td class="lineitem">&nbsp;</td>
              <% } else if (isOwner && (enc.getSpots().size() > 0) && (enc.getRightSpots().size() > 0)) {%>
              <td class="lineitem">LR</td>
              <%} else if (isOwner && (enc.getSpots().size() > 0)) {%>
              <td class="lineitem">L</td>
              <%} else if (isOwner && (enc.getRightSpots().size() > 0)) {%>
              <td class="lineitem">R</td>
              <%
              }
              }

              */

              ArrayList<String> occ = new ArrayList<String>();
              if(myShepherd.getOccurrenceForEncounter(enc.getCatalogNumber())!=null){
              Occurrence thisOccur=myShepherd.getOccurrenceForEncounter(enc.getCatalogNumber());
              ArrayList<String> otherOccurs=thisOccur.getMarkedIndividualNamesForThisOccurrence();
              if(otherOccurs!=null){
              int numOtherOccurs=otherOccurs.size();
              for(int j=0;j<numOtherOccurs;j++){
              String thisName=otherOccurs.get(j);
              if(!thisName.equals(sharky.getIndividualID())) occ.add(thisName);
              }
              }
              }

              henc.put("occurrences", occ);

              henc.put("behavior", enc.getBehavior());
              /*
              if(myShepherd.getOccurrenceForEncounter(enc.getCatalogNumber())!=null){
              Occurrence thisOccur=myShepherd.getOccurrenceForEncounter(enc.getCatalogNumber());
              if((thisOccur!=null)&&(thisOccur.getGroupBehavior()!=null)){
              %>
              <br /><br /><em><%=props.getProperty("groupBehavior") %></em><br /><%=thisOccur.getGroupBehavior() %>
              <%
              }
              }
              */

              System.out.println(henc);
              myEncs.add(henc);

              } //end for

              //String encsJson = new Gson().toJson(myEncs);
              String encsJson = "[\n";
              ExecutionContext ec = ((JDOPersistenceManager)myShepherd.getPM()).getExecutionContext();
              for (int i = 0; i < total; i++) {
              Encounter enc = dateSortedEncs[i];
              //myEncs.get(i);  //HashMap
              JSONObject jobj = RESTUtils.getJSONObjectFromPOJO(enc, ec);
              jobj.put("date", enc.getDate());
              jobj = enc.sanitizeJson(request, jobj);

              ArrayList<String> occ = new ArrayList<String>();
              if(myShepherd.getOccurrenceForEncounter(enc.getCatalogNumber())!=null){
              Occurrence thisOccur=myShepherd.getOccurrenceForEncounter(enc.getCatalogNumber());
              ArrayList<String> otherOccurs=thisOccur.getMarkedIndividualNamesForThisOccurrence();
              if(otherOccurs!=null){
              int numOtherOccurs=otherOccurs.size();
              for(int j=0;j<numOtherOccurs;j++){
              String thisName=otherOccurs.get(j);
              System.out.println("name -> "+thisName);
              if(!thisName.equals(sharky.getIndividualID())) occ.add(thisName);
              }
              }
              }
              jobj.put("occurrences", occ);

              encsJson += jobj.toString() + ",\n";
              }
              encsJson += "\n]";
              //encsJson = "[]";

              %>

              <div class="pageableTable-wrapper mygrid-wrapper-div" id="innerEncountersTable">
                <div id="progress">Generating encounters table</div>
                <table id="results-table"></table>
                <div id="results-slider"></div>
              </div>

            </table>

            <script>
              var searchResults = <%=encsJson%>;
            </script>
          </div>
          <%-- End Encounter Table --%>

          <!-- Start genetics -->
          <div id="bioSamplesTable">
            <a name="tissueSamples"></a>
            <p><img align="absmiddle" src="images/microscope.gif" /><strong><%=props.getProperty("tissueSamples") %></strong></p>
            <p>
              <%
              List<TissueSample> tissueSamples=myShepherd.getAllTissueSamplesForMarkedIndividual(sharky);

              int numTissueSamples=tissueSamples.size();
              if(numTissueSamples>0){
                %>
                <table width="100%" class="tissueSample">
                  <tr>
                    <th><strong><%=props.getProperty("sampleID") %></strong></th>
                    <th><strong><%=props.getProperty("correspondingEncounterNumber") %></strong></th>
                    <th><strong><%=props.getProperty("values") %></strong></th>
                    <th><strong><%=props.getProperty("analyses") %></strong></th></tr>
                    <%
                    for(int j=0;j<numTissueSamples;j++){
                      TissueSample thisSample=tissueSamples.get(j);
                      %>
                      <tr>
                        <td><span class="caption"><a href="encounters/encounter.jsp?number=<%=thisSample.getCorrespondingEncounterNumber() %>#tissueSamples"><%=thisSample.getSampleID()%></a></span></td>
                        <td><span class="caption"><a href="encounters/encounter.jsp?number=<%=thisSample.getCorrespondingEncounterNumber() %>#tissueSamples"><%=thisSample.getCorrespondingEncounterNumber()%></a></span></td>
                        <td><span class="caption"><%=thisSample.getHTMLString() %></span>
                      </td>

                      <td><table>
                        <%
                        int numAnalyses=thisSample.getNumAnalyses();
                        List<GeneticAnalysis> gAnalyses = thisSample.getGeneticAnalyses();
                        for(int g=0;g<numAnalyses;g++){
                          GeneticAnalysis ga = gAnalyses.get(g);
                          if(ga.getAnalysisType().equals("MitochondrialDNA")){
                            MitochondrialDNAAnalysis mito=(MitochondrialDNAAnalysis)ga;
                            %>
                            <tr><td style="border-style: none;"><strong><span class="caption"><%=props.getProperty("haplotype") %></strong></span></strong>: <span class="caption"><%=mito.getHaplotype() %></span></td></tr></li>
                            <%
                          }
                          else if(ga.getAnalysisType().equals("SexAnalysis")){
                            SexAnalysis mito=(SexAnalysis)ga;
                            %>
                            <tr><td style="border-style: none;"><strong><span class="caption"><%=props.getProperty("geneticSex") %></strong></span></strong>: <span class="caption"><%=mito.getSex() %></span></td></tr></li>
                            <%
                          }
                          else if(ga.getAnalysisType().equals("MicrosatelliteMarkers")){
                            MicrosatelliteMarkersAnalysis mito=(MicrosatelliteMarkersAnalysis)ga;

                            %>
                            <tr>
                              <td style="border-style: none;">
                                <p><span class="caption"><strong><%=props.getProperty("msMarkers") %></strong></span>&nbsp;
                                <%
                                  if(request.getUserPrincipal()!=null){
                                  %>
                                  <a href="individualSearch.jsp?individualDistanceSearch=<%=sharky.getIndividualID()%>"><img height="20px" width="20px" align="absmiddle" alt="Individual-to-Individual Genetic Distance Search" src="images/Crystal_Clear_app_xmag.png"></img></a>
                                  <%
                                    }
                                    %>
                                  </p>
                                  <span class="caption"><%=mito.getAllelesHTMLString() %></span>
                                </td>
                              </tr></li>

                              <%
                                }
                                else if(ga.getAnalysisType().equals("BiologicalMeasurement")){
                                BiologicalMeasurement mito=(BiologicalMeasurement)ga;
                                %>
                                <tr><td style="border-style: none;"><strong><span class="caption"><%=mito.getMeasurementType()%> <%=props.getProperty("measurement") %></span></strong><br /> <span class="caption"><%=mito.getValue().toString() %> <%=mito.getUnits() %> (<%=mito.getSamplingProtocol() %>)
                                <%
                                  if(!mito.getSuperHTMLString().equals("")){
                                  %>
                                  <em>
                                    <br /><%=props.getProperty("analysisID")%>: <%=mito.getAnalysisID()%>
                                    <br /><%=mito.getSuperHTMLString()%>
                                  </em>
                                  <%
                                    }
                                    %>
                                  </span></td></tr></li>
                                  <%
                                    }
                                    }
                                    %>
                                  </table>

                                </td>


                              </tr>
                              <%
                                }
                                %>
                              </table>
                            </p>
                            <%
                              }
                              else {
                              %>
                              <p class="para"><%=props.getProperty("noTissueSamples") %></p>
                              <%
                                }
                                %>
                              </div>
                              <!-- End genetics -->
      </div>
      <%-- Start Adoption --%>
      <div>
        <%
          if (CommonConfiguration.allowAdoptions(context)) {
        %>

        <div id="rightcol" style="vertical-align: top;">
          <div id="menu" style="vertical-align: top;">


            <div class="module">
              <jsp:include page="individualAdoptionEmbed.jsp" flush="true">
                <jsp:param name="name" value="<%=name%>"/>
              </jsp:include>
            </div>


          </div><!-- end menu -->
        </div><!-- end rightcol -->

          <%
           }
        %>
      </div>
      <%-- End Adoption --%>
      <%-- Map --%>
      <div>
        <table>
        <tr>
        <td>

              <jsp:include page="individualMapEmbed.jsp" flush="true">
                <jsp:param name="name" value="<%=name%>"/>
              </jsp:include>
        </td>
        </tr>
        </table>
      </div>


    <%-- End of Main Left Column --%>
    </div>

    <%-- Main Right Column --%>
    <div class="col-sm-4">
      <!-- Start thumbnail gallery -->
      <div>
        <p>
          <strong><%=props.getProperty("imageGallery") %>
          </strong></p>

            <%
            String[] keywords=keywords=new String[0];
        		int numThumbnails = myShepherd.getNumThumbnails(sharky.getEncounters().iterator(), keywords);
        		if(numThumbnails>0){
        		%>

        <table id="results" border="0" width="100%">
            <%


        			int countMe=0;
        			//Vector thumbLocs=new Vector();
        			List<SinglePhotoVideo> thumbLocs=new ArrayList<SinglePhotoVideo>();

        			int  numColumns=3;
        			int numThumbs=0;
        			  if (CommonConfiguration.allowAdoptions(context)) {
        				  List<Adoption> adoptions = myShepherd.getAllAdoptionsForMarkedIndividual(name,context);
        				  int numAdoptions = adoptions.size();
        				  if(numAdoptions>0){
        					  numColumns=2;
        				  }
        			  }

        			try {

        			    Query query = myShepherd.getPM().newQuery("SELECT from org.ecocean.Encounter WHERE individualID == \""+sharky.getIndividualID()+"\"");
        		        //query.setFilter("SELECT "+jdoqlQueryString);
        		        query.setResult("catalogNumber");
        		        Collection c = (Collection) (query.execute());
        		        ArrayList<String> enclist = new ArrayList<String>(c);
        		        query.closeAll();


        				thumbLocs=myShepherd.getThumbnails(myShepherd,request, enclist, 1, 99999, keywords);
        				numThumbs=thumbLocs.size();
        			%>

          <tr valign="top">
         <td>
         <!-- HTML Codes by Quackit.com -->
        <div style="text-align:left;border:1px solid lightgray;width:100%;height:400px;overflow-y:scroll;overflow-x:scroll;border-radius:5px;">

              <%
              						while(countMe<numThumbs){
        							//for(int columns=0;columns<numColumns;columns++){
        								if(countMe<numThumbs) {
        									//String combined ="";
        									//if(myShepherd.isAcceptableVideoFile(thumbLocs.get(countMe).getFilename())){
        									//	combined = "http://" + CommonConfiguration.getURLLocation(request) + "/images/video.jpg" + "BREAK" + thumbLocs.get(countMe).getCorrespondingEncounterNumber() + "BREAK" + thumbLocs.get(countMe).getFilename();
        									//}
        									//else{
        									//	combined= thumbLocs.get(countMe).getCorrespondingEncounterNumber() + "/" + thumbLocs.get(countMe).getDataCollectionEventID() + ".jpg" + "BREAK" + thumbLocs.get(countMe).getCorrespondingEncounterNumber() + "BREAK" + thumbLocs.get(countMe).getFilename();

        									//}

        									//StringTokenizer stzr=new StringTokenizer(combined,"BREAK");
        									//String thumbLink=stzr.nextToken();
        									//String encNum=stzr.nextToken();
        									//int fileNamePos=combined.lastIndexOf("BREAK")+5;
        									//String fileName=combined.substring(fileNamePos).replaceAll("%20"," ");

        									Encounter thisEnc = myShepherd.getEncounter(thumbLocs.get(countMe).getCorrespondingEncounterNumber());
        									String encSubdir = thisEnc.subdir();
        									boolean visible = thisEnc.canUserAccess(request);

        									String thumbLink="";
        									boolean video=true;
        									if(!myShepherd.isAcceptableVideoFile(thumbLocs.get(countMe).getFilename())){
        										thumbLink="/"+CommonConfiguration.getDataDirectoryName(context)+"/encounters/"+ encSubdir +"/"+thumbLocs.get(countMe).getDataCollectionEventID()+".jpg";
        										video=false;
        									}
        									else{
        										thumbLink="http://"+CommonConfiguration.getURLLocation(request)+"/images/video.jpg";

        									}
        									String link="/"+CommonConfiguration.getDataDirectoryName(context)+"/encounters/"+ encSubdir +"/"+thumbLocs.get(countMe).getFilename();

        	boolean thisEncounterVisible = thisEnc.canUserAccess(request);
        							%>



              <table class="<%=(visible ? "" : "no-access")%>" align="left" width="<%=100/numColumns %>%" margin="0 auto">
                <tr align="center">
                  <td valign="top">

                      <%
        			if(isOwner && thisEncounterVisible){
        												%>
                    <a href="<%=link%>" target="_blank"
                    <%
                    if(thumbLink.indexOf("video.jpg")==-1){
                    %>
                    	class="highslide" onclick="return hs.expand(this)"
                    <%
                    }
                    %>
                    >
                    <%
                    }
                     %>
                      <img src="<%=thumbLink%>" alt="photo" border="1" title="<%=props.getProperty("clickEnlarge")%>"/>
                      <%
                        if (isOwner) {
                      %>
                    </a>
                      <%
        			}

        			%>

                    <div
                    <%
                    if(!thumbLink.endsWith("video.jpg")){
                    %>
                    class="highslide-caption"
                    <%
                    }
                    %>
                    >

                      <table>
                        <tr>
                          <td align="left" valign="top">

                            <table>
                              <%

                                int kwLength = keywords.length;
                                //Encounter thisEnc = myShepherd.getEncounter(thumbLocs.get(countMe).getCorrespondingEncounterNumber());
                              %>



                              <tr>
                                <td>

        	<% if (!visible) out.println(thisEnc.collaborationLockHtml(collabs)); %>
                                	<span class="caption"><%=props.getProperty("location") %>:
                                		<%
                                		if(thisEnc.getLocation()!=null){
                                		%>
                                			<%=thisEnc.getLocation() %>
                                		<%
                                		}
                                		else {
                                		%>
                                			&nbsp;
                                		<%
                                		}
                                		%>
                                	</span>
                                </td>
                              </tr>
                              <tr>
                                <td>
                                	<span class="caption"><%=props.getProperty("locationID") %>:
        				                        		<%
        				                        		if(thisEnc.getLocationID()!=null){
        				                        		%>
        				                        			<%=thisEnc.getLocationID() %>
        				                        		<%
        				                        		}
        				                        		else {
        				                        		%>
        				                        			&nbsp;
        				                        		<%
        				                        		}
        				                        		%>
                                	</span>
                                </td>
                              </tr>
                              <tr>
                                <td><span
                                  class="caption"><%=props.getProperty("date") %>: <%=thisEnc.getDate() %></span>
                                </td>
                              </tr>
                              <tr>
                                <td><span class="caption"><%=props.getProperty("catalogNumber") %>: <a target="_blank"
                                  href="encounters/encounter.jsp?number=<%=thisEnc.getCatalogNumber() %>"><%=thisEnc.getCatalogNumber() %>
                                </a></span></td>
                              </tr>
                              <%
                                if (thisEnc.getVerbatimEventDate() != null) {
                              %>
                              <tr>

                                <td><span
                                  class="caption"><%=props.getProperty("verbatimEventDate") %>: <%=thisEnc.getVerbatimEventDate() %></span>
                                </td>
                              </tr>
                              <%
                                }
                              %>
                              <tr>
                                <td><span class="caption">
        											<%=props.getProperty("matchingKeywords") %>
        											<%
        											 //while (allKeywords2.hasNext()) {
        					                          //Keyword word = (Keyword) allKeywords2.next();


        					                          //if (word.isMemberOf(encNum + "/" + fileName)) {
        											  //if(thumbLocs.get(countMe).getKeywords().contains(word)){

        					                            //String renderMe = word.getReadableName();
        												List<Keyword> myWords = thumbLocs.get(countMe).getKeywords();
        												int myWordsSize=myWords.size();
        					                            for (int kwIter = 0; kwIter<myWordsSize; kwIter++) {
        					                              //String kwParam = keywords[kwIter];
        					                              //if (kwParam.equals(word.getIndexname())) {
        					                              //  renderMe = "<strong>" + renderMe + "</strong>";
        					                              //}
        					                      		 	%>
        					 								<br/><%= ("<strong>" + myWords.get(kwIter).getReadableName() + "</strong>")%>
        					 								<%
        					                            }




        					                          //    }
        					                       // }

                                  %>
        										</span></td>
                              </tr>
                            </table>
                            <br/>

                            <%
                              if (CommonConfiguration.showEXIFData(context)) {

                    	if(!thumbLink.endsWith("video.jpg")){
                   		 %>
        					<span class="caption">
        						<div class="scroll">
        						<span class="caption">
        					<%
                    if ((thumbLocs.get(countMe).getFilename().toLowerCase().endsWith("jpg")) || (thumbLocs.get(countMe).getFilename().toLowerCase().endsWith("jpeg"))) {
                      try{
                      File exifImage = new File(encountersDir.getAbsolutePath() + "/" + thisEnc.subdir() + "/" + thumbLocs.get(countMe).getFilename());
                      if(exifImage.exists()){
                      	Metadata metadata = JpegMetadataReader.readMetadata(exifImage);
                      	// iterate through metadata directories
                        for (Tag tag : MediaUtilities.extractMetadataTags(metadata)) {
                  				%>
          								<%=tag.toString() %><br/>
          								<%
                        }
                      } //end if
                      else{
                    	  %>
        		            <p>File not found on file system. No EXIF data available.</p>
                  		<%
                      }
                    } //end try
                    catch(Exception e){
                    	 %>
        		            <p>Cannot read metadata for this file.</p>
                    	<%
                    	System.out.println("Cannout read metadata for: "+thumbLocs.get(countMe).getFilename());
                    	e.printStackTrace();
                    }

                          }
                        %>


           								</span>
                    </div>
           								</span>
           			<%
                    	}
           			%>


                          </td>
                          <%
                            }
                          %>
                        </tr>
                      </table>
                    </div>


        </td>
        </tr>

         <%
                    if(!thumbLink.endsWith("video.jpg")){
         %>
        <tr>
          <td class="lock-td">
        <% if (!visible) out.println(thisEnc.collaborationLockHtml(collabs)); %>
          	<span class="caption"><%=props.getProperty("location") %>:
        	                        		<%
        	                        		if(thisEnc.getLocation()!=null){
        	                        		%>
        	                        			<%=thisEnc.getLocation() %>
        	                        		<%
        	                        		}
        	                        		else {
        	                        		%>
        	                        			&nbsp;
        	                        		<%
        	                        		}
        	                        		%>
                                	</span>
          </td>
        </tr>
        <tr>
          <td>
         	<span class="caption"><%=props.getProperty("locationID") %>:
                                		<%
                                		if(thisEnc.getLocationID()!=null){
                                		%>
                                			<%=thisEnc.getLocationID() %>
                                		<%
                                		}
                                		else {
                                		%>
                                			&nbsp;
                                		<%
                                		}
                                		%>
                                	</span>
           </td>
        </tr>
        <tr>
          <td><span class="caption"><%=props.getProperty("date") %>: <%=thisEnc.getDate() %></span></td>
        </tr>
        <tr>
          <td><span class="caption"><%=props.getProperty("catalogNumber") %>: <a target="_blank"
            href="encounters/encounter.jsp?number=<%=thisEnc.getCatalogNumber() %>"><%=thisEnc.getCatalogNumber() %>
          </a></span></td>
        </tr>
        <tr>
          <td><span class="caption">
        											<%=props.getProperty("matchingKeywords") %>
        											<%
                                //int numKeywords=myShepherd.getNumKeywords();
        											 //while (allKeywords2.hasNext()) {
        					                          //Keyword word = (Keyword) allKeywords2.next();


        					                          //if (word.isMemberOf(encNum + "/" + fileName)) {
        											  //if(thumbLocs.get(countMe).getKeywords().contains(word)){

        					                            //String renderMe = word.getReadableName();
        												//List<Keyword> myWords = thumbLocs.get(countMe).getKeywords();
        												//int myWordsSize=myWords.size();
        					                            for (int kwIter = 0; kwIter<myWordsSize; kwIter++) {
        					                              //String kwParam = keywords[kwIter];
        					                              //if (kwParam.equals(word.getIndexname())) {
        					                              //  renderMe = "<strong>" + renderMe + "</strong>";
        					                              //}
        					                      		 	%>
        					 								<br/><%= ("<strong>" + myWords.get(kwIter).getReadableName() + "</strong>")%>
        					 								<%
        					                            }




        					                          //    }
        					                       // }

                                  %>
        										</span></td>
        </tr>
        <%

                    }
        %>
        </table>

        <%

              countMe++;
            } //end if
          } //endFor
        %>
        </div>

        </td>
        </tr>
        <%



        } catch (Exception e) {
          e.printStackTrace();
        %>
        <tr>
          <td>
            <p><%=props.getProperty("error")%>
            </p>.
          </td>
        </tr>
        <%
          }
        %>

        </table>
        <%
        } else {
        %>

        <p><%=props.getProperty("noImages")%></p>

        <%
          }
        %>
      </div>
      <!-- End thumbnail gallery -->

      <%-- Start Collaborators --%>
      <div>
        <%
        if(CommonConfiguration.showUsersToPublic(context)){


        	Shepherd userShepherd=new Shepherd("context0");
        	userShepherd.beginDBTransaction();

        %>
        <p>
          <strong><%=props.getProperty("collaboratingResearchers") %></strong> (click each to learn more)
        </p>

             <p class="para">
            <table >
             <tr>
             <td>


                                 <%
                                 //myShepherd.beginDBTransaction();

                                 List<User> relatedUsers =  userShepherd.getAllUsersForMarkedIndividual(sharky);
                                 int numUsers=relatedUsers.size();
                                 if(numUsers>0){
                                 for(int userNum=0;userNum<numUsers;userNum++){

                                	 User thisUser=relatedUsers.get(userNum);
                                	 String username=thisUser.getUsername();
                                 	 %>

                                        <table align="left">
                                        	<%


                                        	String profilePhotoURL="images/empty_profile.jpg";

                                 		if(thisUser.getUserImage()!=null){
                                 			profilePhotoURL="/"+CommonConfiguration.getDataDirectoryName("context0")+"/users/"+thisUser.getUsername()+"/"+thisUser.getUserImage().getFilename();

                                 		}
                                 		%>
                             			<tr><td><center><div style="height: 50px">
        						<a style="color:blue;cursor: pointer;" id="username<%=userNum%>"><img style="height: 100%" border="1" align="top" src="<%=profilePhotoURL%>"  /></a>
        					</div></center></td></tr>
                             			<%
                                 		String displayName="";
                                 		if(thisUser.getFullName()!=null){
                                 			displayName=thisUser.getFullName();

                                 		%>
                                 		<tr><td style="border:none"><center><a style="color:blue;cursor: pointer;" id="username<%=userNum%>" style="font-weight:normal;border:none"><%=displayName %></a></center></td></tr>
                                 		<%
                                 		}

                                 		%>
                                 	</table>

                                 		<!-- Now prep the popup dialog -->
                                 		<div id="dialog<%=userNum%>" title="<%=displayName %>" style="display:none">
                                 			<table cellpadding="3px"><tr><td>
                                 			<div style="height: 150px"><img border="1" align="top" src="<%=profilePhotoURL%>" style="height: 100%" />
                                 			</td>
                                 			<td><p>
                                 			<%
                                 			if(thisUser.getAffiliation()!=null){
                                 			%>
                                 			<strong>Affiliation:</strong> <%=thisUser.getAffiliation() %><br />
                                 			<%
                                 			}

                                 			if(thisUser.getUserProject()!=null){
                                 			%>
                                 			<strong>Research Project:</strong> <%=thisUser.getUserProject() %><br />
                                 			<%
                                 			}

                                 			if(thisUser.getUserURL()!=null){
                                     			%>
                                     			<strong>Web site:</strong> <a style="font-weight:normal;color: blue" class="ecocean" href="<%=thisUser.getUserURL()%>"><%=thisUser.getUserURL() %></a><br />
                                     			<%
                                     			}

                                 			if(thisUser.getUserStatement()!=null){
                                     			%>
                                     			<br /><em>"<%=thisUser.getUserStatement() %>"</em>
                                     			<%
                                     			}
                                 			%>
                                      </div>
                                 			</p>
                                 			</td></tr></table>
                                 		</div>
                                 		<!-- popup dialog script -->

        					<script>
        					    var dlg<%=userNum%> = $("#dialog<%=userNum%>").dialog({
        					      autoOpen: false,
        					      draggable: false,
        					      resizable: false,
        					      width: 500
        					    });

        					    $("a#username<%=userNum%>").click(function() {
        					      dlg<%=userNum%>.dialog("open");
        					    });
        					</script>


                                 		<%
                                 	} //end for loop of users

                                 } //end if loop if there are any users
                                 else{
                                %>

                                	 <p><%=props.getProperty("noCollaboratingResearchers") %></p>
                                <%
                                 }

                                %>
                                </td>


            </tr></table></p>
          <%
          userShepherd.rollbackDBTransaction();
          userShepherd.closeDBTransaction();
        } //end if showUsersToGeneralPublic

        //myShepherd.beginDBTransaction();

          %>
      </div>
      <%-- End Collaborators --%>
      <%-- Comments --%>
      <div>
        <%
        if(isOwner){
        %>
        <p><img align="absmiddle" src="images/Crystal_Clear_app_kaddressbook.gif"> <strong><%=researcherComments %></strong>: </p>

        <div style="text-align:left;border:1px solid lightgray;width:100%;height:400px;overflow-y:scroll;overflow-x:scroll;border-radius:5px;">
        	<p><%=sharky.getComments().replaceAll("\n", "<br>")%></p>
        </div>
        <%
          if (CommonConfiguration.isCatalogEditable(context) && isOwner) {
        %>
        <p>
        	<form action="IndividualAddComment" method="post" name="addComments">
          		<input name="user" type="hidden" value="<%=request.getRemoteUser()%>" id="user">
          		<input name="individual" type="hidden" value="<%=sharky.getName()%>" id="individual">
          		<input name="action" type="hidden" value="comments" id="action">

          		<p><textarea name="comments" cols="60" id="comments" class="form-control" rows="3" style="width: 100%"></textarea> <br />
            			<input name="Submit" type="submit" value="<%=addComments %>">
        	</form>
        </p>
        <%
            } //if isEditable

        }
        %>

        </td>
        </tr>
        </table>
      </div>
      <%-- End Comments --%>

    <%-- End of Main Right Column --%>
    </div>

  <%-- End of Body Row --%>
  </div>


<%-- End of Main Div --%>
</div>


<%-- Import Footer --%>
<jsp:include page="footer.jsp" flush="true"/>

<%---------------- End Visual Content ----------------%>

<%
}

//could not find the specified individual!
else {

//let's check if the entered name is actually an alternate ID
List<MarkedIndividual> al = myShepherd.getMarkedIndividualsByAlternateID(name);
List<MarkedIndividual> al2 = myShepherd.getMarkedIndividualsByNickname(name);
List<Encounter> al3 = myShepherd.getEncountersByAlternateID(name);

if (myShepherd.isEncounter(name)) {
  %>
  <meta http-equiv="REFRESH"
        content="0;url=http://<%=CommonConfiguration.getURLLocation(request)%>/encounters/encounter.jsp?number=<%=name%>">
  </HEAD>
  <%
  }
  else if(myShepherd.isOccurrence(name)) {
  %>
  <meta http-equiv="REFRESH"
        content="0;url=http://<%=CommonConfiguration.getURLLocation(request)%>/occurrence.jsp?number=<%=name%>">
  </HEAD>
  <%
  }

  else if (al.size() > 0) {
  //just grab the first one
  MarkedIndividual shr = al.get(0);
  String realName = shr.getName();
%>

<meta http-equiv="REFRESH"
    content="0;url=http://<%=CommonConfiguration.getURLLocation(request)%>/individuals.jsp?number=<%=realName%>">
</HEAD>
<%
} else if (al2.size() > 0) {
//just grab the first one
MarkedIndividual shr = al2.get(0);
String realName = shr.getName();
%>

<meta http-equiv="REFRESH"
    content="0;url=http://<%=CommonConfiguration.getURLLocation(request)%>/individuals.jsp?number=<%=realName%>">
</HEAD>
<%
} else if (al3.size() > 0) {
//just grab the first one
Encounter shr = al3.get(0);
String realName = shr.getEncounterNumber();
%>

<meta http-equiv="REFRESH"
    content="0;url=http://<%=CommonConfiguration.getURLLocation(request)%>/encounters/encounter.jsp?number=<%=realName%>">
</HEAD>
<%
}
else {
%>


<p><%=matchingRecord %>: <strong><%=name%>
</strong></p>
<p>
<%=tryAgain %>
</p>

<p>

<form action="individuals.jsp" method="get" name="sharks"><strong><%=record %>:</strong>
<input name="number" type="text" id="number" value=<%=name%>> <input
  name="sharky_button" type="submit" id="sharky_button"
  value="<%=getRecord %>"></form>
</p>
<p>
<font color="#990000">
  <a href="encounters/encounterSearch.jsp">
    <%=props.getProperty("searchEncounters") %>
  </a>
</font>
</p>

<p>
<font color="#990000">
  <a href="individualSearch.jsp">
    <%=props.getProperty("searchIndividuals") %>
  </a>
</font>
</p>
<%
    }
  %>
    </td>
</tr>
</table>


    <%
  }
}
catch (Exception eSharks_jsp) {
  System.out.println("Caught and handled an exception in individuals.jsp!");
  eSharks_jsp.printStackTrace();
}



myShepherd.rollbackDBTransaction();
myShepherd.closeDBTransaction();


%>
