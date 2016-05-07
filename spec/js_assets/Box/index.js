function Box(data) {
  this.value = data.value;
}

Box.prototype.serverRender = function() {
  return '<box>' + this.value + '</box>';
};

function serverRender(data) {
  var box = new Box(data);
  return box.serverRender();
}

window.serverRenderBox = function(data) {
  return serverRender(data);
};

window.renderBoxServer = function(data) {
  return serverRender(data);
};
