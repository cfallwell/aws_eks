/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_SPLUNK_RUM_REALM?: string;
  readonly VITE_SPLUNK_RUM_ACCESS_TOKEN?: string;
  readonly VITE_SPLUNK_RUM_APPLICATION_NAME?: string;
  readonly VITE_SPLUNK_RUM_ENVIRONMENT?: string;
  readonly VITE_SPLUNK_RUM_DEBUG?: string;
  readonly VITE_SPLUNK_RUM_IGNORE_URLS?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
