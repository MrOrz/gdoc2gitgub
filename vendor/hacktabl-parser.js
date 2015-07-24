//
// Custom-build from hacktabl.org
// Extracted from https://github.com/MrOrz/hacktabl/blob/dev/src/livescript/app-service.ls
//

var ItemSplitter, TableParser, CommentParser;
ItemSplitter = function(){
  var SPLITTER, REF_END, EMPTY_SPAN;
  SPLITTER = /\[\s*出處\s*[:：]*/gm;
  REF_END = /]/gim;
  EMPTY_SPAN = /<span\s*[^>]*><\/span>/gim;
  return function(doc){
    var idx;
    idx = doc.search(SPLITTER);
    if (idx === -1) {
      idx = doc.length;
    }
    return {
      content: doc.slice(0, idx),
      ref: doc.slice(idx).replace(SPLITTER, '').replace(REF_END, '').replace(EMPTY_SPAN, '').trim()
    };
  };
}();
TableParser = function(){
  var TR_EXTRACTOR, TD_EXTRACTOR, TAGS, SUMMARY_EXTRACTOR, LI_EXTRACTOR, LI_START, LI_END, BLOCK_TAG_START, BLOCK_TAG_END, SUP_EXTRACTOR;
  TR_EXTRACTOR = /<tr[^>]*>(.+?)<\/tr>/gim;
  TD_EXTRACTOR = /<td[^>]*>(.*?)<\/td>/gim;
  TAGS = /<\/?[^>]*>/gim;
  SUMMARY_EXTRACTOR = /^<td[^>]*>(.*?)<ul[^>]*>/im;
  LI_EXTRACTOR = /<li[^>]*>(.+?)<\/li>/gim;
  LI_START = /<li[^>]*>/;
  LI_END = /<\/li>/;
  BLOCK_TAG_START = /<(?:(?:td)|(?:p)|(?:div)|(?:h\d))[^>]*>/g;
  BLOCK_TAG_END = /<\/(?:(?:td)|(?:p)|(?:div)|(?:h\d))>/g;
  SUP_EXTRACTOR = /<sup[^>]*>.+?<\/sup>/g;
  function cleanupTags(matchedString){
    return matchedString.replace(TAGS, '').trim();
  }
  function cleanupBlockTags(matchedString){
    return matchedString.replace(BLOCK_TAG_START, '').replace(BLOCK_TAG_END, '').trim();
  }
  function cleanupLi(matchedString){
    return matchedString.replace(LI_START, '').replace(LI_END, '').trim();
  }
  return function(doc, parserOptions){
    var comments, trs, tds, ref$, positionTitle, res$, i$, len$, td, perspectives, tr, decodedTitle, title, positions, res1$, j$, len1$, lis, summaryMatches, summary, debateArguments, res2$, k$, len2$, li, argument;
    parserOptions == null && (parserOptions = {});
    comments = CommentParser(doc);
    trs = doc.replace(/\n/gm, '').match(TR_EXTRACTOR) || [''];
    tds = ((ref$ = trs[0].match(TD_EXTRACTOR)) != null ? ref$.slice(1) : void 8) || [];
    res$ = [];
    for (i$ = 0, len$ = tds.length; i$ < len$; ++i$) {
      td = tds[i$];
      res$.push(cleanupTags(td));
    }
    positionTitle = res$;
    trs.shift();
    res$ = [];
    for (i$ = 0, len$ = trs.length; i$ < len$; ++i$) {
      tr = trs[i$];
      tds = tr.match(TD_EXTRACTOR);
      decodedTitle = tds[0];
      title = cleanupTags(decodedTitle.replace(SUP_EXTRACTOR, ''));
      tds.shift();
      res1$ = [];
      for (j$ = 0, len1$ = tds.length; j$ < len1$; ++j$) {
        td = tds[j$];
        lis = td.match(LI_EXTRACTOR) || [];
        summaryMatches = td.match(SUMMARY_EXTRACTOR);
        summary = cleanupBlockTags(summaryMatches ? summaryMatches[1] : '');
        res2$ = [];
        for (k$ = 0, len2$ = lis.length; k$ < len2$; ++k$) {
          li = lis[k$];
          argument = ItemSplitter(cleanupLi(li));
          argument.content = cleanupTags(argument.content);
          argument.ref = cleanupTags(argument.ref);
          res2$.push(argument);
        }
        debateArguments = res2$;
        res1$.push({
          summary: summary,
          debateArguments: debateArguments
        });
      }
      positions = res1$;
      res$.push({
        title: title,
        positions: positions
      });
    }
    perspectives = res$;
    return {
      positionTitle: positionTitle,
      perspectives: perspectives,
      comments: comments
    };
  };
}();
CommentParser = function(){
  var REF_MISSING, REF_CONTROVERSIAL, NOTE, SECOND, OTHER, COMMENT_DIV_EXTRACTOR, TYPE_EXTRACTOR, SECOND_MATCHER, SPAN_START, SPAN_END, CLASS, parser;
  REF_MISSING = 'REF_MISSING';
  REF_CONTROVERSIAL = 'REF_CONTROVERSIAL';
  NOTE = 'NOTE';
  SECOND = 'SECOND';
  OTHER = 'OTHER';
  COMMENT_DIV_EXTRACTOR = /<div[^>]*><p[^>]*><a[^>]+name="cmnt(\d+)">[^>]+<\/a>(.+?)<\/div>/gim;
  TYPE_EXTRACTOR = /^\[([^\]]+)\]\s*/;
  SECOND_MATCHER = /^\+1/;
  SPAN_START = /<span class="[^"]+">/gim;
  SPAN_END = /<\/span>/gim;
  CLASS = /\s+class="[^"]+"/gim;
  parser = function(doc){
    var comments, matched, id, rawContent, rawType, ref$, type, content;
    comments = {};
    while (matched = COMMENT_DIV_EXTRACTOR.exec(doc)) {
      id = matched[1];
      rawContent = matched[2].replace(SPAN_START, '').replace(SPAN_END, '').replace(CLASS, '').trim();
      rawType = (ref$ = rawContent.match(TYPE_EXTRACTOR)) != null ? ref$[1] : void 8;
      type = (fn$());
      content = rawContent.replace(TYPE_EXTRACTOR, '').trim();
      if (content.match(SECOND_MATCHER)) {
        type = SECOND;
      }
      content = "<p>" + content;
      comments[id] = {
        type: type,
        content: content
      };
    }
    return comments;
    function fn$(){
      switch (rawType) {
      case "&#35036;&#20805;&#35498;&#26126;":
        return NOTE;
      case "&#38656;&#35201;&#20986;&#34389;":
        return REF_MISSING;
      case "&#20986;&#34389;&#29229;&#35696;":
        return REF_CONTROVERSIAL;
      default:
        return OTHER;
      }
    }
  };
  parser.types = {
    REF_MISSING: REF_MISSING,
    REF_CONTROVERSIAL: REF_CONTROVERSIAL,
    NOTE: NOTE,
    SECOND: SECOND,
    OTHER: OTHER
  };
  return parser;
}();