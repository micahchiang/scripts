#!/bin/bash

# This is a setup script that sets up an opinionated, lightweight react project

echo "What is the name of your project?"

read projectName

echo "Creating folder for $projectName..."

mkdir $projectName && cd $projectName

echo "Setting up a default package.json file..."

npm init -y

echo "Installing dependencies..."

npm install react react-dom @reach/router react-test-renderer

echo "Do you want to use Redux for state management? (y/n)" 

read -r useRedux

if [[ $useRedux =~ ^([yY][eE][sS]|[yY])$ ]]; then
	npm install redux redux-thunk react-redux
fi

echo "Done..."

echo "Installing DevDependencies..."

npm install -D babel-core babel-eslint babel-plugin-transform-class-properties babel-plugin-transform-es2015-modules-commonjs babel-preset-env babel-preset-react eslint eslint-config-prettier eslint-plugin-import eslint-plugin-jsx-a11y eslint-plugin-prettier eslint-plugin-react jest parcel-bundler prettier

echo "Done..."

echo "Setting up Babel config..."

cat << EOF > .babelrc
{
  "presets": [
    "react",
    [
      "env",
      {
        "targets": {
          "browsers": ["last 2 versions"]
        }
      }
    ]
  ],
  "plugins": ["transform-class-properties"],
  "env": {
    "test": {
      "plugins": ["transform-es2015-modules-commonjs"],
    }
  }
}
EOF

echo "Done..."

echo "Setting up Prettier config..."

cat << EOF > .prettierrc
{}
EOF

echo "Done..."

echo "Setting up Eslint config..."

cat << EOF > .eslintrc.json
{
  "extends": [
    "eslint:recommended",
    "plugin:import/errors",
    "plugin:react/recommended",
    "plugin:jsx-a11y/recommended",
    "prettier",
    "prettier/react"
  ],
  "rules": {
    "react/prop-types": 0,
    "jsx-a11y/label-has-for": 0,
    "no-console": 1
  },
  "plugins": ["react", "import", "jsx-a11y"],
  "parser": "babel-eslint",
  "parserOptions": {
    "ecmaVersion": 2018,
    "sourceType": "module",
    "ecmaFeatures": {
      "jsx": true
    }
  },
  "env": {
    "es6": true,
    "browser": true,
    "node": true,
    "jest": true
  }
}
EOF

echo "Done..."

echo "Setting up gitignore..."

cat << EOF > .gitignore
.vscode/
.cache/
.env
dist/
node_modules/
EOF

echo "Done..."

echo "Setting up src..."

mkdir src && cd src

# index.html
cat << EOF > index.html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="ie=edge" />
    <title>My React Project</title>
</head>

<body>
    <div id="root">not rendered</div>
    <script src="./App.js"></script>
</body>

</html>
EOF

# unit tests and redux directories
mkdir __tests__

# if Redux is used create store and other redux directories.
if [[ $useRedux =~ ^([yY][eE][sS]|[yY])$ ]]; then

mkdir actionCreators
mkdir reducers

# store.js
cat << EOF > store.js
import { createStore, compose, applyMiddleware } from "redux";
import thunk from "redux-thunk";
import reducer from "./reducers";

const store = createStore(
  reducer,
  compose(
    applyMiddleware(thunk),
    typeof window === "object" &&
      typeof window.devToolsExtension !== "undefined"
      ? window.devToolsExtension()
      : f => f
  )
);

export default store;
EOF

# App.js
cat << EOF > App.js
import React from "react";
import { render } from "react-dom";
import { Router } from "@reach/router";
import { Provider } from "react-redux";
import store from "./store";

class App extends React.Component {

	render() {
		return (
			<div>
				<Provider store={store}>
					<Router></Router>
				</Provider>
			</div>
		)
	}
}

render(<App />, document.getElementById("root"));
EOF
else 
cat << EOF > App.js
import React from "react";
import { render } from "react-dom";
import { Router } from "@reach/router";

class App extends React.Component {

        render() {
                return (
                        <div>
                            <Router></Router>
                        </div>
                )
        }
}

render(<App />, document.getElementById("root"));
EOF
fi

echo "Done setting up src..."

cd ..

echo "Adding npm scripts to package.json..."

# It seems using the in-place flag (-i) in sed doesn't work too well on osx, and using extension backups is less portable
# so we'll just create an intermediate json file and use it to overwrite the original one.
# https://stackoverflow.com/questions/4247068/sed-command-with-i-option-failing-on-mac-but-works-on-linux
# Remove the default test script from package json using sed

sed "7d" package.json > package-new.json

# Create a new text file of the actual test scripts, and append it to package-new after line 6

cat << EOF > tests.txt
    "test": "jest --silent",
    "test-update": "jest --silent -u",
    "format": "prettier --write \"src/**/*.{js,jsx,css,json} \" ",
    "format-check": "prettier --list-different \"src/**/*.{js,jsx,css,json} \" ",
    "lint": "eslint \"src/**/*.{js,jsx}\"",
    "dev": "parcel src/index.html",
    "build": "parcel build --public-url ./dist/ src/index.html",
    "start": "npm run build && babel-node server.js"
EOF

sed "6 r tests.txt" package-new.json > package-w-scripts.json

# overwrite the original package json with the new one that has scripts and remove intermediate json file

mv package-w-scripts.json package.json
rm package-new.json
rm tests.txt

echo "Project setup complete."
