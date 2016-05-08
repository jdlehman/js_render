import {renderToString} from 'react-dom/server';
import React from 'react';
import Counter from './index';

window.renderCounterServer = function(props) {
  return renderToString(<Counter {...props} />);
};
