import React, { createContext, useContext, useEffect } from "react";

export interface RumConfig {
  realm: string;
  rumAccessToken: string;
  applicationName: string;
  environment: string;
  debug?: boolean;
  ignoreUrls?: string[];
}

const RumConfigContext = createContext<RumConfig | null>(null);

export function SplunkRumProvider({
  children,
  configOverride,
}: {
  children: React.ReactNode;
  configOverride: RumConfig;
}) {
  return <RumConfigContext.Provider value={configOverride}>{children}</RumConfigContext.Provider>;
}

export function RumRouterTracker() {
  const config = useContext(RumConfigContext);

  useEffect(() => {
    if (config?.debug) {
      console.debug("RUM router tracking enabled for", config.applicationName);
    }
  }, [config]);

  return null;
}

export function useEnableReplayPersist() {
  const config = useContext(RumConfigContext);

  return () => {
    if (typeof window === "undefined") {
      return;
    }

    window.localStorage.setItem("spa-demo:session-replay-enabled", "true");

    if (config?.debug) {
      console.debug("Session replay toggle stored locally.");
    }
  };
}
