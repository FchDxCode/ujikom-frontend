module.exports = {
    webpack: {
      configure: (webpackConfig) => {
        webpackConfig.module.rules.push({
          enforce: 'pre',
          test: /\.js$/,
          loader: 'source-map-loader',
          exclude: /node_modules/,
        });
        return webpackConfig;
      },
    },
  };
  