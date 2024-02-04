/* @refresh reload */
import { render } from 'solid-js/web';
import { Main, Players } from './pages';

import './root.css';
import { Router, Route, RouteSectionProps } from '@solidjs/router';

const App = (props: RouteSectionProps) => {
  return (
    <div class="bg-slate-700 min-h-screen flex flex-col items-center justify-center text-white">
      {props.children}
    </div>
  );
};

const root = document.getElementById('root');

if (import.meta.env.DEV && !(root instanceof HTMLElement)) {
  throw new Error(
    'Root element not found. Did you forget to add it to your index.html? Or maybe the id attribute got misspelled?',
  );
}

render(() => (
  <Router>
    <Route path="/" component={App}>
      <Route path="/" component={Main} />
      <Route path="/players" component={Players} />
    </Route>
  </Router>
), root!);
