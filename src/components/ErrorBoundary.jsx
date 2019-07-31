/* eslint-disable react/prop-types */
/* eslint-disable react/destructuring-assignment */
import React from "react";
import {Button, ToastMessage} from "rimble-ui";

// TODO: implement ErrorBoundary react pattern
const ErrorBoundary = (props) => {
  const {error, errorInfo, close} = props;
  // eslint-disable-next-line react/destructuring-assignment
  if (error) {
    return (
      <React.Fragment>
        <ToastMessage.Failure
          my={0}
          message="Error"
          secondaryMessage="Unable to fullfil your request. Check the details section for more information"
        />
        <details style={{whiteSpace: "pre-wrap", color: "red"}}>
          {error && error.toString()}
          <br />
          {errorInfo && errorInfo.toString()}
        </details>
        <Button onClick={close}>Close error</Button>
      </React.Fragment>
    );
  }

  return null;
};

export default ErrorBoundary;
