REPORT_HEADER = <<-EOF
<div class="rspec-report container">

<div id="rspec-header">
  <div id="label">
    <h1>Specification</h1>
  </div>

  <div id="summary">
    <p id="totals" class="alert alert-success"></p>
    <div id="stats"></div>
  </div>
</div>


<div class="results">
EOF

GLOBAL_SCRIPTS = <<-EOF

EOF

GLOBAL_STYLES = <<-EOF

#rspec-header {
  height: 4em;
}

.rspec-report h1 {
  margin: 0px 10px 0px 10px;
  padding: 10px;
  font-family: "Lucida Grande", Helvetica, sans-serif;
  font-size: 1.8em;
  position: absolute;
}

#label {
  float:left;
}

#display-filters {
  float:left;
  padding: 28px 0 0 40%;
  font-family: "Lucida Grande", Helvetica, sans-serif;
}

#summary {
  float:right;
  padding: 5px 10px;
  font-family: "Lucida Grande", Helvetica, sans-serif;
  text-align: right;
}

#summary p {
  margin: 0 0 0 2px;
}

#summary #totals {
  font-size: 1.2em;
}

.example_group {
  margin: 0 10px 5px;
  background: #fff;
}

dl {
  margin: 0; padding: 0 0 5px;
  font: normal 11px "Lucida Grande", Helvetica, sans-serif;
}

dt {
  padding: 3px;
  font-weight: bold;
}

dd {
  margin: 5px 0 5px 5px;
  padding: 3px 3px 3px 18px;
}

dd .duration {
  padding-left: 5px;
  text-align: right;
  right: 0px;
  float:right;
}

dd.example.passed {

}

dd.example.not_implemented {

}

dd.example.pending_fixed {

}

dd.example.failed {

}

dt.not_implemented {

}

dt.pending_fixed {

}

dt.failed {

}

#rspec-header.not_implemented {

}

#rspec-header.pending_fixed {

}

#rspec-header.failed {

}

.backtrace {

}

a {

}

/* Ruby code, style similar to vibrant ink */
.ruby {
  font-size: 12px;
  font-family: monospace;
  color: white;
  background-color: black;
  padding: 0.1em 0 0.2em 0;
}

.ruby .keyword { color: #FF6600; }
.ruby .constant { color: #339999; }
.ruby .attribute { color: white; }
.ruby .global { color: white; }
.ruby .module { color: white; }
.ruby .class { color: white; }
.ruby .string { color: #66FF00; }
.ruby .ident { color: white; }
.ruby .method { color: #FFCC00; }
.ruby .number { color: white; }
.ruby .char { color: white; }
.ruby .comment { color: #9933CC; }
.ruby .symbol { color: white; }
.ruby .regex { color: #44B4CC; }
.ruby .punct { color: white; }
.ruby .escape { color: white; }
.ruby .interp { color: white; }
.ruby .expr { color: white; }

.ruby .offending { background-color: gray; }
.ruby .linenum {
  width: 75px;
  padding: 0.1em 1em 0.2em 0;
  color: #000000;
  background-color: #FFFBD3;
}
EOF

HTML_HEADER = <<-EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <title>RSpec results</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <meta http-equiv="Expires" content="-1" />
  <meta http-equiv="Pragma" content="no-cache" />
  <script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
  <script src="http://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.4/underscore-min.js"></script>
  <script src="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.3.1/js/bootstrap.min.js"></script>
  <link href="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.3.1/css/bootstrap-combined.min.css" rel="stylesheet">
</head>
<body>
EOF