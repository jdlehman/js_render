import React, {Component} from 'react';

export default class Counter extends Component {
  constructor(props) {
    super(props);

    this.state = {
      value: this.props.startingValue || 0
    };
  }

  handleMinusClick() {
    const value = this.state.value;
    this.setState({value: value - 1});
  }

  handlePlusClick() {
    const value = this.state.value;
    this.setState({value: value + 1});
  }

  render() {
    return (
      <div className="counter">
        <span style={{marginRight: '1rem'}}>{this.state.value}</span>
        <button onClick={this.handleMinusClick.bind(this)}>-</button>
        <button onClick={this.handlePlusClick.bind(this)}>+</button>
      </div>
    );
  }
}
