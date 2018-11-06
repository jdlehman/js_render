(function(history) {
  var result = '';
  if (history && history.length > 0) {
    var result = '\n<scr'+'ipt class="js_render-console-replay">';
    history.forEach(function (msg) {
      var filteredArgs = msg.arguments.map(function(arg) {
        try {
          JSON.stringify(arg);
          return arg;
        } catch(e) {
          return null;
        }
      });
      result += '\nconsole.' + msg.level + '.apply(console, ' + JSON.stringify(filteredArgs) + ');';
    });
    result += '\n</scr'+'ipt>';
  }
  return result;
})(console.history)
