var path = require('path');

module.exports = {
  entry: './src/js/index.js',
  output: {
    path: path.join(__dirname, "js"),
    filename: 'src.js'
  },

  module: {
    loaders: [{
        test: /\.html$/,
        exclude: /node_modules/,
        loader: 'file-loader?name=[name].[ext]'
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: 'elm-webpack-loader',
          options: {
            debug: true
          }
        }
      }
    ]
  }
};