window.renderCounterClient = function(id, data) {
  var counter = new Counter(data);
  counter.setUpHandlers(id);
};
