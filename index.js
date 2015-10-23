var htParser = require('hacktabl-parser');

var fetchDoc = htParser.fetchDoc;
var parseTable = htParser.parseTable;

var DATA_URL = process.argv[process.argv.length-1]

function recursiveCommentPopulator(current, commentMap) {
  if(current.commentIds instanceof Array) {
    current.comments = [];
    current.commentIds.forEach(function(id){
      var comment = commentMap[id];
      current.comments.push(comment);
      delete comment.id;
    });
    delete current.commentIds;
  }

  var i;
  if(current instanceof Array){
    for(i = 0; i < current.length; i += 1){
      recursiveCommentPopulator(current[i], commentMap)
    }

  }else{
    ['children', 'runs', 'cells', 'paragraphs',
     'summaryParagraphs', 'items', 'ref'].forEach(function(prop){
      if(current[prop] instanceof Array) {
        recursiveCommentPopulator(current[prop], commentMap);
      }
    });
  }
}

fetchDoc(DATA_URL).then(function(xmls){
  return parseTable(xmls, htParser.DEFAULTS);
}).then(function(table){
  // Remove 'ID' from comments because they may cause false diffs.
  //
  recursiveCommentPopulator(table.rows, table.commentMap);
  recursiveCommentPopulator(table.columns, table.commentMap);

  console.log(JSON.stringify({rows: table.rows, columns: table.columns}, null, '  '));
}).catch(function(e){
  if(e.stack){
    console.error(e.stack);
  }else{
    console.error(e);
  }
});