/* eslint-disable import/extensions */
/* eslint-disable react/jsx-filename-extension */

/* global window, document */

import "@babel/polyfill";

import React from "react";
import ReactDOM from "react-dom";

import App from "./components/App.jsx";

const wrapper = document.getElementById("root");
ReactDOM.render(<App />, wrapper);
