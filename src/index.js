/* eslint-disable import/extensions */
/* eslint-disable react/jsx-filename-extension */

/* global window, document */

import "@babel/polyfill";

import React from "react";
import ReactDOM from "react-dom";

import App from "./components/App.jsx";

// import getWeb3 from "./utils/getWeb3";

// async function load() {
//   // Get network provider and web3 instance.
//   const web3 = await getWeb3();

//   // Use web3 to get the user's accounts.
//   const accounts = await web3.eth.getAccounts();

//   // Get the contract instance.
//   const networkId = await web3.eth.net.getId();

//   window.web3Instance = web3;
//   window.accounts = accounts;
//   window.networkId = networkId;

//   const wrapper = document.getElementById("root");
//   ReactDOM.render(<App />, wrapper);
// }

// load();

const wrapper = document.getElementById("root");
ReactDOM.render(<App />, wrapper);
