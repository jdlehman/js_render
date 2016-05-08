function Counter(data) {
  this.value = data.value;
}

Counter.prototype.plus = function() {
  this.value++;
};

Counter.prototype.minus = function() {
  this.value--;
};

Counter.prototype.renderServer = function() {
  return '<div class="counter"><span id="value">' + this.value + '</span><button id="minus">-</button><button id="plus">+</button></div>';
};

Counter.prototype.updateValue = function(id) {
  $('#' + id + ' #value').text(this.value);
};

Counter.prototype.setUpHandlers = function (id) {
  var self = this;
  $('#' + id + ' #minus').click(function(e) {
    self.minus();
    self.updateValue(id);
  });

  $('#' + id + ' #plus').click(function(e) {
    self.plus();
    self.updateValue(id);
  });
};
