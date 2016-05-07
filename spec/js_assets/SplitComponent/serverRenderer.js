window.renderSplitComponentServer = function(data) {
  var split = new SplitComponent(data);
  return split.serverRender();
};
