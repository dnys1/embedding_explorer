// Monaco Editor bundle
import * as monaco from 'monaco-editor';

// Configure worker environment for Monaco Editor
globalThis.MonacoEnvironment = {
  getWorkerUrl: function (moduleId, label) {
    if (label === 'json') {
      return '/js/json.worker.js';
    }
    if (label === 'css' || label === 'scss' || label === 'less') {
      return '/js/css.worker.js';
    }
    if (label === 'html' || label === 'handlebars' || label === 'razor') {
      return '/js/html.worker.js';
    }
    if (label === 'typescript' || label === 'javascript') {
      return '/js/ts.worker.js';
    }
    return '/js/editor.worker.js';
  }
};

// Export monaco globally
globalThis.monaco = monaco;
