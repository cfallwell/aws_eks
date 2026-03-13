import type { RumConfig } from "@cfallwell/rumbootstrap";

const ignoreUrls = import.meta.env.VITE_SPLUNK_RUM_IGNORE_URLS
  ? import.meta.env.VITE_SPLUNK_RUM_IGNORE_URLS.split(",")
      .map((value) => value.trim())
      .filter(Boolean)
  : ["http://sampleurl.org"];

export const rumConfig: RumConfig = {
  realm: import.meta.env.VITE_SPLUNK_RUM_REALM || "us1",
  rumAccessToken: import.meta.env.VITE_SPLUNK_RUM_ACCESS_TOKEN || "",
  applicationName: import.meta.env.VITE_SPLUNK_RUM_APPLICATION_NAME || "shopping-spa-demo",
  environment: import.meta.env.VITE_SPLUNK_RUM_ENVIRONMENT || "development",
  debug: import.meta.env.VITE_SPLUNK_RUM_DEBUG === "true",
  ignoreUrls,
};
