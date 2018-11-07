(function(history) {
  var result = '';
  if (history && history.length > 0) {
    result += '\n<script class="js_render-console-replay">';
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
    result += '\n</script>';
  }
  return result;
})(console.history)
