import React, {Component} from "react";

class App extends Component {
  constructor() {
    super();
    this.state = {};
  }

  render() {
    return (
      <form id="main-form">
        <input placeholder="hackthon name" />
      </form>
    );
  }
}

export default App;
