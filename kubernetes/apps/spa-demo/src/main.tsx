import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import App from "./App";
import { SplunkRumProvider } from "./lib/rumbootstrap";
import { rumConfig } from "./rum.config";

ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
  <React.StrictMode>
    <BrowserRouter>
      <SplunkRumProvider configOverride={rumConfig}>
        <App />
      </SplunkRumProvider>
    </BrowserRouter>
  </React.StrictMode>
);
