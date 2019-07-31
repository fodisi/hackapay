import React, {Component} from "react";
import PropTypes from "prop-types";

import {Box, MetaMaskButton, Loader} from "rimble-ui";

const Header = (props) => (
  <div className="container">
    <Box bg="white" color="white" fontSize={4} p={3} width={[1, 1, 0.5]}>
      <MetaMaskButton size="small">Connect with MetaMask</MetaMaskButton>
      {/* eslint-disable-next-line react/destructuring-assignment */}
      {props.processing && <Loader />}
    </Box>
    {/* TODO: display metamask status and allows enabling it */}
  </div>
);

Header.defaultProps = {
  processing: false,
};

Header.propTypes = {
  processing: PropTypes.bool,
};

export default Header;
