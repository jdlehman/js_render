window.renderCounterServer = function(data) {
  var counter = new Counter(data);
  return counter.renderServer();
};
