import React from 'react';
import logo from './logo.svg';
import './App.css';
import SideNavigationBar from './components/sidebar/side-navigation-bar';

function App() {
  const navbarItems = [
    {label: "Item 1", fontAwesomeClassName: "fa-plus-circle", tooltip: "this is item 1"},
    {label: "Item 2", icon: "minus_circle", tooltip: "this is item 2"},
    {label: "Item 3", icon: "delete", tooltip: "this is item 3"},
    {label: "Item 4", icon: "add_circle", tooltip: "this is item 4"},
    {label: "Item 5", icon: "add_circle", tooltip: "this is item 5"},
  ];

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>

      
      <SideNavigationBar
        navbarItems={navbarItems}
      />
    </div>
  );
}

export default App;
