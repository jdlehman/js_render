import {render} from 'react-dom';
import React from 'react';
import Counter from './index';

window.renderCounterClient = function(id, props) {
  const node = document.getElementById(id);
  render(<Counter {...props} />, node);
};
