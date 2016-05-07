function TodoItem(data) {
  this.task = data.task;
  this.status = data.status;
}

TodoItem.prototype.serverRender = function() {
  return '<li class="' + this.status + '">' + this.task + '</li>';
};

TodoItem.prototype.markDone = function() {
  this.status = 'done';
};

TodoItem.prototype.editTask = function(newTask) {
  this.task = newTask;
};

function TodoList(data) {
  this.items = data.items.map(function(d) {
    return new TodoItem(d);
  });
}

TodoList.prototype.initialize = function() {
  // set up handlers or something
};

TodoList.prototype.serverRender = function() {
  var todoItemsHTML = this.items.map(function(item) {
    return item.serverRender();
  }).join('');
  return '<ul>' + todoItemsHTML + '</ul>';
};

window.renderTodoListServer = function(data) {
  var list = new TodoList(data);
  return list.serverRender();
};

window.renderTodoListClient = function(id, data) {
  var list = new TodoList(data);
  list.initialize();
};
