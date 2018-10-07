'user strict';

require('../../index.html');
const Elm = require('../elm/GitHubUser.elm');

const node = document.getElementById('app');
Elm.GitHubUser.embed(node);